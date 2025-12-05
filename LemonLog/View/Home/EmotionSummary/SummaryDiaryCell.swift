//
//  SummaryDiaryCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/24/25.
//


import UIKit


final class SummaryDiaryCell: UITableViewCell {
    
    
    // MARK: ✅ Reuse Identifier
    static let reuseIdentifier: String = "SummaryDiaryCell"
    
    
    // MARK: ✅ Constraints
    private var imagesContainerHeightConstraint: NSLayoutConstraint?
    private var situationTopWithImagesConstraint: NSLayoutConstraint?
    private var situationTopWithoutImagesConstraint: NSLayoutConstraint?
    
    
    // MARK: ✅ UI
    private let cardView: UIView = UIView()
    
    private let dateLabel = UILabel()
    private let emojiImageView = UIImageView()
    private let separatorView = UIView()
    private let situationLabel = TopAlignedLabel()
    private let imagesContainer = UIStackView()
    
    private let leftContainer = UIView()
    
    private let leftStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    
    // MARK: ✅ Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imagesContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // ▸ CardView
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 12
        cardView.clipsToBounds = true
        
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        
        // ▸ Left Section: Date + Separator + Emoji
        dateLabel.font = .systemFont(ofSize: 16, weight: .bold)
        dateLabel.textAlignment = .center
        
        separatorView.backgroundColor = .lightGray
        
        emojiImageView.contentMode = .scaleAspectFit
        
        leftContainer.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(leftContainer)
        leftContainer.addSubview(leftStack)
        
        NSLayoutConstraint.activate([
            leftContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            leftContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            leftContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8),
            leftContainer.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.2),
            
            leftStack.centerXAnchor.constraint(equalTo: leftContainer.centerXAnchor),
            leftStack.centerYAnchor.constraint(equalTo: leftContainer.centerYAnchor),
            leftStack.widthAnchor.constraint(equalTo: leftContainer.widthAnchor, multiplier: 0.75)
        ])
        
        leftStack.addArrangedSubview(dateLabel)
        leftStack.addArrangedSubview(separatorView)
        leftStack.addArrangedSubview(emojiImageView)
        
        NSLayoutConstraint.activate([
            dateLabel.heightAnchor.constraint(equalTo: leftContainer.heightAnchor, multiplier: 0.2),
            emojiImageView.heightAnchor.constraint(equalTo: leftContainer.heightAnchor, multiplier: 0.2),
            emojiImageView.widthAnchor.constraint(equalTo: emojiImageView.heightAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 2.5),
            separatorView.widthAnchor.constraint(equalTo: leftStack.widthAnchor, multiplier: 0.65)
        ])
        
        
        // ▸ ImagesContainer
        imagesContainer.axis = .vertical
        imagesContainer.spacing = 4
        imagesContainer.distribution = .fillEqually
        
        // ▸ SituationLabel
        situationLabel.font = .systemFont(ofSize: 14)
        situationLabel.numberOfLines = 3
        
        
        cardView.addSubview(imagesContainer)
        cardView.addSubview(situationLabel)
        
        imagesContainer.translatesAutoresizingMaskIntoConstraints = false
        situationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        // ▸ Height Constraint for imagesContainer (fixed)
        imagesContainerHeightConstraint = imagesContainer.heightAnchor.constraint(equalToConstant: 0)
        
        // ▸ Two possible top constraints for situationLabel
        situationTopWithImagesConstraint =
            situationLabel.topAnchor.constraint(equalTo: imagesContainer.bottomAnchor, constant: 8)
        
        situationTopWithoutImagesConstraint =
            situationLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8)
        
        
        NSLayoutConstraint.activate([
            imagesContainer.leadingAnchor.constraint(equalTo: leftContainer.trailingAnchor, constant: 8),
            imagesContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            imagesContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            imagesContainerHeightConstraint!,
            
            // 기본은 이미지 없는 상태로 시작
            situationTopWithoutImagesConstraint!,
            
            situationLabel.leadingAnchor.constraint(equalTo: imagesContainer.leadingAnchor),
            situationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            situationLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])
    }
    
    
    // MARK: ✅ Bind Data
    func configure(with diary: EmotionDiaryModel) {
        configureDate(diary.createdAt)
        emotionToUI(diary)
        
        let images = diary.images ?? []
        configureImages(images)
        updateImagesVisibility(images.count)
    }
    
    
    private func emotionToUI(_ diary: EmotionDiaryModel) {
        //situationLabel.text = diary.summaryText
        //emojiImageView.image = UIImage(named: diary.emotion)
    }
    
    
    // MARK: ✅ Date
    private func configureDate(_ date: Date) {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        dateLabel.text = f.string(from: date)
    }
    
    
    // MARK: ✅ Images Rendering
    private func configureImages(_ images: [UIImage]) {
        imagesContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let maxDisplay = 3
        let display = Array(images.prefix(maxDisplay))
        let extra = images.count - maxDisplay
        
        switch display.count {
        case 1:
            imagesContainer.addArrangedSubview(makeImageView(display[0]))
        case 2:
            let v = UIStackView(arrangedSubviews: [
                makeImageView(display[0]), makeImageView(display[1])
            ])
            v.axis = .vertical
            v.distribution = .fillEqually
            v.spacing = 4
            imagesContainer.addArrangedSubview(v)
        case 3:
            let top = makeImageView(display[0])
            let bottom = UIStackView(arrangedSubviews: [
                makeImageView(display[1]), makeImageView(display[2])
            ])
            bottom.axis = .horizontal
            bottom.distribution = .fillEqually
            bottom.spacing = 4
            
            let v = UIStackView(arrangedSubviews: [top, bottom])
            v.axis = .vertical
            v.distribution = .fillEqually
            v.spacing = 4
            imagesContainer.addArrangedSubview(v)
        default:
            break
        }
        
        if extra > 0 { addMoreOverlay(extra) }
    }
    
    
    // MARK: ✅ Visibility Toggle
    private func updateImagesVisibility(_ count: Int) {
        if count == 0 {
            imagesContainerHeightConstraint?.constant = 0
            imagesContainer.isHidden = true
            
            situationTopWithImagesConstraint?.isActive = false
            situationTopWithoutImagesConstraint?.isActive = true
            
        } else {
            imagesContainerHeightConstraint?.constant = 112
            imagesContainer.isHidden = false
            
            situationTopWithoutImagesConstraint?.isActive = false
            situationTopWithImagesConstraint?.isActive = true
        }
    }
    
    
    // MARK: ✅ Overlay
    private func addMoreOverlay(_ extra: Int) {
        guard let last = imagesContainer.arrangedSubviews.last else { return }
        
        let overlay = UILabel()
        overlay.text = "+\(extra)"
        overlay.textColor = .white
        overlay.font = .boldSystemFont(ofSize: 20)
        overlay.textAlignment = .center
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        last.addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: last.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: last.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: last.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: last.bottomAnchor)
        ])
    }
    
    
    // MARK: ✅ Helper
    private func makeImageView(_ image: UIImage) -> UIImageView {
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }
}
