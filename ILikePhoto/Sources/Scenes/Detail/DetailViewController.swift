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
import Charts
import DGCharts

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
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
    }
    // TODO: - 차트 기능 레이아웃, 데이터 다듬기
    private let chartLabel = UILabel().then {
        $0.text = "차트"
        $0.font = MyFont.bold16
    }
    private lazy var segmentControl = UISegmentedControl(items: ["조회", "다운로드"]).then {
        $0.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
        $0.selectedSegmentIndex = 0
    }
    private lazy var chartView = LineChartView().then {
        $0.noDataText = "출력 데이터가 없습니다."
        $0.noDataFont = .systemFont(ofSize: 20)
        $0.noDataTextColor = .lightGray
        $0.backgroundColor = .yellow
        // 값마다 구분하고 싶은 valueFormatter 예) 날짜, 이름
//        guard let value = viewModel.outputStatistics.value else { return }
//        let data = value.views.historical.values
//        $0.xAxis.valueFormatter = IndexAxisValueFormatter(values: data.map { $0.date })
//        // 값마다 구분하고 싶은 valueFormatter를 개수만큼 출력
//        $0.xAxis.setLabelCount(data.count, force: false)
    }
    
    private enum Info: String, CaseIterable {
        case size = "크기"
        case viewCount = "조회수"
        case downloadCount = "다운로드"
    }
    
    let viewModel = DetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputViewDidLoad.value = ()
        setChartData(index: segmentControl.selectedSegmentIndex)
    }
    
    override func bindData() {
        viewModel.outputPhoto.bindEarly { [weak self] photo in
            guard let self, let photo else { return }
            let photographerURL = URL(string: photo.user.profileImage.medium)
            self.photographerImageView.kf.setImage(with: photographerURL)
            self.photographerNameLabel.text = photo.user.name
            self.createAtLabel.text = photo.createdAt
            self.likeButton.toggleButton(isLike: RealmRepository.shared.fetchItem(photo.id) != nil)
            let mainURL = URL(string: photo.urls.small)
            self.mainImageView.kf.setImage(with: mainURL)
        }
        
        viewModel.outputStatistics.bind { [weak self] _ in
            guard let self else { return }
            tableView.reloadData()
        }
        
        viewModel.outputButtonToggle.bind {  [weak self] value in
            guard let self else { return }
            likeButton.toggleButton(isLike: value)
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
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
            tableView,
            chartLabel,
            segmentControl,
            chartView
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
            // width height 비율에 맞게 조정
            let data = viewModel.outputPhoto.value!
            let ratio = CGFloat(data.height) / CGFloat(data.width)
            $0.height.equalTo(mainImageView.snp.width ).multipliedBy(ratio)
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
        }
        chartLabel.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(8)
            $0.leading.equalTo(infoLabel)
        }
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(chartLabel)
            $0.leading.equalTo(tableView)
        }
        chartView.snp.makeConstraints {
            $0.top.equalTo(segmentControl.snp.bottom).offset(8)
            $0.leading.equalTo(segmentControl)
            $0.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(300)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    @objc private func likeButtonTapped() {
        viewModel.inputLikeButtonTapped.value = mainImageView.image
    }
    
    @objc private func segmentValueChanged() {
        setChartData(index: segmentControl.selectedSegmentIndex)
    }
    
    private func entryData(index: Int) -> [BarChartDataEntry] {
        guard let value = viewModel.outputStatistics.value else { return [] }
        var barDataEntries = [BarChartDataEntry]()
        switch index {
        case 0: // 조회
            let data = value.views.historical.values
            for i in 0..<data.count {
                let barDataEntry = BarChartDataEntry(x: Double(i), y: Double(data[i].value))
                barDataEntries.append(barDataEntry)
            }
        case 1: // 다운로드
            let data = value.downloads.historical.values
            for i in 0..<data.count {
                let barDataEntry = BarChartDataEntry(x: Double(i), y: Double(data[i].value))
                barDataEntries.append(barDataEntry)
            }
        default:
            break
        }
        return barDataEntries
    }
    
    private func setChartData(index: Int) {
        let barChartDataEntries = entryData(index: index)
        let barChartdataSet = LineChartDataSet(entries: barChartDataEntries)
        let barChartData = LineChartData(dataSet: barChartdataSet)
        chartView.data = barChartData
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
              let photo = viewModel.outputPhoto.value else {
            return UITableViewCell()
        }
        
        let statistics = viewModel.outputStatistics.value
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
        cell.selectionStyle = .none
        return cell
    }
}
