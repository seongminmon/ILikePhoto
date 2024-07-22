//
//  OnboardingViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

import SnapKit
import Then

class OnboardingViewController: UIViewController {
    
    let titleImageView = UIImageView().then {
        $0.image = Design.Image.launch
    }
    
    let logoImageView = UIImageView().then {
        $0.image = Design.Image.launchLogoImage
    }
    
    let nameLabel = UILabel().then {
        $0.text = "김성민"
        $0.font = .boldSystemFont(ofSize: 30)
    }
    
    let startButton = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 20
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(titleImageView)
        view.addSubview(logoImageView)
        view.addSubview(nameLabel)
        view.addSubview(startButton)
        
        titleImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(120)
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(titleImageView.snp.bottom).offset(20)
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

}
