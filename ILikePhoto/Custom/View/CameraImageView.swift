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
        $0.image = Design.Image.camera
        $0.tintColor = Design.Color.white
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = frame.width / 2
    }
    
    override func addSubviews() {
        addSubview(camera)
    }
    
    override func configureLayout() {
        camera.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }
    
    override func configureView() {
        backgroundColor = Design.Color.blue
        clipsToBounds = true
    }
}
