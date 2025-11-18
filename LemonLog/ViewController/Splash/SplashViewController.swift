//
//  SplashViewController.swift
//  LemonLog
//
//  Created by 권정근 on 10/15/25.
//

import UIKit

final class SplashViewController: UIViewController {
    
    
    // MARK: ✅ ViewModel
    private let homeVM: HomeViewModel
    
    
    // MARK: ✅ View
    private var logoImageView: UIImageView = UIImageView()
    
    
    // MARK: ✅ UI
    init(homeViewModel: HomeViewModel) {
        self.homeVM = homeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
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
        view.backgroundColor = .secondarySystemBackground
        //view.backgroundColor = UIColor(named: "VanillaCream")
        
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
        let homeVC = HomeViewController(viewModel: homeVM)
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.modalTransitionStyle = .crossDissolve
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
}
