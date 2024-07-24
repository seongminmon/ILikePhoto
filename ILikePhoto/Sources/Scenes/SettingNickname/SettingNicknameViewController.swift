//
//  SettingNicknameViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit
import SnapKit
import Then

enum SettingOption: String {
    case create = "PROFILE SETTING"
    case edit = "EDIT PROFILE"
}

final class SettingNicknameViewController: BaseViewController {
    
    private lazy var profileImageView = ProfileImageView().then {
        $0.setImageView(isSelect: true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
        $0.addGestureRecognizer(tapGesture)
        $0.isUserInteractionEnabled = true
    }
    private let cameraView = CameraImageView()
    private lazy var nicknameTextField = UITextField().then {
        $0.placeholder = "닉네임을 입력해주세요 :)"
        $0.font = MyFont.regular14
        $0.clearButtonMode = .whileEditing
        $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    private let separator = UIView().then {
        $0.backgroundColor = MyColor.gray
    }
    private let descriptionLabel = UILabel().then {
        $0.font = MyFont.regular13
    }
    private let mbtiLabel = UILabel().then {
        $0.text = "MBTI"
        $0.font = MyFont.bold20
    }
    private let eButton = MBTIButton()
    private let sButton = MBTIButton()
    private let tButton = MBTIButton()
    private let jButton = MBTIButton()
    private let iButton = MBTIButton()
    private let nButton = MBTIButton()
    private let fButton = MBTIButton()
    private let pButton = MBTIButton()
    private let buttonStackView1 = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }
    private let buttonStackView2 = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }
    private lazy var confirmButton = BlueButton(title: "완료").then {
        $0.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    private lazy var buttons = [
        eButton, sButton, tButton, jButton,
        iButton, nButton, fButton, pButton
    ]
    
    // 이전 화면에서 전달
    var option: SettingOption?
    
    private let viewModel = SettingNicknameViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputViewDidLoad.value = option ?? .create
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        if option == .edit {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "탈퇴", style: .plain, target: self, action: #selector(deleteButtonTapped))
        }
    }
    
    override func bindData() {
        viewModel.outputImageIndex.bind { [weak self] index in
            guard let self, let index else { return }
            profileImageView.image = MyImage.profileImageList[index]
        }
        
        viewModel.outputNickname.bind { [weak self] nickname in
            guard let self else { return }
            nicknameTextField.text = nickname
        }
        
        viewModel.outputMbtiList.bind { [weak self] list in
            guard let self else { return }
            for i in 0..<list.count {
                buttons[i].setButton(isSelect: list[i])
            }
        }
        
        viewModel.outputDescriptionText.bind { [weak self] text in
            guard let self else { return }
            descriptionLabel.text = text
            if viewModel.nicknameValid == nil {
                descriptionLabel.textColor = MyColor.blue
            } else {
                descriptionLabel.textColor = MyColor.red
            }
        }
        
        viewModel.outputConfirmButtonEnabled.bind { [weak self] flag in
            guard let self else { return }
            confirmButton.isEnabled = flag
            confirmButton.backgroundColor = flag ? MyColor.blue : MyColor.gray
        }
        
        viewModel.outputPushSelectImageVC.bind { [weak self] _ in
            guard let self else { return }
            let vc = SettingImageViewController()
            vc.option = option
            vc.selectedIndex = viewModel.outputImageIndex.value
            vc.sendSelectedIndex = { [weak self] index in
                guard let self else { return }
                viewModel.outputImageIndex.value = index
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        
        viewModel.outputDeleteAll.bind { [weak self] _ in
            guard let self else { return }
            changeWindowToOnboarding()
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.title = option?.rawValue
    }
    
    override func configureHierarchy() {
        view.addSubview(profileImageView)
        view.addSubview(cameraView)
        view.addSubview(nicknameTextField)
        view.addSubview(separator)
        view.addSubview(descriptionLabel)
        view.addSubview(mbtiLabel)
        for i in 0..<buttons.count {
            if i < 4 {
                buttonStackView1.addArrangedSubview(buttons[i])
            } else {
                buttonStackView2.addArrangedSubview(buttons[i])
            }
        }
        view.addSubview(buttonStackView1)
        view.addSubview(buttonStackView2)
        view.addSubview(confirmButton)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(120)
        }
        cameraView.snp.makeConstraints {
            $0.trailing.bottom.equalTo(profileImageView)
            $0.size.equalTo(40)
        }
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        separator.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom)
            $0.horizontalEdges.equalTo(nicknameTextField)
            $0.height.equalTo(1)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(separator)
            $0.horizontalEdges.equalTo(nicknameTextField)
            $0.height.equalTo(30)
        }
        mbtiLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        buttonStackView1.snp.makeConstraints {
            $0.top.equalTo(mbtiLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(190)
            $0.height.equalTo(40)
        }
        buttonStackView2.snp.makeConstraints {
            $0.top.equalTo(buttonStackView1.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(190)
            $0.height.equalTo(40)
        }
        confirmButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(50)
        }
    }
    
    override func configureView() {
        for i in 0..<buttons.count {
            buttons[i].setTitle(MBTI.list[i], for: .normal)
            buttons[i].tag = i
            buttons[i].addTarget(self, action: #selector(mbtiButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func profileImageViewTapped() {
        viewModel.inputProfileImageTap.value = ()
    }
    
    @objc func textFieldDidChange() {
        viewModel.inputTextChange.value = nicknameTextField.text ?? ""
    }
    
    @objc func mbtiButtonTapped(sender: UIButton) {
        viewModel.inputMBTIButtonTap.value = sender.tag
    }
    
    @objc func confirmButtonTapped() {
        viewModel.inputConfirmButtonTap.value = (nicknameTextField.text ?? "")
        changeWindowToTabBarController()
    }
    
    @objc func deleteButtonTapped() {
        showDeleteAlert { [weak self] _ in
            guard let self else { return }
            viewModel.inputDeleteButtonTap.value = ()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
