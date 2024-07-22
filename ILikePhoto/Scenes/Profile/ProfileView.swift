//
//  ProfileView.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit
import SnapKit
import Then

final class ProfileView: BaseView {
    
    private let mainImageView = ProfileImageView(image: Design.Image.profileImageList.randomElement())
    
    private let cameraView = CameraImageView()
    
    private let nicknameTextField = UITextField().then {
        $0.placeholder = "닉네임을 입력해주세요 :)"
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
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionView.createLayout())
    
    private let confirmButton = BlueButton(title: "완료")
    
    override func configureNavigationBar(_ vc: UIViewController) {
        vc.navigationItem.title = "PROFILE SETTING"
    }
    
    override func addSubviews() {
        addSubview(mainImageView)
        addSubview(cameraView)
        addSubview(nicknameTextField)
        addSubview(separator)
        addSubview(descriptionLabel)
        addSubview(mbtiLabel)
        addSubview(collectionView)
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
        collectionView.snp.makeConstraints {
            $0.top.equalTo(mbtiLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(210)
            $0.height.equalTo(110)
        }
        confirmButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(50)
        }
    }
    
    override func configureView() {
        mainImageView.toggleImageView(isSelect: true)
        collectionView.backgroundColor = .blue
        descriptionLabel.text = "사용 가능한 닉네임입니다."
    }
}

extension UICollectionView {
    static func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let sectionSpacing: CGFloat = 10
        let cellSpacing: CGFloat = 10
        let width: CGFloat = 40
        let height: CGFloat = 40
        
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        layout.sectionInset = UIEdgeInsets(top: sectionSpacing, left: sectionSpacing, bottom: sectionSpacing, right: sectionSpacing)
        return layout
    }
}
