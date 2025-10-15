//
//  SplashViewController.swift
//  LemonLog
//
//  Created by 권정근 on 10/15/25.
//

import UIKit

final class SplashViewController: UIViewController {
    
    
    // MARK: ✅ View
    private var logoImageView: UIImageView = UIImageView()
    
    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 부드러운 페이드 인 효과
        UIView.animate(withDuration: 0.75, animations: {
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.moveToMain()
            }
        }
    }
    
    
    // MARK: ✅ Method
    private func setupUI() {
        view.backgroundColor = UIColor.white
        
        logoImageView = UIImageView(image: UIImage(named: "lemon"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func moveToMain() {
        let mainVC = ViewController()
        mainVC.modalTransitionStyle = .crossDissolve
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true)
    }
}
