//
//  OnboardingViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class OnboardingViewController: BaseViewController {
    
    private let titleLabel = UILabel().then {
        $0.text = Literal.appName
        $0.font = MyFont.title
        $0.textColor = MyColor.blue
        $0.textAlignment = .center
    }
    
    private let logoImageView = UIImageView().then {
        $0.image = MyImage.launchLogoImage
    }
    
    private let nameLabel = UILabel().then {
        $0.text = Literal.name
        $0.font = MyFont.title
    }
    
    private lazy var startButton = BlueButton(title: Literal.start)
    
    override func configureHierarchy() {
        [
            titleLabel,
            logoImageView,
            nameLabel,
            startButton
        ].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(120)
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(logoImageView.snp.width)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        startButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.height.equalTo(50)
        }
    }
    
    override func bindData() {
        startButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = SettingNicknameViewController()
                vc.option = .create
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension OnboardingViewController {
    private enum Literal {
        static let appName = "I Like Photo"
        static let name = "김성민"
        static let start = "시작하기"
    }
}
