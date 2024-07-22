//
//  BaseView.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        configureLayout()
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureNavigationBar(_ vc: UIViewController) {}
    func addSubviews() {}
    func configureLayout() {}
    func configureView() {}
}
