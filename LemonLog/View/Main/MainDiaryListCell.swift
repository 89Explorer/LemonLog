//
//  MainDiaryListCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/28/25.
//

import UIKit


final class MainDiaryListCell: UICollectionViewCell {
    
    
    // MARK: - Closure
    var onTappedSetting: ((EmotionDiaryModel) -> Void)?
    
    
    // MARK: - Data
    private var selectedDiary: EmotionDiaryModel?
    
    
    
    // MARK: - Reuse Identifier
    static let reuseIdentifier: String = "MainDiaryListCell"
    
    
    
    // MARK: - Placeholder 뷰 (데이터 없을 때)
    private let placeholderView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let label = UILabel()
        label.text = "아직 작성하신 감정일기가 없어요.\n오늘의 기록을 남겨보세요!"
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    
    
    // MARK: - UI Components
    private let dayLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 18)
        lbl.textColor = .label
        return lbl
    }()
    
    private let weekLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let emojiImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    
    
    // MARK: 이미지 CollectionView
    private var diaryImageCollectionView: UICollectionView!
    private var imageCollectionHeightConstraint: NSLayoutConstraint?
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .systemYellow
        pc.currentPageIndicatorTintColor = .black
        pc.hidesForSinglePage = true
        return pc
    }()
    
    
    // MARK: 텍스트뷰 (패딩 조절 적용)
    private let diaryContentTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = .black
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        
        // 🔥 내부 패딩 제거 및 커스텀
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tv.textContainer.lineFragmentPadding = 0
        
        return tv
    }()
    
    
    private let settingButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let settingImage = UIImage(systemName: "ellipsis", withConfiguration: config)
        button.setImage(settingImage, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    
    private let bottomSeparatorView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.lightGray
        return v
    }()
    
    
    private let topSeparatorView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.lightGray
        return v
    }()
    
    
    // MARK: - Data
    private var images: [UIImage] = []
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupGalleryCollectionView()
        setupCardStyle()
        setupUI()
        setupLayout()
        
        settingButton.addTarget(self, action: #selector(didTappedSetting), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - Action Method
extension MainDiaryListCell {
    
    @objc private func didTappedSetting() {
        onTappedSetting?(selectedDiary!)
    }
}


// MARK: - Extension (카드형 디자인 적용)
extension MainDiaryListCell {
    private func setupCardStyle() {
        
        // contentView layoutInset을 주기 위해 내부 래퍼뷰 생성
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = .clear
        
        //layer.cornerRadius = 16
        //layer.masksToBounds = false
        
        // 카드 스타일 그림자
        //layer.shadowColor = UIColor.black.cgColor
        //layer.shadowOpacity = 0.08
        //layer.shadowRadius = 8
        //layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // 셀 내부 내용 배경
        backgroundColor = .clear
        layer.cornerCurve = .continuous
        
        // 외곽선 설정
        //layer.borderColor = UIColor.systemGray.cgColor
        //layer.borderWidth = 1.0
    }
}



// MARK: - Extension (UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout)
extension MainDiaryListCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func setupGalleryCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        diaryImageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        diaryImageCollectionView.isPagingEnabled = true
        diaryImageCollectionView.showsHorizontalScrollIndicator = false
        diaryImageCollectionView.backgroundColor = .clear
        
        diaryImageCollectionView.layer.cornerRadius = 24
        diaryImageCollectionView.layer.borderWidth = 1
        diaryImageCollectionView.layer.borderColor = UIColor.systemGray.cgColor
        diaryImageCollectionView.clipsToBounds = true
        
        diaryImageCollectionView.delegate = self
        diaryImageCollectionView.dataSource = self
        
        diaryImageCollectionView.register(UICollectionViewCell.self,
                                          forCellWithReuseIdentifier: "ImageCell")
        
        diaryImageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell",
                                                      for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let iv = UIImageView(image: images[indexPath.item])
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.frame = cell.bounds
        
        cell.contentView.addSubview(iv)
        
        return cell
    }
    
    
    // MARK: Size
    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAt: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = page
    }
}



// MARK: - Extension (UI 배치 및 레이아웃)
extension MainDiaryListCell {
    
    private func setupUI() {
        contentView.addSubview(topSeparatorView)
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(weekLabel)
        contentView.addSubview(emojiImageView)
        contentView.addSubview(settingButton)
        
        contentView.addSubview(diaryImageCollectionView)
        contentView.addSubview(pageControl)
        contentView.addSubview(diaryContentTextView)
        
        contentView.addSubview(placeholderView)
        
        
        contentView.addSubview(bottomSeparatorView)
    }
    
    
    private func setupLayout() {
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        weekLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiImageView.translatesAutoresizingMaskIntoConstraints = false
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        diaryContentTextView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            topSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topSeparatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 0.2)
        ])
        
        
        NSLayoutConstraint.activate([
            
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            weekLabel.centerYAnchor.constraint(equalTo: dayLabel.centerYAnchor),
            weekLabel.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 6),
            
            emojiImageView.centerYAnchor.constraint(equalTo: dayLabel.centerYAnchor),
            emojiImageView.leadingAnchor.constraint(equalTo: weekLabel.trailingAnchor, constant: 16),
            emojiImageView.widthAnchor.constraint(equalToConstant: 28),
            emojiImageView.heightAnchor.constraint(equalToConstant: 28),
            
            settingButton.centerYAnchor.constraint(equalTo: dayLabel.centerYAnchor),
            settingButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        
        NSLayoutConstraint.activate([
            diaryImageCollectionView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 12),
            diaryImageCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            diaryImageCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
        ])
        
        imageCollectionHeightConstraint = diaryImageCollectionView.heightAnchor.constraint(equalToConstant: 260)
        imageCollectionHeightConstraint?.isActive = true
        
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: diaryImageCollectionView.bottomAnchor, constant: -12),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            diaryContentTextView.topAnchor.constraint(equalTo: diaryImageCollectionView.bottomAnchor, constant: 12),
            diaryContentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            diaryContentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            diaryContentTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        NSLayoutConstraint.activate([
            bottomSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSeparatorView.topAnchor.constraint(equalTo: diaryContentTextView.bottomAnchor, constant: 4),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.2)
        ])
    }
}


// MARK: - Extension (configure(with:))
extension MainDiaryListCell {
    
    func configure(with diary: EmotionDiaryModel?) {
        
        guard let diary else {
            configurePlaceholder()
            return
        }
        
        placeholderView.isHidden = true
        showContentViews()
        
        self.selectedDiary = diary
        
        // 날짜/요일
        let df = DateFormatter()
        df.dateFormat = "d일"
        dayLabel.text = df.string(from: diary.createdAt)
        
        df.dateFormat = "E요일"
        weekLabel.text = df.string(from: diary.createdAt)
        
        //emojiImageView.image = UIImage(named: diary.emotion.)
        
        
        // 이미지 처리
        self.images = diary.images ?? []
        pageControl.numberOfPages = images.count
        
        if images.isEmpty {
            imageCollectionHeightConstraint?.constant = 0
            pageControl.isHidden = true
        } else {
            imageCollectionHeightConstraint?.constant = 260
            pageControl.isHidden = false
        }
        
        diaryImageCollectionView.reloadData()
        
        
        // 내용
        //diaryContentTextView.text = diary.totalText
    }
    
    func configurePlaceholder() {
        placeholderView.isHidden = false
        hideContentViews()
    }
    
    private func hideContentViews() {
        dayLabel.isHidden = true
        weekLabel.isHidden = true
        emojiImageView.isHidden = true
        diaryImageCollectionView.isHidden = true
        pageControl.isHidden = true
        diaryContentTextView.isHidden = true
        settingButton.isHidden = true
        bottomSeparatorView.isHidden = true
    }
    
    private func showContentViews() {
        dayLabel.isHidden = false
        weekLabel.isHidden = false
        emojiImageView.isHidden = false
        diaryImageCollectionView.isHidden = false
        diaryContentTextView.isHidden = false
        settingButton.isHidden = false
        bottomSeparatorView.isHidden = false
    }
}
