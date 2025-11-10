//
//  CustomCalendarViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/6/25.
//
//

import UIKit
import Combine


@MainActor
final class CustomCalendarViewController: UIViewController {

    
    // MARK: ✅ ViewModel & Cancellables
    private var viewModel: CalendarViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ Property
    // 선택할 날짜 저장
    private let initializedDate: Date
    
    
    // MARK: ✅ Closuer
    // 선택된 날짜를 전달할 콜백
    private let onSelectDate: (Date) -> Void
    

    // MARK: ✅ UI
    private let monthLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let weekView = WeekView()

    // "월" 단위로 스크롤되는 컬렉션뷰
    private lazy var pagerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(MonthCollectionCell.self, forCellWithReuseIdentifier: MonthCollectionCell.reuseIdentifier)
        return cv
    }()
    
    
    // MARK: ✅ Init
    init(initializedDate: Date = Date(),
         mode: CalendarMode = .dateOnly,
         onSelectDate: @escaping (Date) -> Void
    ) {
        self.initializedDate = initializedDate
        self.onSelectDate = onSelectDate
        
        // ✅ 초기 날짜로 바로 앵커 고정
        self.viewModel = CalendarViewModel(initialDate: initializedDate, mode: mode)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    
    // MARK: ✅ LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let layout = pagerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            // 각 셀=한 페이지 (전체 화면에 꽉차게)
            // MonthCollectionCell이 화면 전체 크기만큼 차지하도록 함
            layout.itemSize = pagerCollectionView.bounds.size
        }
        
        // 최초 진입 시 가운데(현재월)로 이동
        // viewModel에서 months 배열은 항상 [이전, 현재, 다음] 형태
        // 그런데 컬렉션뷰는 처음 표시될 때 자동으로 인데스 0 (이전 달)부터 보여줌
        // 아래 코드를 통해 현재 월 (가운데, 인덱스 1)로 강제 스크롤 시켜줌
        DispatchQueue.main.async {
            self.scrollToCenterPage(animated: false)
        }
    }

    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .secondarySystemBackground

        monthLabel.font = .boldSystemFont(ofSize: 16)
        monthLabel.textAlignment = .center

        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let prevImage = UIImage(systemName: "chevron.backward", withConfiguration: config)
        
        prevButton.setImage(prevImage, for: .normal)
        prevButton.tintColor = .black
        prevButton.addTarget(self, action: #selector(didTapPrev), for: .touchUpInside)

        
        let nextImage = UIImage(systemName: "chevron.forward", withConfiguration: config)
        nextButton.setImage(nextImage, for: .normal)
        nextButton.tintColor = .black
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)

        let header = UIStackView(arrangedSubviews: [prevButton, monthLabel, nextButton])
        header.axis = .horizontal
        header.spacing = 8
        header.distribution = .fill

        [header, weekView, pagerCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            weekView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            weekView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            weekView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            weekView.heightAnchor.constraint(equalToConstant: 20),

            pagerCollectionView.topAnchor.constraint(equalTo: weekView.bottomAnchor, constant: 4),
            pagerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            pagerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            pagerCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    

    // MARK: ✅ Binding Data
    private func setupBindings() {
        viewModel.$currentMonth
            .receive(on: RunLoop.main)
            .sink { [weak self] month in
                guard let self else { return }
                self.monthLabel.text = self.viewModel.headerTitle(for: month)
                self.pagerCollectionView.reloadData()
                // 데이터 롤링 후 가운데 페이지로 재정렬
                self.scrollToCenterPage(animated: false)
            }
            .store(in: &cancellables)
    }
    
    // 👍 핵심 로직: 달력의 중앙을 항상 “현재 월”로 유지시키는 함수.
    // 달력이 항상 현재 월(중앙 페이지 = viewmodel.months[1])을 기준으로 보이게 하는 함수
    private func scrollToCenterPage(animated: Bool) {
        // viewModel.months = [이전달, 현재달, 다음달] -> 인덱스 1 인 "현재달" = center
        let center = IndexPath(item: 1, section: 0)
        
        // 컬렉션뷰가 아직 데이터를 로드하기 전이라면,
        // scrollToItem을 호출해도 이동할 대상이 없어서 발생하는 크래시 방지
        // 최소 2개 이상의 아이템 [이전, 현재, 다음] 이 준비된 상태일 때만 스크롤 수행
        if pagerCollectionView.numberOfItems(inSection: 0) > 1 {
            pagerCollectionView.scrollToItem(at: center, at: .centeredHorizontally, animated: animated)
        }
    }
    

    // MARK: ✅ Actions
    @objc private func didTapPrev() {
        viewModel.moveMonth(isForward: false) // -> 바인딩 통해 reload + recenter
    }

    @objc private func didTapNext() {
        viewModel.moveMonth(isForward: true)  // -> 바인딩 통해 reload + recenter
    }

}


// MARK: ✅ Extension - UICollectionViewDataSource
extension CustomCalendarViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 항상 3페이지: [이전, 현재, 다음]
        return viewModel.months.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MonthCollectionCell.reuseIdentifier,
            for: indexPath
        ) as? MonthCollectionCell else {
            return UICollectionViewCell()
        }
        
        let month = viewModel.months[indexPath.item]
       
        // 초기 선택 날짜 전달
        cell.configure(month: month,
                       viewModel: viewModel,
                       initialSelectedDate: initializedDate)

        // ✅ 날짜 선택 시 콜백 전달 + dismiss
        cell.onSelectDate = { [weak self] date in
            
            self?.viewModel.anchor(to: date)
            self?.onSelectDate(date)
            self?.dismiss(animated: true)
        }
        return cell
    }
}


// MARK: ✅ MARK - UICollectionViewDelegate (무한 페이징 핵심)
extension CustomCalendarViewController: UICollectionViewDelegate {
    
    // 사용자가 손을 떼고 자연스럽게 스크롤이 멈췄을 때 호출
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustMonthsIfNeeded()
    }
    
    // 사용자가 스크롤하다가 바로 손을 떼서 멈출 때 호출
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { adjustMonthsIfNeeded() }
    }

    // "달" 넘기기 로직의 핵심
    // 스크롤 방향 판단 -> moveMonth() 호출 -> currentMonth 갱신 
    private func adjustMonthsIfNeeded() {
        let pageWidth = pagerCollectionView.bounds.width
        guard pageWidth > 0 else { return }

        // scrollPositionX -> 현재 스크롤된 가로 위치 의미
        let scrollPositionX = pagerCollectionView.contentOffset.x
        
        // page -> 한 페이지(한 달)의 너비 pageWidth를 나누면
        // 지금 몇 번째 페이지 (index)인지 확인
        let page = Int(round(scrollPositionX / pageWidth))
        switch page {
        case 0:
            // 왼쪽 끝(이전달)으로 스와이프 → months 롤링 후 가운데로 복귀
            viewModel.moveMonth(isForward: false)
        case 2:
            // 오른쪽 끝(다음달)으로 스와이프 → months 롤링 후 가운데로 복귀
            viewModel.moveMonth(isForward: true)
        default:
            break // 가운데면 아무 것도 안 함
        }
    }
}
