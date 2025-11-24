//
//  EmotionSummaryHeaderViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/19/25.
//

import UIKit
import Combine


@MainActor
class EmotionSummaryHeaderViewController: UIViewController {
    
    
    // MARK: ✅ ViewModel
    private let emotionSummaryVM: EmotionSummaryHeaderViewModel
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ UI
    private let prevButton: UIButton = UIButton(type: .system)
    private let monthLabel: UILabel = UILabel()
    private let nextButton: UIButton = UIButton(type: .system)
    
    private let summaryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 28
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    
    // MARK: ✅ Init
    init() {
        self.emotionSummaryVM = EmotionSummaryHeaderViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureUI()
        bindViewModel()
        configureActions()
    }
    
    
    // MARK: ✅ Bindings
    private func bindViewModel() {
        
        emotionSummaryVM.$currentMonth
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.monthLabel.text = self.emotionSummaryVM.monthTitle()
            }
            .store(in: &cancellables)
        
        emotionSummaryVM.$weeklyModels
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.summaryCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .pastelLemon
    
        summaryCollectionView.showsVerticalScrollIndicator = false
        summaryCollectionView.backgroundColor = .clear
        summaryCollectionView.dataSource = self
        summaryCollectionView.delegate = self
        summaryCollectionView.register(WeeklySummaryCell.self, forCellWithReuseIdentifier: WeeklySummaryCell.reuseIdentifier)
        
        summaryCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
        view.addSubview(summaryCollectionView)
        
        NSLayoutConstraint.activate([
            
            summaryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            summaryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            summaryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            summaryCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
            
        ])
    }
}


// MARK: ✅ Extension -> Prev / Next 버튼 액션
extension EmotionSummaryHeaderViewController {
    
    private func configureActions() {
        prevButton.addTarget(self, action: #selector(didTapPrev), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    @objc private func didTapPrev() {
        emotionSummaryVM.moveMonth(isForward: false)
    }
    
    @objc private func didTapNext() {
        emotionSummaryVM.moveMonth(isForward: true)
    }
    
}


// MARK: ✅ Extension -> 네비게이션아이템 설정
extension EmotionSummaryHeaderViewController {
    
    private func configureNavigation() {
        navigationItem.hidesBackButton = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        //let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        let backImage = UIImage(systemName: "xmark", withConfiguration: config)
        
        let backBarButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(didTappedBack))
        backBarButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = backBarButton
        
        
        monthLabel.font = .systemFont(ofSize: 16, weight: .bold)
        monthLabel.textAlignment = .center
        monthLabel.textColor = .black
        
        let buttonconfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let prevImage = UIImage(systemName: "arrowtriangle.backward.fill", withConfiguration: buttonconfig)
        
        prevButton.setImage(prevImage, for: .normal)
        prevButton.tintColor = .systemGray
        
        let nextImage = UIImage(systemName: "arrowtriangle.right.fill", withConfiguration: buttonconfig)
        nextButton.setImage(nextImage, for: .normal)
        nextButton.tintColor = .systemGray
        
        let headerStackView: UIStackView = UIStackView(arrangedSubviews: [prevButton, monthLabel, nextButton])
        headerStackView.axis = .horizontal
        headerStackView.spacing = 8
        headerStackView.distribution = .fill
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        navigationItem.titleView = headerStackView
        
        NSLayoutConstraint.activate([
            headerStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    
    
    @objc private func didTappedBack() {
        navigationController?.dismiss(animated: true)
    }
}


// MARK: ✅ Extension -> UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension EmotionSummaryHeaderViewController: UICollectionViewDataSource,
                                              UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        emotionSummaryVM.weeklyModels.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WeeklySummaryCell.reuseIdentifier,
            for: indexPath
        ) as! WeeklySummaryCell

        let model = emotionSummaryVM.weeklyModels[indexPath.item]

        cell.configure(
            model: model
        )

        return cell
    }

    // Cell 높이
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.width, height: 140)
    }
}


