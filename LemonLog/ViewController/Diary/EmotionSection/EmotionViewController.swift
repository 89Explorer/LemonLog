//
//  EmotionViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/11/25.
//

import UIKit

class EmotionViewController: UIViewController {
    
    
    // MARK: ✅ Data
    private let emotions: [EmotionCategory] = EmotionCategory.allCases
    
    
    // MARK: ✅ Closure
    var onEmotionSelected: ((EmotionCategory) -> Void)?
    
    
    // MARK: ✅ UI
    private var dateLabel: UILabel!
    private var titleLabel: UILabel!
    private var emotionCollectionView: UICollectionView!

    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .secondarySystemBackground
        
        dateLabel = UILabel()
        dateLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        dateLabel.font = .systemFont(ofSize: 16, weight: .bold)
        dateLabel.textColor = .black
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel = UILabel()
        titleLabel.text = "오늘의 감정을 선택하세요 :)"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 3열 Grid Layout 구성
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 24
        
        emotionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emotionCollectionView.delegate = self
        emotionCollectionView.dataSource = self
        emotionCollectionView.backgroundColor = .clear
        emotionCollectionView.showsVerticalScrollIndicator = false
        
        emotionCollectionView.register(SelectEmotionCell.self, forCellWithReuseIdentifier: SelectEmotionCell.reuseIdentifier)
        
        emotionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(dateLabel)
        view.addSubview(titleLabel)
        view.addSubview(emotionCollectionView)
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emotionCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            emotionCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            emotionCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            emotionCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    
    }

}


// MARK: ✅ Extension - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension EmotionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emotions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectEmotionCell.reuseIdentifier, for: indexPath) as? SelectEmotionCell else { return UICollectionViewCell() }
        
        let emotionImage = emotions[indexPath.item]
        
        cell.configure(with: emotionImage)

        return cell
    }
    
    // 3열 고정 셀 크기 계산
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacing: CGFloat = 20.0
        let totalSpacing = (spacing * 2) + (spacing * 2) // 좌우, 셀 간격 고려
        let availableWidth = collectionView.bounds.width - totalSpacing
        let cellWidth = floor(availableWidth / 3)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEmotion = emotions[indexPath.item]
        onEmotionSelected?(selectedEmotion)
        dismiss(animated: true)
    }
}

