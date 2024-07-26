//
//  RandomViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit
import SnapKit
import Then

final class RandomViewController: BaseViewController {
    
    private lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(
            RandomTableViewCell.self,
            forCellReuseIdentifier: RandomTableViewCell.description()
        )
        $0.rowHeight = UIScreen.main.bounds.height
        print($0.rowHeight)
    }
    
    override func configureNavigationBar() {
        
    }
    
    override func configureHierarchy() {
        view.addSubview(tableView)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.backgroundColor = .yellow
    }
    
    override func configureView() {
        
    }
}

extension RandomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RandomTableViewCell.description(), for: indexPath) as? RandomTableViewCell else { return UITableViewCell() }
        cell.backgroundColor = .blue
        return cell
    }
}
