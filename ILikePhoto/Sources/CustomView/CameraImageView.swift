//
//  CameraImageView.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit
import SnapKit
import Then

final class CameraImageView: BaseView {
    
    let camera = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = MyImage.camera
        $0.tintColor = MyColor.white
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = frame.width / 2
    }
    
    override func configureHierarchy() {
        addSubview(camera)
    }
    
    override func configureLayout() {
        camera.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }
    
    override func configureView() {
        backgroundColor = MyColor.blue
        clipsToBounds = true
    }
}
