//
//  CustomCalendarViewController.swift
//  LemonLog
//
//  Created by 권정근 on 12/10/25.
//
// ▶️ 날짜를 선택하는 사용하는 MonthCalendarCell을 담은 뷰컨 ◀️

import UIKit
import Combine

final class CustomCalendarViewController: UIViewController {
    
    
    private var didScrollToCenterInitially = false
    
    // MARK: ✅ Callback
    var onDateSelected: ((Date) -> Void)?
    var onImageSelected: ((UIImage?) -> Void)?
    
    
    // MARK: ✅ ViewModel
    private let calendarVM: CalendarViewModel
    private var cancellables = Set<AnyCancellable>()

    
    // MARK: ✅ UI
    private var calendarCollectionView: UICollectionView!
    
    
    // MARK: ✅ Initialization
    init(viewModel: CalendarViewModel = CalendarViewModel()) {
        self.calendarVM = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 레이아웃이 잡힌 뒤, 최초 한 번만 현재달(중앙)로 이동
        guard !didScrollToCenterInitially else { return }
        didScrollToCenterInitially = true
        
        calendarCollectionView.reloadData()
        scrollToCenter()
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .clear
        setupCollectionView()
        setupLayout()
       
    }
    
    
    private func bindingViewModel() {
        calendarVM.$months
            .sink { [weak self] _ in
                self?.calendarCollectionView.reloadData()
                self?.scrollToCenter()
            }
            .store(in: &cancellables)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        self.calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        calendarCollectionView.backgroundColor = .systemBackground
        calendarCollectionView.isPagingEnabled = true
        calendarCollectionView.showsHorizontalScrollIndicator = false
        calendarCollectionView.register(MonthCalendarCell.self, forCellWithReuseIdentifier: MonthCalendarCell.reuseIdentifier)
        
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
    }
    
    private func setupLayout() {
        view.addSubview(calendarCollectionView)
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            calendarCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func scrollToCenter() {
        guard calendarVM.months.count >= 3 else { return }
        let center = IndexPath(item: 1, section: 0)
        calendarCollectionView.scrollToItem(at: center, at: .centeredHorizontally, animated: false)
    }
    
}


// MARK: ✅ Extension (UICollectionViewDataSource, UICollectionViewDelegate)
extension CustomCalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarVM.months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthCalendarCell.reuseIdentifier, for: indexPath) as! MonthCalendarCell
        
        let month = calendarVM.months[indexPath.item]   // ✅ indexPath에 맞는 month 전달
        cell.configure(with: calendarVM, month: month, mode: .full)
        
        cell.onDaySelected = { [weak self] selectedDate in
            guard let self else { return }
            
            // VC 외부 연결
            self.onDateSelected?(selectedDate)
            
            // 캘린더 닫기
            self.dismiss(animated: true)
        }
        return cell
    }
    
    // 셀 사이즈 (한 달 = 한 페이지)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height)
    }
    
    // 스크롤 끝났을 때 → 방향에 따라 month 이동
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        guard width > 0 else { return }
        
        let rawPage = scrollView.contentOffset.x / width
        let page = Int(round(rawPage))
        print("rawPage:", rawPage, "→ page:", page)
        
        // 왼쪽 (page 0) / 가운데 (1) / 오른쪽 (2)
        if page == 0 {
            calendarVM.moveMonth(isForward: false)
        } else if page == 2 {
            calendarVM.moveMonth(isForward: true)
        } else {
            return
        }
        
        // months가 변경되었으니, 즉시 다시 3페이지 구성 + 중앙으로
        calendarCollectionView.reloadData()
        scrollToCenter()
    }

}


