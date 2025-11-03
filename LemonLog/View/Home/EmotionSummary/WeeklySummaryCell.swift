//
//  WeeklySummaryCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/2/25.
//

import UIKit


class WeeklySummaryCell: UICollectionViewCell {
    
    
    // MARK: ✅ Static
    static let reuseIdentifier: String = "WeeklySummaryCell"
    
    
    // MARK: ✅ Property
    private var emotions: [DiaryCoreDataManager.Weekday: EmotionCategory] = [:]
    
    
    // MARK: ✅ UI
    private let weekLabel: UILabel = UILabel()
    private let topEmotionLabel: UILabel = UILabel()
    private let topEmotionStackView: UIStackView = UIStackView()
    private var emotionCollectionView: UICollectionView!
    
    
    // MARK: ✅ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCollectionView()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // top3 이미지 초기화
        for view in topEmotionStackView.arrangedSubviews {
            (view as? UIImageView)?.image = nil
            view.isHidden = true 
        }
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        contentView.backgroundColor = UIColor.vanillaCream
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        weekLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        weekLabel.textColor = .label
        weekLabel.textAlignment = .left
        weekLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topEmotionLabel.text = "이번 주에 많이 느낀 감정: "
        topEmotionLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        topEmotionLabel.textColor = .secondaryLabel
        topEmotionLabel.textAlignment = .left
        topEmotionLabel.numberOfLines = 1
        
        topEmotionStackView.axis = .horizontal
        topEmotionStackView.spacing = 8
        topEmotionStackView.alignment = .center
        topEmotionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        emotionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(weekLabel)
        contentView.addSubview(emotionCollectionView)
        contentView.addSubview(topEmotionStackView)
        topEmotionStackView.addArrangedSubview(topEmotionLabel)
        
        // 이미지 자리 미리 추가
        for _ in 0..<3 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            topEmotionStackView.addArrangedSubview(imageView)
        }
        
        NSLayoutConstraint.activate([
            weekLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            weekLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weekLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emotionCollectionView.topAnchor.constraint(equalTo: weekLabel.bottomAnchor, constant: 8),
            emotionCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emotionCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            emotionCollectionView.heightAnchor.constraint(equalToConstant: 60),
            
            topEmotionStackView.topAnchor.constraint(equalTo: emotionCollectionView.bottomAnchor, constant: 16),
            topEmotionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topEmotionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    
    // MARK: ✅ Configure CollectionView
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        //layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        emotionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emotionCollectionView.dataSource = self
        emotionCollectionView.delegate = self
        emotionCollectionView.isScrollEnabled = false
        emotionCollectionView.backgroundColor = .clear
        emotionCollectionView.register(EmotionDayCell.self, forCellWithReuseIdentifier: EmotionDayCell.reuseIdentifier)
    }
    
    
    // MARK: ✅ Configure Data
    func configure(
        weekText: String,
        emotions: [DiaryCoreDataManager.Weekday: EmotionCategory],
        top3: [EmotionCategory]
    ) {
        self.weekLabel.text = weekText
        self.emotions = emotions
        
        for (index, view) in topEmotionStackView.arrangedSubviews.enumerated() {
            // 0번은 제목 라벨이므로 건너뜀
            guard let imageView = view as? UIImageView else { continue }
            let emotionIndex = index - 1     // 이미뷰는 1,2,3번째
            
            if emotionIndex >= 0 && emotionIndex < top3.count {
                let emotion = top3[emotionIndex]
                
                // 렌더링 모드, 사이즈 문제 회피용: 원본으로 표시
                imageView.image = emotion.emotionImage?.withRenderingMode(.alwaysOriginal)
                imageView.isHidden = false
            } else {
                imageView.image = nil
                imageView.isHidden = true
            }
        }
    }
}


// MARK: ✅ Extension (UICollectionViewDataSource, UICollectionViewDelegateFlowLayout)
extension WeeklySummaryCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        DiaryCoreDataManager.Weekday.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmotionDayCell.reuseIdentifier, for: indexPath) as? EmotionDayCell else {
            return UICollectionViewCell()
        }
        
        let day = DiaryCoreDataManager.Weekday.allCases[indexPath.item]
        let emotion = emotions[day] ?? ._1
        cell.configure(dayText: day.rawValue, emotion: emotion)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 24) / 7
        return CGSize(width: width, height: 60)
    }

}
