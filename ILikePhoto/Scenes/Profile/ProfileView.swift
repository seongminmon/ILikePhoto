//
//  ProfileView.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit
import SnapKit
import Then

protocol ProfileViewDelegate {
    func profileImageViewTapped()
    func textFieldDidChange(_ text: String)
    func mbtiButtonTapped(_ tag: Int)
    func confirmButtonTapped()
}

final class ProfileView: BaseView {
    
    private lazy var mainImageView = ProfileImageView(image: nil).then {
        $0.setImageView(isSelect: true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
        $0.addGestureRecognizer(tapGesture)
        $0.isUserInteractionEnabled = true
    }
    
    private let cameraView = CameraImageView()
    
    private lazy var nicknameTextField = UITextField().then {
        $0.placeholder = "닉네임을 입력해주세요 :)"
        $0.font = Design.Font.regular14
        $0.clearButtonMode = .whileEditing
        $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private let separator = UIView().then {
        $0.backgroundColor = Design.Color.gray
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = Design.Font.regular13
    }
    
    private let mbtiLabel = UILabel().then {
        $0.text = "MBTI"
        $0.font = Design.Font.bold20
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
    
    private lazy var buttons: [UIButton] = [
        eButton, sButton, tButton, jButton,
        iButton, nButton, fButton, pButton
    ]
    
    var delegate: ProfileViewDelegate?
    
    override func addSubviews() {
        addSubview(mainImageView)
        addSubview(cameraView)
        addSubview(nicknameTextField)
        addSubview(separator)
        addSubview(descriptionLabel)
        addSubview(mbtiLabel)
        for i in 0..<buttons.count {
            if i < 4 {
                buttonStackView1.addArrangedSubview(buttons[i])
            } else {
                buttonStackView2.addArrangedSubview(buttons[i])
            }
        }
        addSubview(buttonStackView1)
        addSubview(buttonStackView2)
        addSubview(confirmButton)
    }
    
    override func configureLayout() {
        mainImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(120)
        }
        cameraView.snp.makeConstraints {
            $0.trailing.bottom.equalTo(mainImageView)
            $0.size.equalTo(40)
        }
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(20)
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
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(50)
        }
    }
    
    override func configureView() {
        descriptionLabel.text = "사용 가능한 닉네임입니다."
        for i in 0..<buttons.count {
            buttons[i].setTitle(MBTI.allCases[i].rawValue, for: .normal)
            buttons[i].tag = i
            buttons[i].addTarget(self, action: #selector(mbtiButtonTapped), for: .touchUpInside)
        }
    }
    
    func setImageView(_ index: Int) {
        mainImageView.image = Design.Image.profileImageList[index]
    }
    
    // 닉네임 유효성 통과 && mbti 모두 선택
    func confirmButtonEnabled(_ flag: Bool) {
        confirmButton.isEnabled = flag
    }
    
    @objc func profileImageViewTapped() {
        delegate?.profileImageViewTapped()
    }
    
    @objc func textFieldDidChange() {
        delegate?.textFieldDidChange(nicknameTextField.text ?? "")
    }
    
    @objc func mbtiButtonTapped(sender: UIButton) {
        // TODO: - UI 관련 처리하기
        delegate?.mbtiButtonTapped(sender.tag)
    }
    
    @objc func confirmButtonTapped() {
        delegate?.confirmButtonTapped()
    }
}
