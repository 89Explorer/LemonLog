//
//  EmotionStepCell.swift
//  LemonLog
//
//  Created by 권정근 on 12/7/25.
//


import UIKit


final class EmotionStepCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "EmotionStepCell"
    
    
    // MARK: ✅ UI
    private var titleLabel: UILabel = UILabel()
    private var guideLabel: UILabel = UILabel()
    private var emotionCollectionView: UICollectionView!
    
    
    // MARK: ✅ Data
    private var categories: [EmotionCategory] = []
    private var expandedCategory: EmotionCategory?
    private var selectedSubEmotions: [EmotionCategory: Set<String>] = [:]
    
    // 셀 선택이 남아 있는 것을 방지하기 위한 프로퍼티
    private var expandedIndexPath: IndexPath?
    private var selectionEnabled: Bool = true
    
    
    // MARK: ✅ Callback
    var onEmotionSelected: ((EmotionCategory, [String]) -> Void)?
    var onTrySelectEmotion: ((EmotionCategory, [String]) -> Bool)?


    // MARK: ✅ Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupCollectionView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Configure
    func configure(title: String, guide: String, categories: [EmotionCategory]) {
        titleLabel.text = title
        guideLabel.text = guide
        self.categories = categories
        emotionCollectionView.reloadData()
    }
}


// MARK: ✅ Extension (UI 기본 설정, AutoLayout 구성)
extension EmotionStepCell {
    
    private func setupUI() {

        //titleLabel.text = "오늘의 감정"
        titleLabel.font = UIFont(name: "DungGeunMo", size: 22)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black

        //guideLabel.text = "지금 느끼는 감정을 선택해주세요"
        guideLabel.font = UIFont(name: "DungGeunMo", size: 12)
        guideLabel.textColor = .darkGray
        guideLabel.numberOfLines = 0
        guideLabel.textAlignment = .center
    }
    
    private func setupLayout() {

        [titleLabel, guideLabel, emotionCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            guideLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            guideLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            emotionCollectionView.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 20),
            emotionCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emotionCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emotionCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

}


// MARK: ✅ Extension (emotionCollectionView 구성)
extension EmotionStepCell {
    
    private func setupCollectionView() {

        let layout = UICollectionViewCompositionalLayout { _, _ in
            
            // 1) 각 셀
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),   // 가로의 1/2 → 2열
                heightDimension: .estimated(120)          // 내용에 따라 늘어나는 높이
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // estimated 축(세로)에 인셋 주지 말고, 좌우만 인셋
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 4,
                bottom: 0,
                trailing: 4
            )

            // 가로 2개짜리 그룹 (2열)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(120)
            )
            
            // 가로 2개
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 2
            )
            
            // 같은 줄 안에서 두 셀 사이의 간격
            group.interItemSpacing = .fixed(4)

            let section = NSCollectionLayoutSection(group: group)
            
            // 줄과 줄 사이의 간격
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 20, trailing: 8)

            return section
        }

        emotionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emotionCollectionView.backgroundColor = .clear
        emotionCollectionView.delegate = self
        emotionCollectionView.dataSource = self

        emotionCollectionView.register(
            EmotionCategoryCell.self,
            forCellWithReuseIdentifier: "EmotionCategoryCell"
        )
    }
    
    // EmotionCategoryCell 에 선택한 셀을 전달하는 함수
    func updateSelectEnabled(_ allowed: Bool) {
        self.selectionEnabled = allowed
        emotionCollectionView.visibleCells.forEach { cell in
            (cell as? EmotionCategoryCell)?.setSelectionEnabled(allowed)
        }
    }

}


// MARK: ✅ Extension (UICollectionView DataSource)
extension EmotionStepCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EmotionCategoryCell",
            for: indexPath
        ) as! EmotionCategoryCell
        
        let category = categories[indexPath.item]
        
        cell.configure(
            category: category,
            expanded: expandedCategory == category,
            selected: Array(selectedSubEmotions[category] ?? [])
        )
        
        // 선택 콜백
        cell.onSelectSubEmotion = { [weak self] subs in
            guard let self else { return }
            
            let tapped = subs.first!                                   // 방금 눌린 아이템
            let category = category                                    // 이 셀의 대 분류
            var current = self.selectedSubEmotions[category] ?? []     // 현재 선택 상태 가져오기
            
            // 후보 상태 만들기
            var candidate = current
            if candidate.contains(tapped) {
                candidate.remove(tapped)
            } else {
                candidate.insert(tapped)
            }
            
            // 먼저 viewModel에 물어보기
            let allowed = self.onTrySelectEmotion?(category, Array(candidate)) ?? true
            
            if !allowed {
                // ❌ 실패 → UI는 변경하지 않고 그대로 둔다.
                return
            }
            
            // 성공이면 로컬 상태 업데이트
            self.selectedSubEmotions[category] = candidate
            self.onEmotionSelected?(category, Array(candidate))
            
            // 이 카테고리 셀만 다시 그리기
            if let idx = self.categories.firstIndex(of: category) {
                let indexPath = IndexPath(item: idx, section: 0)
                self.emotionCollectionView.reloadItems(at: [indexPath])
            }
        
        }
        
        return cell
    }
}


// MARK: ✅ Extension (UICollectionView Delegate)
extension EmotionStepCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let category = categories[indexPath.item]
        let previousIndexPath = expandedIndexPath   // 선택된 인덱스 저장

        if expandedCategory == category {
            // 펼쳐진 상태 → 접기
            expandedCategory = nil
            expandedIndexPath = nil
        } else {
            // 다른 셀 펼치기
            expandedCategory = category
            expandedIndexPath = indexPath
        }
        
        // 레이아웃 변화 애니메이션
        collectionView.performBatchUpdates(nil)

        // 선택된 셀만 부드럽게 업데이트
        if let cell = collectionView.cellForItem(at: indexPath) as? EmotionCategoryCell {
            cell.animateToggle(expanded: expandedCategory == category)
        }
        
        // 이전에 열려 있던 셀 닫기
        if let prev = previousIndexPath,
        prev != indexPath,
        let previousCell = collectionView.cellForItem(at: prev) as? EmotionCategoryCell {
            previousCell.animateToggle(expanded: false)
        }
        
    }
}

