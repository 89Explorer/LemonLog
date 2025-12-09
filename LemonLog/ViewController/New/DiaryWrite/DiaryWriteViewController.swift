//
//  DiaryWriteViewController.swift
//  LemonLog
//
//  Created by 권정근 on 12/6/25.
//


import UIKit
import Combine


final class DiaryWriteViewController: UIViewController {
    
    
    // MARK: ✅ ViewModel
    private var diaryWriteVM: DiaryWriteViewModel
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ Data
    // 총 스텝 갯수 확인
    private let steps = DiaryWriteStep.allCases
    
    private var currentStepIndex: Int = 0 {
        didSet {
            updateUIForStep(index: currentStepIndex)
        }
    }
    
    
    // MARK: ✅ UI
    private lazy var stepProgressView: StepProgressView = StepProgressView(total: steps.count)
    private var writeCollectionView: UICollectionView!
    private lazy var pagingControlView: PagingControlView = PagingControlView(total: steps.count)
    
    
    // MARK: ✅ Initialization
    init(diaryWriteVM: DiaryWriteViewModel) {
        self.diaryWriteVM = diaryWriteVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: ✅ Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .vanillaCream
        setupNavigationBar()
        setupCollectionView()
        setupLayout()
        setupPagingControlCallbacks()
        updateUIForStep(index: 0)
        bindingsVM()
    }
    
    
    // MARK: ✅ bindings
    private func bindingsVM() {
        
        // 감정 선택 유효성 검사를 통해 에러메세지 구독
        diaryWriteVM.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showAlert(message: message)
            }
            .store(in: &cancellables)
        
        diaryWriteVM.$canSelectEmotion
            .sink { [weak self] allowed in
                self?.updateEmotionSelectionEnabled(allowed)
            }
            .store(in: &cancellables)
    }
    
    
    private func updateEmotionSelectionEnabled(_ allowed: Bool) {
        // 첫 번째 스텝(감정 선택) 페이지가 화면에 있을 때만 반영
        let indexPath = IndexPath(item: 0, section: 0)
        
        guard let cell = writeCollectionView.cellForItem(at: indexPath) as? EmotionStepCell else {
            return
        }

        cell.updateSelectEnabled(allowed)
    }
    
}


// MARK: ✅ writeCollectionView 설정 + 페이징 기능 적용
private extension DiaryWriteViewController {

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        writeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        writeCollectionView.isPagingEnabled = true
        writeCollectionView.showsHorizontalScrollIndicator = false
        writeCollectionView.backgroundColor = .clear

        writeCollectionView.dataSource = self
        writeCollectionView.delegate = self

        writeCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        writeCollectionView.register(EmotionStepCell.self, forCellWithReuseIdentifier: EmotionStepCell.reuseIdentifier)
        writeCollectionView.register(DiaryWriteContentCell.self, forCellWithReuseIdentifier: DiaryWriteContentCell.reuseIdentifier)
        
        writeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(writeCollectionView)
    }
}


// MARK: ✅ AutoLayout 제약조건 설정
private extension DiaryWriteViewController {

    func setupLayout() {

        // StepProgressView
        stepProgressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stepProgressView)

        // PagingControlView
        pagingControlView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pagingControlView)

        NSLayoutConstraint.activate([

            // StepProgressView
            stepProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            stepProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stepProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    
            // writeCollectionView
            writeCollectionView.topAnchor.constraint(equalTo: stepProgressView.bottomAnchor, constant: 20),
            writeCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            writeCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            writeCollectionView.bottomAnchor.constraint(equalTo: pagingControlView.topAnchor, constant: -20),

            // PagingControlView
            pagingControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingControlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingControlView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            pagingControlView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}


// MARK: ✅ 스와이프 + 버튼으로 페이징 이동 테스트 기능 구현
// Prev / Next 버튼 콜백 처리
private extension DiaryWriteViewController {

    func setupPagingControlCallbacks() {

        pagingControlView.onTapPrev = { [weak self] in
            guard let self else { return }
            let prev = max(self.currentStepIndex - 1, 0)
            self.scrollTo(step: prev)
        }

        pagingControlView.onTapNext = { [weak self] in
            guard let self else { return }
            
            let currentStep = self.steps[self.currentStepIndex]
            
            // 먼저 현재 단계에서 다음 단계로 넘어갈 수 있는지를 ViewModel에 검토 요청
            let allowed = self.diaryWriteVM.canProceedToNextStep(currentStep)
            
            guard allowed else {
                return
            }
            
            let next = min(self.currentStepIndex + 1, self.steps.count - 1)
            self.scrollTo(step: next)
        }
    }

    func scrollTo(step: Int) {
        let indexPath = IndexPath(item: step, section: 0)
        writeCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currentStepIndex = step
    }
}

// MARK: ✅ Extension (스와이프 시 index 업데이트)
extension DiaryWriteViewController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int(scrollView.contentOffset.x / pageWidth)
        let targetPage = Int(targetContentOffset.pointee.x / pageWidth)

        // → 방향으로 스와이프
        if targetPage > currentPage {
            let currentStep = steps[currentPage]
            if !diaryWriteVM.canProceedToNextStep(currentStep){
                targetContentOffset.pointee.x = CGFloat(currentPage) * pageWidth
                //showStepError(step: currentStep)
            }
        }
    }

}


// MARK: ✅ Extension (컬렉션뷰 기본 콘텐츠 설정 (배경색으로 테스트))
extension DiaryWriteViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return steps.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let step = steps[indexPath.item]
        let title = steps[indexPath.item].titleKey
        let guide = steps[indexPath.item].guideKey
        let placeholder1 = steps[indexPath.item].placeholder1Key
        let placeholder2 = steps[indexPath.item].placeholder2Key
        
        switch step {
        case .emotion:
            // 첫 페이지는 EmotionStepCell
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmotionStepCell.reuseIdentifier,
                for: indexPath
            ) as! EmotionStepCell
            
            // configure로 데이터 전달
            cell.configure(
                title: NSLocalizedString(title, comment: ""),
                guide: NSLocalizedString(guide, comment: ""),
                categories: EmotionCategory.allCases.filter { $0 != .none }
            )
            
            cell.onEmotionSelected = { [weak self] category, subs in
                print("선택된 감정: \(category), 세부감정: \(subs)")
                let selectedEmotions = EmotionSelection(category: category, subEmotion: subs)
                self?.diaryWriteVM.trySelectEmotion(selectedEmotions)
            }
            
            cell.onTrySelectEmotion = { [weak self] category, subs in
                guard let self else { return false }
                let selection = EmotionSelection(category: category, subEmotion: subs)
                return self.diaryWriteVM.trySelectEmotion(selection)
            }
            
            return cell
        case .situation :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryWriteContentCell.reuseIdentifier, for: indexPath) as! DiaryWriteContentCell
            cell.configure(
                titleKey: title,
                guideKey: guide,
                placeholderKey1: placeholder1,
                placeholderKey2: placeholder2,
                text: ""
            )
            
            cell.textChanged = { [weak self] situation in
                print("상황: \(situation)")
            }
            
            return cell
        
        default:
            // 나머지 셀은 컬러 테스트용 셀
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.contentView.backgroundColor = randomColor(indexPath.item)
            return cell
        }
        
    }


    private func randomColor(_ index: Int) -> UIColor {
        let colors: [UIColor] = [.red, .green, .blue, .orange, .purple, .yellow]
        return colors[index % colors.count].withAlphaComponent(0.3)
    }
}


// MARK: ✅ Extension (레이아웃 사이즈 지정)
extension DiaryWriteViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
}


// MARK: ✅ Extension (UI 갱신 (ProgressView + PagingControlView update))
extension DiaryWriteViewController {

    func updateUIForStep(index: Int) {
        stepProgressView.update(current: index)
        pagingControlView.current = index
    }
    
}


// MARK: ✅ Extension (네비게이션 컨트롤러 설정)
extension DiaryWriteViewController {
    
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        
        let backBarButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(didTappedBack))
        backBarButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = backBarButton
    }
    
    @objc private func didTappedBack() {
        self.dismiss(animated: true)
    }
}



// MARK: ✅ Enum (감정일기 각 스텝을 담는 enum)
enum DiaryWriteStep: Int, CaseIterable {
    case emotion
    case situation
    case thought
    case reeval
    case action
    case dateAndImages
    
    var titleKey: String {
        switch self {
        case .emotion:       return "diary.emotion.title"
        case .situation:     return "diary.situation.title"
        case .thought:       return "diary.thought.title"
        case .reeval:        return "diary.reeval.title"
        case .action:        return "diary.action.title"
        case .dateAndImages: return "diary.date.title"
        }
    }
    
    var guideKey: String {
        switch self {
        case .emotion:       return "diary.emotion.guide"
        case .situation:     return "diary.situation.guide"
        case .thought:       return "diary.thought.guide"
        case .reeval:        return "diary.reeval.guide"
        case .action:        return "diary.action.guide"
        case .dateAndImages: return "diary.date.guide"
        }
    }
    
    var placeholder1Key: String {
        switch self {
        case .emotion:       return "diary.emotion.placeholder1"
        case .situation:     return "diary.situation.placeholder1"
        case .thought:       return "diary.thought.placeholder1"
        case .reeval:        return "diary.reeval.placeholder1"
        case .action:        return "diary.action.placeholder1"
        case .dateAndImages: return "diary.date.placeholder1"
        }
    }
    
    var placeholder2Key: String {
        switch self {
        case .emotion:       return "diary.emotion.placeholder2"
        case .situation:     return "diary.situation.placeholder2"
        case .thought:       return "diary.thought.placeholder2"
        case .reeval:        return "diary.reeval.placeholder2"
        case .action:        return "diary.action.placeholder2"
        case .dateAndImages: return "diary.date.placeholder2"
        }
    }
}
