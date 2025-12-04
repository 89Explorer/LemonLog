//
//  SplashViewController.swift
//  LemonLog
//
//  Created by 권정근 on 10/15/25.
//

import UIKit

final class SplashViewController: UIViewController {
    
    
    // MARK: ✅ ViewModel
//    private let homeVM: HomeViewModel
    
    // ▶️ 새롭게 작성한 ViewModel ◀️
    private let mainHomeVM: MainHomeViewModel
    
    
    // MARK: ✅ View
    private var logoImageView: UIImageView = UIImageView()
    
    
    // MARK: ✅ UI
//    init(homeViewModel: HomeViewModel) {
//        self.homeVM = homeViewModel
//        super.init(nibName: nil, bundle: nil)
//    }
    
    // ▶️ 새롭게 작성한 Init ◀️
    init(mainHomeVM: MainHomeViewModel) {
        self.mainHomeVM = mainHomeVM
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
    
    
    
    // MARK: moveToMain() - 스플래쉬 화면은 닫고, 루트뷰를 MainViewController로 변경
    private func moveToMain() {
//        let mainVC = MainViewController(homeVM: homeVM)
//        let naviVC = UINavigationController(rootViewController: mainVC)
//        naviVC.modalPresentationStyle = .fullScreen
        
        let newMainVC = MainHomeViewController(viewModel: mainHomeVM)
        
        // 현재 윈도우 가져오기 (iOS 13+ 대응)
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else { return }

        // ✅ 스플래시 대신 메인 네비게이션 컨트롤러를 루트로 교체
        window.rootViewController = newMainVC

        // ✅ 자연스러운 전환을 위한 크로스 디졸브 애니메이션
        UIView.transition(with: window,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }

}
