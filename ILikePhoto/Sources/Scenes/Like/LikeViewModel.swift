//
//  LikeViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 8/10/24.
//

import Foundation
import RxSwift
import RxCocoa

enum LikeSearchOrder: String {
    case descending, ascending
    
    var title: String {
        switch self {
        case .descending:
            return "최신순"
        case .ascending:
            return "과거순"
        }
    }
}

final class LikeViewModel: ViewModelType {
    
    struct Input {
        let sortButtonTap: ControlEvent<Void>
        let colorCellTap: ControlEvent<IndexPath>
        let likeButtonTap: PublishSubject<Int>
        let viewWillAppear: ControlEvent<Bool>
        let photoCellTap: ControlEvent<IndexPath>
    }
    
    struct Output {
        let searchOrder: BehaviorSubject<LikeSearchOrder>
        let colorList: BehaviorSubject<[SearchColor]>
        let list: BehaviorSubject<[LikedPhoto]>
        let itemDeleted: PublishSubject<Void>
        let photoCellTap: PublishSubject<PhotoResponse>
        let scrollToTop: PublishSubject<Void>
    }
    
    lazy var list = RealmRepository.shared.fetchAll(order: searchOrder, color: searchColor)
    private var searchOrder = LikeSearchOrder.descending
    var searchColor = Set<SearchColor>()
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let searchOrder = BehaviorSubject<LikeSearchOrder>(value: searchOrder)
        let colorList = BehaviorSubject<[SearchColor]>(value: SearchColor.allCases)
        let list = BehaviorSubject<[LikedPhoto]>(value: list)
        let itemDeleted = PublishSubject<Void>()
        let photoCellTap = PublishSubject<PhotoResponse>()
        let scrollToTop = PublishSubject<Void>()
        
        input.sortButtonTap
            .subscribe(with: self) { owner, _ in
                owner.searchOrder = owner.searchOrder == .descending ? .ascending : .descending
                searchOrder.onNext(owner.searchOrder)
                
                owner.list = RealmRepository.shared.fetchAll(order: owner.searchOrder, color: owner.searchColor)
                list.onNext(owner.list)
                
                if !owner.list.isEmpty {
                    scrollToTop.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        input.colorCellTap
            .subscribe(with: self) { owner, indexPath in
                let color = SearchColor.allCases[indexPath.item]
                if owner.searchColor.contains(color) {
                    owner.searchColor.remove(color)
                } else {
                    owner.searchColor.insert(color)
                }
                colorList.onNext(SearchColor.allCases)
                
                owner.list = RealmRepository.shared.fetchAll(order: owner.searchOrder, color: owner.searchColor)
                list.onNext(owner.list)
                
                if !owner.list.isEmpty {
                    scrollToTop.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        input.photoCellTap
            .subscribe(with: self) { owner, indexPath in
                let data = owner.list[indexPath.item].ToPhotoResponse()
                photoCellTap.onNext(data)
            }
            .disposed(by: disposeBag)
        
        input.likeButtonTap
            .subscribe(with: self) { owner, index in
                let data = owner.list[index]
                ImageFileManager.shared.deleteImageFile(filename: data.id)
                ImageFileManager.shared.deleteImageFile(filename: data.id + "user")
                RealmRepository.shared.deleteItem(data.id)
                owner.list.remove(at: index)
                list.onNext(owner.list)
                itemDeleted.onNext(())
            }
            .disposed(by: disposeBag)
        
        input.viewWillAppear
            .subscribe(with: self) { owner, _ in
                owner.list = RealmRepository.shared.fetchAll(order: owner.searchOrder, color: owner.searchColor)
                list.onNext(owner.list)
            }
            .disposed(by: disposeBag)
        
        return Output(
            searchOrder: searchOrder,
            colorList: colorList,
            list: list,
            itemDeleted: itemDeleted,
            photoCellTap: photoCellTap, 
            scrollToTop: scrollToTop
        )
    }
}
