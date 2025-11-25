//
//  SummaryDiaryCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/24/25.
//


import UIKit


final class SummaryDiaryCell: UITableViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "SummaryDiaryCell"
    

    // MARK: ✅ UI
    private let dateLabel: UILabel = UILabel()
    private let emojiImageView: UIImageView = UIImageView()
    private let separatorView: UIView = UIView()

    private let situationLabel: UILabel = UILabel()
    private let imagesContainer: UIStackView = UIStackView()

    
    // left = date + separator + emoji
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
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imagesContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        // CARD VIEW ----------------------------------------------------
        let cardView = UIView()
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
        
        // DATE LABEL -----------------------------------------
        dateLabel.font = .systemFont(ofSize: 16, weight: .bold)
        dateLabel.textColor = .black
        dateLabel.textAlignment = .center
        
        // SEPARATOR VIEW -------------------------------------
        separatorView.backgroundColor = .lightGray
        
        // EMOJI IMAGEVIEW ------------------------------------
        emojiImageView.contentMode = .scaleAspectFit
        
        // LEFT STRUCTURE -------------------------------------
        leftContainer.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(leftContainer)
        
        leftContainer.addSubview(leftStack)
        
        NSLayoutConstraint.activate([
            leftContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            leftContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            leftContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8),
            leftContainer.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.2),
            
            // Center leftStack inside leftContainer
            leftStack.centerXAnchor.constraint(equalTo: leftContainer.centerXAnchor),
            leftStack.centerYAnchor.constraint(equalTo: leftContainer.centerYAnchor),
            leftStack.widthAnchor.constraint(equalTo: leftContainer.widthAnchor, multiplier: 0.75),
        ])
        
        // leftStack 구성 -------------------------------------
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
        
        // SITUATION LABEL ------------------------------------
        situationLabel.font = .systemFont(ofSize: 12, weight: .regular)
        situationLabel.textColor = .black
        situationLabel.textAlignment = .left
        situationLabel.numberOfLines = 3
        
        
        // IMAGES CONTAINER -----------------------------------
        imagesContainer.axis = .vertical
        imagesContainer.spacing = 4
        imagesContainer.distribution = .fillEqually

        // RIGHT STRUCTURE ------------------------------------
        cardView.addSubview(situationLabel)
        cardView.addSubview(imagesContainer)
    
        situationLabel.translatesAutoresizingMaskIntoConstraints = false
        imagesContainer.translatesAutoresizingMaskIntoConstraints = false 
        
        
        NSLayoutConstraint.activate([
            
            imagesContainer.leadingAnchor.constraint(equalTo: leftContainer.trailingAnchor, constant: 8),
            imagesContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            imagesContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            imagesContainer.heightAnchor.constraint(equalTo: cardView.heightAnchor, multiplier: 0.55),
            
            situationLabel.leadingAnchor.constraint(equalTo: imagesContainer.leadingAnchor, constant: 0),
            situationLabel.topAnchor.constraint(equalTo: imagesContainer.bottomAnchor, constant: 8),
            situationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            situationLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)

        ])
    }
    

    // MARK: ✅ Bind Data
    func configure(with diary: EmotionDiaryModel) {
        configureDate(diary.createdAt)
        situationLabel.text = diary.summaryText
        emojiImageView.image = UIImage(named: diary.emotion)
        configureImages(diary.images ?? [])
    }
    
    
    // MARK: ✅ Configure Date Format
    private func configureDate(_ date: Date) {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        dateLabel.text = f.string(from: date)
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

