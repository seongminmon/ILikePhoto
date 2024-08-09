//
//  DetailViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit
import DGCharts
import Kingfisher
import RxSwift
import RxCocoa
import SnapKit
import Then
import Toast

final class DetailViewController: BaseViewController {
    
    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
    }
    private let contentView = UIView()
    private let headerView = UIView().then {
        $0.backgroundColor = MyColor.black.withAlphaComponent(0.3)
    }
    private let photographerImageView = UIImageView().then {
        $0.backgroundColor = MyColor.gray
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
    }
    private let photographerNameLabel = UILabel().then {
        $0.font = MyFont.regular15
    }
    private let createAtLabel = UILabel().then {
        $0.font = MyFont.bold14
    }
    private let likeButton = LikeButton().then {
        $0.toggleButton(isLike: false)
    }
    private let mainImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    private let infoLabel = UILabel().then {
        $0.text = "정보"
        $0.font = MyFont.bold16
    }
    private let tableView = UITableView().then {
        $0.register(
            DetailTableViewCell.self,
            forCellReuseIdentifier: DetailTableViewCell.description()
        )
        $0.rowHeight = UITableView.automaticDimension
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
    }
    private let chartLabel = UILabel().then {
        $0.text = "차트"
        $0.font = MyFont.bold16
    }
    private let segmentControl = UISegmentedControl(items: ["조회", "다운로드"]).then {
        $0.selectedSegmentIndex = 0
    }
    private let chartView = LineChartView().then {
        $0.noDataText = "출력 데이터가 없습니다."
        $0.noDataFont = .systemFont(ofSize: 20)
        $0.noDataTextColor = .lightGray
        $0.rightAxis.enabled = false
        $0.leftAxis.enabled = false
        $0.xAxis.enabled = false
        $0.legend.enabled = false
        $0.isUserInteractionEnabled = false
        $0.dragEnabled = false
        $0.pinchZoomEnabled = false
        $0.doubleTapToZoomEnabled = false
        $0.highlightPerTapEnabled = false
        $0.highlightPerDragEnabled = false
    }
    
    let viewModel = DetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindRefactoring()
    }
    
    func bindRefactoring() {
        let input = DetailViewModel.Input(
            viewDidLoad: Observable.just(()),
            likeTap: likeButton.rx.tap,
            segmentIndex: segmentControl.rx.selectedSegmentIndex
        )
        let output = viewModel.transform(input: input)
        
        output.photographerImage
            .bind(to: photographerImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.photographerName
            .bind(to: photographerNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.createAt
            .bind(to: createAtLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.mainImage
            .bind(to: mainImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.likeButtonState
            .bind(with: self) { owner, value in
                owner.likeButton.toggleButton(isLike: value)
            }
            .disposed(by: disposeBag)
        
        output.list
            .bind(to: tableView.rx.items(
                cellIdentifier: DetailTableViewCell.description(),
                cellType: DetailTableViewCell.self
            )) { (row, element, cell) in
                cell.configureCell(title: element.title, description: element.description)
            }
            .disposed(by: disposeBag)
        
        output.networkFailure
            .bind(with: self) { owner, _ in
                owner.makeNetworkFailureToast()
            }
            .disposed(by: disposeBag)
        
        output.realmToast
            .bind(with: self) { owner, value in
                owner.makeRealmToast(value)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            output.segmentIndex,
            output.chartData
        ).subscribe(with: self) { owner, value in
            owner.setChartData(index: value.0, value: value.1)
        }
        .disposed(by: disposeBag)
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
            if let data = viewModel.photo {
                let ratio = CGFloat(data.height) / CGFloat(data.width)
                $0.height.equalTo(mainImageView.snp.width ).multipliedBy(ratio)
            } else {
                $0.height.equalTo(mainImageView.snp.width ).multipliedBy(1)
            }
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
    
    private func entryData(index: Int, value: StatisticsResponse) -> [BarChartDataEntry] {
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
    
    private func setChartData(index: Int, value: StatisticsResponse) {
        let dataEntries = entryData(index: index, value: value)
        
        let dataSet = LineChartDataSet(entries: dataEntries)
        dataSet.drawValuesEnabled = false
        dataSet.setCircleColor(MyColor.blue)
        dataSet.drawCircleHoleEnabled = false
        dataSet.circleRadius = 0
        dataSet.colors = [MyColor.blue]
        
        let gradientColors = [MyColor.blue.cgColor] as CFArray
        let colorLocations: [CGFloat] = [0.0]
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: gradientColors,
            locations: colorLocations
        ) else { return }
        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 80.0)
        dataSet.drawFilledEnabled = true
        
        chartView.data = LineChartData(dataSet: dataSet)
    }
}
