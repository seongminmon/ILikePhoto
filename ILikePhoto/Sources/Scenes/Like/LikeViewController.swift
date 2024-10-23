//
//  LikeViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/25/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import Toast

final class LikeViewController: BaseViewController {
    // TODO: - 통신에서 오는 hex가 enum값과 다른 문제
    // TODO: - 삭제시 스크롤이 남아있는 문제
    
    private let colorCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .createColorButtonsLayout()
    ).then {
        $0.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorCollectionViewCell.description()
        )
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    private let sortButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 8
        $0.configuration = config
        $0.setTitleColor(MyColor.black, for: .normal)
        $0.titleLabel?.font = MyFont.bold14
        $0.tintColor = MyColor.black
        $0.setImage(MyImage.sort, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = MyColor.gray.cgColor
    }
    private lazy var pinterestLayout = PinterestLayout().then {
        $0.delegate = self
    }
    private lazy var mainCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: pinterestLayout
    ).then {
        $0.register(
            LikeCollectionViewCell.self,
            forCellWithReuseIdentifier: LikeCollectionViewCell.description()
        )
    }
    private let emptyLabel = UILabel().then {
        $0.text = "저장된 사진이 없어요."
        $0.font = MyFont.bold20
        $0.textColor = MyColor.black
    }
    
    private let viewModel = LikeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindData() {
        
        let likeButtonTap = PublishSubject<Int>()
        
        let input = LikeViewModel.Input(
            sortButtonTap: sortButton.rx.tap,
            colorCellTap: colorCollectionView.rx.itemSelected,
            likeButtonTap: likeButtonTap,
            viewWillAppear: rx.viewWillAppear,
            photoCellTap: mainCollectionView.rx.itemSelected
        )
        let output = viewModel.transform(input: input)
        
        output.searchOrder
            .map { $0.title }
            .bind(to: sortButton.rx.title())
            .disposed(by: disposeBag)
        
        output.colorList
            .bind(to: colorCollectionView.rx.items(
                cellIdentifier: ColorCollectionViewCell.description(),
                cellType: ColorCollectionViewCell.self
            )) { row, element, cell in
                cell.configureCell(color: element)
                cell.toggleSelected(isSelect: self.viewModel.searchColor.contains(element))
            }
            .disposed(by: disposeBag)
        
        output.list
            .bind(to: mainCollectionView.rx.items(
                cellIdentifier: LikeCollectionViewCell.description(),
                cellType: LikeCollectionViewCell.self
            )) { row, element, cell in
                cell.configureCell(data: element)
                cell.likeButton.toggleButton(isLike: true)
                cell.likeButton.rx.tap
                    .bind(with: self) { owner, _ in
                        likeButtonTap.onNext(row)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.list
            .map { $0.isEmpty }
            .subscribe(with: self) { owner, flag in
                owner.emptyLabel.isHidden = !flag
                owner.mainCollectionView.isHidden = flag
            }
            .disposed(by: disposeBag)
        
        output.photoCellTap
            .subscribe(with: self) { owner, data in
                owner.pushDetailViewController(data)
            }
            .disposed(by: disposeBag)
        
        output.itemDeleted
            .subscribe(with: self) { owner, _ in
                owner.makeRealmToast(false)
            }
            .disposed(by: disposeBag)
        
        output.scrollToTop
            .subscribe(with: self) { owner, _ in
                owner.mainCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "MY PHOTO"
    }
    
    override func configureHierarchy() {
        [
            colorCollectionView,
            sortButton,
            mainCollectionView,
            emptyLabel
        ].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureLayout() {
        colorCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.leading.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(sortButton.snp.leading)
            $0.height.equalTo(30)
        }
        sortButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(30)
        }
        mainCollectionView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(8)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyLabel.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension LikeViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        let data = viewModel.list[indexPath.item]
        let ratio = CGFloat(data.height) / CGFloat(data.width)
        let width = view.frame.width / 2
        return width * ratio
    }
}
