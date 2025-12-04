//
//  DetailDiaryViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/25/25.
//

import UIKit


final class DetailDiaryViewController: UIViewController {
    
    
    // MARK: ✅ NSLayoutConstraint -> 이미지뷰
    private var imagesContainerHeightConstraint: NSLayoutConstraint?
    
    
    // MARK: ✅ Data
    private let diary: EmotionDiaryModel
    
    
    // MARK: ✅ UI
    private let imagesContainer: UIStackView = UIStackView()
    
    private let dateLabel: UILabel = UILabel()
    private let emojiImageView: UIImageView = UIImageView()
    private let separatorView: UIView = UIView()
    private let middleStack: UIStackView = UIStackView()
    
    private let contentLabel: UILabel = UILabel()
    
    
    // MARK: ✅ Init
    init(from diary: EmotionDiaryModel) {
        self.diary = diary
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configure(with: diary)
        configureNavigation()
        configureTapGesutre()
    }
    
    
    // MARK: ✅ Bind Data
    func configure(with diary: EmotionDiaryModel) {
        configureDate(diary.createdAt)
        contentLabel.text = diary.totalText
        emojiImageView.image = UIImage(named: diary.emotion)
        configureImages(diary.images ?? [])
        updateImagesConstraints()
    }
    
    
    // MARK: ✅ Configure Date Format
    private func configureDate(_ date: Date) {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        dateLabel.text = f.string(from: date)
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .pastelLemon
       
        // IMAGES CONTAINER -----------------------------------
        imagesContainer.axis = .vertical
        imagesContainer.spacing = 4
        imagesContainer.distribution = .fillEqually
        imagesContainer.isUserInteractionEnabled = true
        imagesContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // MIDDLE STACKVIEW -----------------------------------
        middleStack.axis = .horizontal
        middleStack.spacing = 8
        middleStack.distribution = .fill
        middleStack.translatesAutoresizingMaskIntoConstraints = false
        
        // DATE LABEL -----------------------------------------
        dateLabel.font = .systemFont(ofSize: 24, weight: .bold)
        dateLabel.textColor = .black
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // SEPARATOR VIEW -------------------------------------
        separatorView.backgroundColor = .lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        // EMOJI IMAGEVIEW ------------------------------------
        emojiImageView.contentMode = .scaleAspectFit
        emojiImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // CONTENT LABEL --------------------------------------
        contentLabel.font = .systemFont(ofSize: 16, weight: .regular)
        contentLabel.textColor = .black
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.lineBreakStrategy = .hangulWordPriority
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imagesContainer)
        view.addSubview(dateLabel)
        view.addSubview(separatorView)
        view.addSubview(emojiImageView)
        view.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            imagesContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imagesContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            imagesContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            //imagesContainer.heightAnchor.constraint(equalToConstant: 320),
        
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: imagesContainer.bottomAnchor, constant: 12),
            dateLabel.heightAnchor.constraint(equalToConstant: 40),
            
            separatorView.centerXAnchor.constraint(equalTo: dateLabel.centerXAnchor),
            separatorView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            separatorView.widthAnchor.constraint(equalToConstant: 2),
            separatorView.heightAnchor.constraint(equalToConstant: 20),
            
            emojiImageView.centerXAnchor.constraint(equalTo: dateLabel.centerXAnchor),
            emojiImageView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 8),
            emojiImageView.widthAnchor.constraint(equalToConstant: 28),
            emojiImageView.heightAnchor.constraint(equalTo: emojiImageView.widthAnchor),
    
            contentLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            contentLabel.topAnchor.constraint(equalTo: emojiImageView.bottomAnchor, constant: 12),
        
        ])
    
        imagesContainerHeightConstraint = imagesContainer.heightAnchor.constraint(equalToConstant: 0)
        imagesContainerHeightConstraint?.isActive = true
    
    }
    
    private func configureTapGesutre(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTappedImageContainer))
        imagesContainer.addGestureRecognizer(tap)
        
    }
    
    @objc private func didTappedImageContainer() {
        guard let diaryImages = diary.images else { return }
        let previewVC = PhotoPreviewViewController(images: diaryImages, startIndex: 0)
        self.present(previewVC, animated: true)
    }
    
}



// MARK: ✅ Extension -> 이미지 스택뷰 관련 함수
extension DetailDiaryViewController {
    
    
    private func updateImagesConstraints() {
        guard let imageList = diary.images else {
            // 이미지 배열 자체가 nil이면
            imagesContainerHeightConstraint?.constant = 0
            imagesContainer.isHidden = true
            return
        }
        
        if imageList.isEmpty {
            // 이미지 없음
            imagesContainerHeightConstraint?.constant = 0
            imagesContainer.isHidden = true
        } else {
            // 이미지 있음
            imagesContainerHeightConstraint?.constant = 320
            imagesContainer.isHidden = false
        }

        view.layoutIfNeeded()
    }
    
    
    // MARK: ✅ Configure Images - 스택뷰로 이미지 갯수 따라 그리드 설정
    private func configureImages(_ images: [UIImage]) {
        
        imagesContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let maxDisplay = 3
        let display = Array(images.prefix(maxDisplay))
        let extraCount = images.count - maxDisplay
        
        switch display.count {

        case 1:
            imagesContainer.addArrangedSubview(makeImageView(display[0]))

        case 2:
            let vStack = UIStackView()
            vStack.axis = .vertical
            vStack.distribution = .fillEqually
            vStack.spacing = 4

            vStack.addArrangedSubview(makeImageView(display[0]))
            vStack.addArrangedSubview(makeImageView(display[1]))

            imagesContainer.addArrangedSubview(vStack)

        case 3:
            let top = makeImageView(display[0])

            let bottom = UIStackView()
            bottom.axis = .horizontal
            bottom.spacing = 4
            bottom.distribution = .fillEqually
            bottom.addArrangedSubview(makeImageView(display[1]))
            bottom.addArrangedSubview(makeImageView(display[2]))

            let v = UIStackView(arrangedSubviews: [top, bottom])
            v.axis = .vertical
            v.spacing = 4
            v.distribution = .fillEqually

            imagesContainer.addArrangedSubview(v)

        default:
            break
        }

        if extraCount > 0 {
            addMoreOverlay(extraCount: extraCount)
        }
    }

    
    // MARK: ✅ +N Overlay
    private func addMoreOverlay(extraCount: Int) {

        guard let lastView = imagesContainer.arrangedSubviews.last else { return }

        let overlay = UILabel()
        overlay.text = "+\(extraCount)"
        overlay.textColor = .white
        overlay.font = .boldSystemFont(ofSize: 20)
        overlay.textAlignment = .center
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        overlay.translatesAutoresizingMaskIntoConstraints = false

        lastView.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: lastView.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: lastView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: lastView.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: lastView.bottomAnchor)
        ])
    }
    
    // MARK: ✅ Make ImageView
    private func makeImageView(_ image: UIImage) -> UIImageView {
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }
}


// MARK: ✅ Extension -> 네비게이션아이템 설정
extension DetailDiaryViewController {
    
    private func configureNavigation() {
        navigationItem.hidesBackButton = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        //let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        let backImage = UIImage(systemName: "xmark", withConfiguration: config)
        
        let backBarButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(didTappedBack))
        backBarButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = backBarButton
        
        let settingImage = UIImage(systemName: "ellipsis", withConfiguration: config)
        let settingButton = UIBarButtonItem(image: settingImage, style: .plain, target: self, action: #selector(didTappedSetting))
        settingButton.tintColor = .black
        
        navigationItem.rightBarButtonItem = settingButton
        
    }
    
    @objc private func didTappedBack() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func didTappedSetting() {
        print("눌렸다.")
        showSettingActionSheet()
    }
}



// MARK: ✅ Extension - showSettingActionSheet 함수
extension DetailDiaryViewController {
    
    func showSettingActionSheet() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 수정
        let editAction = UIAlertAction(
            title: NSLocalizedString("edit_action", comment: "Edit diary"),
            style: .default
        ) { [weak self] _ in
            self?.handleEdit()
        }
        alert.addAction(editAction)
        
        
        // 삭제
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete_action", comment: "Delete diary"),
            style: .destructive
        ) { [weak self] _ in
            self?.showDeleteConfirmation()
        }
        alert.addAction(deleteAction)
        
        
        // 취소
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel_action", comment: "Cancel action"),
            style: .cancel,
            handler: nil
        )
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
    
    
    // 삭제 버튼을 눌렀을 때 확인창 여는 함수
    private func showDeleteConfirmation() {

        let title = NSLocalizedString("delete_confirm_title", comment: "Delete diary confirmation")

        let message = NSLocalizedString("delete_confirm_message", comment: "Delete diary confirmation")

        let confirmAlert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let confirmDelete = UIAlertAction(
            title: NSLocalizedString("delete_action", comment: "Confirm delete"),
            style: .destructive
        ) { [weak self] _ in
            self?.handleDelete()
        }
        confirmAlert.addAction(confirmDelete)

        let cancel = UIAlertAction(
            title: NSLocalizedString("cancel_action", comment: "Cancel"),
            style: .cancel,
            handler: nil
        )
        confirmAlert.addAction(cancel)

        present(confirmAlert, animated: true)
    }
    
    private func handleDelete() {
        // 여기서 CoreData 삭제 또는 ViewModel 호출 등 처리
        print("삭제 실행")
        DiaryStore.shared.delete(id: diary.id.uuidString)
        navigationController?.dismiss(animated: true)
        ToastManager.show(.deleted, position: .center)
    }
    
    private func handleEdit() {
        let selectedDiary = diary
        let editVC = DiaryEditorViewController(mode: .edit(selectedDiary))
        let nav = UINavigationController(rootViewController: editVC)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .coverVertical
        
        // 상위 presentingViewController를 가져옴
        guard let presenter = self.presentingViewController else {
            return
        }
        
        // 1) DetailDiaryVC dismiss
        self.dismiss(animated: false) {
            // 2) DetailDiaryVC를 띄운 쪽에서 present
            presenter.present(nav, animated: true)
        }
    
    }

}

