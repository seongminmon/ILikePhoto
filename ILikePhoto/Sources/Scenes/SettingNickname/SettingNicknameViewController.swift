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
        $0.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEndOnExit)
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
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .createMBTILayout()).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(MBTICollectionViewCell.self, forCellWithReuseIdentifier: MBTICollectionViewCell.description())
    }
    private lazy var confirmButton = BlueButton(title: "완료").then {
        $0.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    // 이전 화면에서 전달
    var option: SettingOption?
    
    private let viewModel = SettingNicknameViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputViewDidLoad.value = option ?? .create
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        if option == .edit {
            let withdrawButton = UIBarButtonItem(
                title: "탈퇴하기",
                style: .done,
                target: self,
                action: #selector(deleteButtonTapped)
            )
            withdrawButton.tintColor = MyColor.red
            navigationItem.rightBarButtonItem = withdrawButton
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
            collectionView.reloadData()
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
        [
            profileImageView,
            cameraView,
            nicknameTextField,
            separator,
            descriptionLabel,
            mbtiLabel,
            collectionView,
            confirmButton
        ].forEach {
            view.addSubview($0)
        }
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
        collectionView.snp.makeConstraints {
            $0.top.equalTo(mbtiLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(160 + 50)
            $0.height.equalTo(80 + 30)
        }
        confirmButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(50)
        }
    }
    
    @objc private func profileImageViewTapped() {
        viewModel.inputProfileImageTap.value = ()
    }
    
    @objc private func textFieldDidChange() {
        viewModel.inputTextChange.value = nicknameTextField.text ?? ""
    }
    
    @objc private func confirmButtonTapped() {
        viewModel.inputConfirmButtonTap.value = nicknameTextField.text ?? ""
        if option == .create {
            changeWindowToTabBarController()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func deleteButtonTapped() {
        showDeleteAlert { [weak self] _ in
            guard let self else { return }
            viewModel.inputDeleteButtonTap.value = ()
        }
    }
    
    @objc func textFieldDidEndEditing() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension SettingNicknameViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MBTI.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MBTICollectionViewCell.description(),
            for: indexPath
        ) as? MBTICollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(text: MBTI.list[indexPath.item])
        cell.toggleSelected(isSelect: viewModel.outputMbtiList.value[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.inputCellSelected.value = indexPath.item
    }
}
