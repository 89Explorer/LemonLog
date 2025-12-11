//
//  DiaryWriteDateAndGalleryCell.swift
//  LemonLog
//
//  Created by 권정근 on 12/10/25.
//
// ▶️ 감정일기에서 날짜와 사진을 선택하는 셀 ◀️

import UIKit

final class DiaryWriteDateAndGalleryCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "DiaryWriteDateAndGalleryCell"
    
    
    // MARK: ✅ Callback
    // 날짜 라벨을 탭했을 때 상위 VC에 알려주는 콜백
    var onTapDate: (() -> Void)?
    
    
    var onSelectPhoto: ((DiaryPhotoGalleryCell) -> Void)?
    var onImagesUpdated: (([UIImage]) -> Void)?


    // MARK: ✅ Constants
    private let maxSelectableImageCount: Int = 3
    
    
    // MARK: ✅ UI
    private let titleLabel = UILabel()
    private let guideLabel = UILabel()
    private var internalCollectionView: UICollectionView!
    
    // Data
    private var selectedDate: Date = Date()
    private var images: [UIImage] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBaseUI()
        configureInternalCollectionView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    
    // Configure from VC
    func configure(titleKey: String, guideKey: String) {
        titleLabel.text = NSLocalizedString(titleKey, comment: "")
        guideLabel.text = NSLocalizedString(guideKey, comment: "")
    }
    
    // 날짜 갱신용 메서드
    func updateDate(_ date: Date) {
        self.selectedDate = date
        let sectionIndex = DateAndGallerySection.date.rawValue
        internalCollectionView.reloadSections(IndexSet(integer: sectionIndex))
    }

    // 이미지 갱신용 메서드 
    func updateImages(_ images: [UIImage]) {
        self.images = images
        internalCollectionView.reloadSections([DateAndGallerySection.gallery.rawValue])
    }

}



// MARK: ✅ Extension (UI 설정)
private extension DiaryWriteDateAndGalleryCell {

    func configureBaseUI() {
        titleLabel.font = UIFont(name: "DungGeunMo", size: 20)
        titleLabel.textAlignment = .center
        
        guideLabel.font = UIFont(name: "DungGeunMo", size: 12)
        guideLabel.textAlignment = .center
        guideLabel.numberOfLines = 0

        contentView.addSubview(titleLabel)
        contentView.addSubview(guideLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}


private extension DiaryWriteDateAndGalleryCell {

    func configureInternalCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16

        internalCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        internalCollectionView.backgroundColor = .clear
        internalCollectionView.isScrollEnabled = false

        internalCollectionView.dataSource = self
        internalCollectionView.delegate = self

        internalCollectionView.register(DiaryDateCell.self,
                                        forCellWithReuseIdentifier: DiaryDateCell.reuseIdentifier)
        internalCollectionView.register(DiaryPhotoGalleryCell.self,
                                        forCellWithReuseIdentifier: DiaryPhotoGalleryCell.reuseIdentifier)

        contentView.addSubview(internalCollectionView)
        internalCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
}


private extension DiaryWriteDateAndGalleryCell {

    func setupLayout() {

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            guideLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            guideLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            guideLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            internalCollectionView.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 20),
            internalCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            internalCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            internalCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}


extension DiaryWriteDateAndGalleryCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DateAndGallerySection.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let section = DateAndGallerySection(rawValue: indexPath.section)!

        switch section {

        case .date:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DiaryDateCell.reuseIdentifier,
                for: indexPath
            ) as! DiaryDateCell
            
            // 날짜 텍스트로 변환
            cell.configure(date: selectedDate)
            
            cell.onTapDate = { [weak self] in
                self?.onTapDate?()
            }
            return cell

        case .gallery:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DiaryPhotoGalleryCell.reuseIdentifier,
                for: indexPath
            ) as! DiaryPhotoGalleryCell
            
            cell.updateImages(images)
            
            cell.onImagesUpdated = { [weak self] updated in
                self?.images = updated
                self?.onImagesUpdated?(updated)
            }
            
            cell.onAddPhotoTapped = { [weak self, weak cell] in
                guard let self, let cell else { return }
                self.onSelectPhoto?(cell)   // ✅ 여기서 gallery 셀을 넘김
            }

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width
        let section = DateAndGallerySection(rawValue: indexPath.section)!

        switch section {
        case .date:
            return CGSize(width: width, height: 52)

        case .gallery:
            return CGSize(width: width, height: 200)
        }
    }
    
    // 섹션 간격 조정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let index = DateAndGallerySection(rawValue: section)!
        
        switch index {
        case .date:
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)   // 날짜 셀 아래쪽 간격
        case .gallery:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)   // 날짜 셀 아래쪽 간격
        }
    }
}


// MARK: ✅ Enum (날짜, 이미지 섹션 구분 목적)
enum DateAndGallerySection: Int, CaseIterable {
    case date
    case gallery
}
