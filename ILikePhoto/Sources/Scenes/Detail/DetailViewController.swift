//
//  DetailViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class DetailViewController: BaseViewController {
    
    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
    }
    private let contentView = UIView()
    private let headerView = UIView().then {
        $0.backgroundColor = MyColor.black.withAlphaComponent(0.3)
    }
    private let photographerImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
    }
    private let photographerNameLabel = UILabel().then {
        $0.font = MyFont.regular15
    }
    private let createAtLabel = UILabel().then {
        $0.font = MyFont.bold14
    }
    
    private lazy var likeButton = LikeButton().then {
        $0.toggleButton(isLike: false)
        $0.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    private let mainImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    private let infoLabel = UILabel().then {
        $0.text = "정보"
        $0.font = MyFont.bold16
    }
    private lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(
            DetailTableViewCell.self,
            forCellReuseIdentifier: DetailTableViewCell.description()
        )
        $0.rowHeight = UITableView.automaticDimension
        $0.backgroundColor = .clear
    }
    
    private enum Info: String, CaseIterable {
        case size = "크기"
        case viewCount = "조회수"
        case downloadCount = "다운로드"
    }
    
    // 이전 화면에서 전달
    var photo: PhotoResponse?
    
    // 네트워크 통신
    var statistics: StatisticsResponse?
    
    let viewModel = DetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        guard let photo else { return }
        NetworkManager.shared.request(
            api: .statistics(imageID: photo.id),
            model: StatisticsResponse.self
        ) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let data):
                statistics = data
                tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func bindData() {
        
    }
    
    override func configureNavigationBar() {
        //
    }
    
    override func configureHierarchy() {
        [
            photographerImageView,
            photographerNameLabel,
            createAtLabel,
            likeButton,
        ].forEach {
            headerView.addSubview($0)
        }
        [
            mainImageView,
            headerView,
            infoLabel,
            tableView
        ].forEach {
            contentView.addSubview($0)
        }
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints {
            $0.width.verticalEdges.equalToSuperview()
        }
        headerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(60)
        }
        photographerImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(8)
            $0.size.equalTo(40)
        }
        photographerNameLabel.snp.makeConstraints {
            $0.top.equalTo(photographerImageView)
            $0.leading.equalTo(photographerImageView.snp.trailing).offset(4)
            $0.trailing.equalTo(likeButton.snp.leading).offset(-8)
            $0.height.equalTo(20)
        }
        createAtLabel.snp.makeConstraints {
            $0.bottom.equalTo(photographerImageView)
            $0.leading.equalTo(photographerNameLabel)
            $0.trailing.equalTo(likeButton.snp.leading).offset(-8)
            $0.height.equalTo(20)
        }
        likeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
            $0.size.equalTo(40)
        }
        mainImageView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(200)
        }
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(8)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(mainImageView.snp.bottom).offset(16)
            $0.leading.equalTo(infoLabel.snp.trailing).offset(60)
            $0.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(44 * 3)
            $0.bottom.equalToSuperview()
        }
    }
    
    override func configureView() {
        guard let photo else { return }
        let photographerURL = URL(string: photo.user.profileImage.medium)
        photographerImageView.kf.setImage(with: photographerURL)
        photographerNameLabel.text = photo.user.name
        createAtLabel.text = photo.createdAt
        likeButton.toggleButton(isLike: RealmRepository.shared.fetchItem(photo.id) != nil)
        let mainURL = URL(string: photo.urls.small)
        mainImageView.kf.setImage(with: mainURL)
    }
    
    @objc private func likeButtonTapped() {
        print(#function)
        
        guard let photo else { return }
        if RealmRepository.shared.fetchItem(photo.id) != nil {
            // 1. 이미지 파일 삭제
            ImageFileManager.shared.deleteImageFile(filename: photo.id)
            // 2. Realm 삭제
            RealmRepository.shared.deleteItem(photo.id)
            // 3. 버튼 업데이트
            likeButton.toggleButton(isLike: false)
        } else {
            // 1. Realm 추가
            let item = photo.toLikedPhoto()
            RealmRepository.shared.addItem(item)
            // 2. 이미지 파일 추가
            let image = mainImageView.image ?? MyImage.star
            ImageFileManager.shared.saveImageFile(image: image, filename: photo.id)
            // 3. 버튼 업데이트
            likeButton.toggleButton(isLike: true)
        }
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Info.allCases.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DetailTableViewCell.description(),
            for: indexPath
        ) as? DetailTableViewCell,
              let photo else {
            return UITableViewCell()
        }
        
        let title = Info.allCases[indexPath.row].rawValue
        var description = ""
        switch indexPath.row {
        case 0:
            description = "\(photo.width) x \(photo.height)"
        case 1:
            description = statistics?.views.total.formatted() ?? ""
        case 2:
            description = statistics?.downloads.total.formatted() ?? ""
        default:
            break
        }
        cell.configureCell(title: title, description: description)
        return cell
    }
}
