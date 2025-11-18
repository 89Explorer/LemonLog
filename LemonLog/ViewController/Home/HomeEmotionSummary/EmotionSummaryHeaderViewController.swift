//
//  EmotionSummaryHeaderViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/19/25.
//

import UIKit

class EmotionSummaryHeaderViewController: UIViewController {

    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigation()
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .pastelLemon
        
        
        
    }
        
}


// MARK: ✅ Extension -> 네비게이션아이템 설정
extension EmotionSummaryHeaderViewController {
    
    private func configureNavigation() {
        navigationItem.hidesBackButton = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .black)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        let backBarButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(didTappedBack))
        backBarButton.tintColor = .black
        navigationItem.leftBarButtonItem = backBarButton
    }
    

    @objc private func didTappedBack() {
        navigationController?.popViewController(animated: true)
    }
}
