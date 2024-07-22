//
//  OnboardingViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

import SnapKit
import Then

final class OnboardingViewController: UIViewController {
    
    let titleImageView = UIImageView().then {
        $0.image = Design.Image.launch
    }
    
    let logoImageView = UIImageView().then {
        $0.image = Design.Image.launchLogoImage
    }
    
    let nameLabel = UILabel().then {
        $0.text = "김성민"
        $0.font = Design.Font.title
    }
    
    lazy var startButton = BlueButton(title: "시작하기").then {
        $0.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = Design.Color.black
        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = Design.Color.white
        addSubviews()
        configureLayout()
    }
    
    func addSubviews() {
        view.addSubview(titleImageView)
        view.addSubview(logoImageView)
        view.addSubview(nameLabel)
        view.addSubview(startButton)
    }
    
    func configureLayout() {
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
    
    @objc func startButtonTapped() {
        let vc = ProfileViewController(view: ProfileView(), viewModel: ProfileViewModel())
        navigationController?.pushViewController(vc, animated: true)
    }
}
