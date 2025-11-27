//
//  HomeRecentDiaryViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/26/25.
//

import UIKit
import Combine


final class HomeRecentDiaryViewController: UIViewController {
    
    
    // MARK: ✅ ViewModel
    private let homeVM: HomeViewModel
    
    
    // MARK: ✅ Dependencies
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ UI
    private var collectionView: UICollectionView!
    
    
    // MARK: ✅ Init
    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
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
    }
    
    
    // MARK: ✅ Bind Data
    private func bindViewModel() {
        homeVM.$totalDiaries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .pastelLemon

        // COLLECTIONVIEW ----------------------------------
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        
        let width: CGFloat = (UIScreen.main.bounds.width - (4 * 3)) / 3
        layout.itemSize = CGSize(width: width, height: width)
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(DiarySummaryCell.self, forCellWithReuseIdentifier: DiarySummaryCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 2),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -2),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


// MARK: ✅ Extension - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeRecentDiaryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.homeVM.totalDiaries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiarySummaryCell.reuseIdentifier, for: indexPath) as? DiarySummaryCell else { return UICollectionViewCell() }
        
        let summary = self.homeVM.totalDiaries[indexPath.item]
        cell.configure(with: summary, summary: summary.summaryText)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = self.homeVM.totalDiaries[indexPath.item]
        
        let recentDiaryVC = DetailDiaryViewController(from: selectedItem)
        let naviVC = UINavigationController(rootViewController: recentDiaryVC)
        self.navigationController?.present(naviVC, animated: true)
    }
    
}


// MARK: ✅ Extension - 네비게이션 설정
extension HomeRecentDiaryViewController {
    
    private func configureNavigation() {
        navigationItem.hidesBackButton = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        //let backImage = UIImage(systemName: "xmark", withConfiguration: config)
        
        let backBarButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(didTappedBack))
        backBarButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = backBarButton
    }
    
    
    @objc private func didTappedBack() {
        //navigationController?.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}
