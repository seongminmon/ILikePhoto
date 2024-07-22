//
//  BaseViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

class BaseViewController<View: BaseView, ViewModel: BaseViewModel>: UIViewController {
    
    let baseView: View
    let viewModel: ViewModel
    
    init(view: View, viewModel: ViewModel) {
        self.baseView = view
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = baseView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = Design.Color.black
        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = Design.Color.white
        configureNavigationBar()
        configureView()
        bindData()
    }
    
    func configureNavigationBar() {}
    func configureView() {}
    func bindData() {}
}
