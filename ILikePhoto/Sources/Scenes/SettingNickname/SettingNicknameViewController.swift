//
//  SettingNicknameViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit
import RxSwift
import RxCocoa
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
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .createMBTILayout()
    ).then {
        $0.register(MBTICollectionViewCell.self, forCellWithReuseIdentifier: MBTICollectionViewCell.description())
    }
    private lazy var confirmButton = BlueButton(title: "완료")
    private lazy var saveButton = UIBarButtonItem(title: "저장")
    private lazy var withdrawButton = UIButton().then {
        let attributeString = NSAttributedString(
            string: "회원탈퇴",
            attributes: [
                NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue
            ])
        $0.setAttributedTitle(attributeString, for: .normal)
        $0.setTitleColor(MyColor.blue, for: .normal)
    }
    
    // 이전 화면에서 전달
    var option: SettingOption?
    private let viewModel = SettingNicknameViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func bindData() {
        
        let deleteAlertAction = PublishSubject<Void>()
        
        let input = SettingNicknameViewModel.Input(
            settingOption: Observable.just(option ?? .create),
            viewWillAppear: rx.viewWillAppear,
            nickname: nicknameTextField.rx.text.orEmpty,
            mbtiSelected: collectionView.rx.itemSelected,
            confirmButtonTap: confirmButton.rx.tap,
            saveButtonTap: saveButton.rx.tap,
            withdrawButtonTap: withdrawButton.rx.tap,
            deleteAlertAction: deleteAlertAction
        )
        let output = viewModel.transform(input: input)
        
        // 이미지뷰
        output.imageIndex
            .map { MyImage.profileImageList[$0] }
            .bind(to: profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        // 닉네임(edit일때)
        output.savedNickname
            .bind(with: self, onNext: { owner, value in
                owner.nicknameTextField.text = value
                owner.nicknameTextField.sendActions(for: .editingChanged)
            })
            .disposed(by: disposeBag)
        
        // 닉네임 유효성
        output.nickNameValid
            .map { $0 ? MyColor.blue : MyColor.red }
            .bind(to: descriptionLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        output.description
            .bind(to: descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        // mbti
        output.mbtiList
            .bind(to: collectionView.rx.items(
                cellIdentifier: MBTICollectionViewCell.description(),
                cellType: MBTICollectionViewCell.self
            )) { row, element, cell in
                cell.configureCell(text: MBTI.list[row])
                cell.toggleSelected(isSelect: element)
            }
            .disposed(by: disposeBag)
        
        output.confirmButtonEnabled
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.confirmButtonEnabled
            .map { $0 ? MyColor.blue : MyColor.gray }
            .bind(to: confirmButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        output.confirmButtonTap
            .bind(with: self) { owner, value in
                owner.changeWindowToTabBarController()
            }
            .disposed(by: disposeBag)
        
        output.saveButtonTap
            .bind(with: self) { owner, value in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.withdrawButtonTap
            .bind(with: self) { owner, value in
                owner.showDeleteAlert { _ in
                    print("Alert Delete Action")
                    deleteAlertAction.onNext(())
                    owner.changeWindowToOnboarding()
                }
            }
            .disposed(by: disposeBag)
    }
    
    // TODO: - RxGesture로 바꾸기
    @objc private func profileImageViewTapped() {
        print(#function)
        let vc = SettingImageViewController()
        vc.option = option
        vc.selectedIndex = viewModel.imageIndex
        vc.sendSelectedIndex = { [weak self] index in
            guard let self else { return }
            viewModel.imageIndex = index
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func configureNavigationBar() {
        navigationItem.title = option?.rawValue
        if option == .edit {
            navigationItem.rightBarButtonItem = saveButton
            confirmButton.isHidden = true
        } else {
            withdrawButton.isHidden = true
        }
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
            confirmButton,
            withdrawButton
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
        withdrawButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(50)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
