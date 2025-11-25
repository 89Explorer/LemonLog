//
//  HomeEmotionSummaryViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/21/25.
//

import UIKit

class HomeEmotionSummaryViewController: UIViewController {
    
    
    // MARK: ✅ Data
    private var diariesFromWeek: [EmotionDiaryModel] = []
    
    
    // MARK: ✅ UI
    private let tableView: UITableView = UITableView()

    
    // MARK: ✅ Init
    init(diariesFromWeek: [EmotionDiaryModel]) {
        self.diariesFromWeek = diariesFromWeek
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let baseDate = diariesFromWeek.first?.createdAt else {
            diariesFromWeek = []
            tableView.reloadData()
            return
        }
        
        diariesFromWeek = DiaryStore.shared.diaries(inWeekOf: baseDate)
        tableView.reloadData()
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .pastelLemon
        
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(SummaryDiaryCell.self, forCellReuseIdentifier: SummaryDiaryCell.reuseIdentifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}


// MARK: ✅ Extension -> UITableViewDataSource
extension HomeEmotionSummaryViewController: UITableViewDataSource, UITableViewDelegate {
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        diariesFromWeek.count
    }
    
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SummaryDiaryCell.reuseIdentifier,
            for: indexPath
        ) as? SummaryDiaryCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.configure(with: diariesFromWeek[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = diariesFromWeek[indexPath.row]
        print("selectedItem: \(selectedItem.summaryText)")
        
        let detailVC = DetailDiaryViewController(from: selectedItem)
        let naviDetailVC = UINavigationController(rootViewController: detailVC)
        naviDetailVC.modalPresentationStyle = .fullScreen
        naviDetailVC.modalTransitionStyle = .coverVertical
        self.present(naviDetailVC, animated: true)
    }

}



// MARK: ✅ Extension -> NavigationController (네비게이션 설정)
extension HomeEmotionSummaryViewController {
    
    private func configureNavigation() {
        
        navigationItem.hidesBackButton = true
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
    
        let iconImage = UIImage(systemName: "chevron.backward", withConfiguration: iconConfig)
        
        let backButton = UIButton(type: .system)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        backButton.setImage(iconImage, for: .normal)

        let barButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = barButtonItem
        
    }
    
    @objc private func didTapDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
}
