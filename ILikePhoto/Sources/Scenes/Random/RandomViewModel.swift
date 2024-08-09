//
//  RandomViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/27/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class RandomViewModel: ViewModelType {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let cellTap: ControlEvent<IndexPath>
        let likeTap: PublishSubject<Int>
    }
    
    struct Output {
        let list: PublishSubject<[PhotoResponse]>
        let networkFailure: PublishSubject<Void>
        let cellTap: Observable<PhotoResponse>
        let likeTap: Observable<Bool>
    }
    
    var list = [PhotoResponse]()
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let list = PublishSubject<[PhotoResponse]>()
        let networkFailure = PublishSubject<Void>()
        let cellTap = PublishSubject<PhotoResponse>()
        let likeTap = PublishSubject<Bool>()
        
        input.viewDidLoad
            .flatMap { NetworkManager.shared.requestRx(api: .random, model: [PhotoResponse].self) }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    owner.list = data
                    list.onNext(owner.list)
                case .failure(_):
                    networkFailure.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        input.cellTap
            .subscribe(with: self) { owner, indexPath in
                let data = owner.list[indexPath.row]
                cellTap.onNext(data)
            }
            .disposed(by: disposeBag)
        
        input.likeTap
            .subscribe(with: self) { owner, indexPath in
                let photo = owner.list[indexPath]
                if RealmRepository.shared.fetchItem(photo.id) != nil {
                    ImageFileManager.shared.deleteImageFile(filename: photo.id)
                    ImageFileManager.shared.deleteImageFile(filename: photo.id + "user")
                    RealmRepository.shared.deleteItem(photo.id)
                    likeTap.onNext(false)
                } else {
                    let item = photo.toLikedPhoto()
                    RealmRepository.shared.addItem(item)
                    ImageFileManager.shared.saveImageFile(url: item.smallURL, filename: photo.id)
                    ImageFileManager.shared.saveImageFile(url: item.photographerImage, filename: photo.id + "user")
                    likeTap.onNext(true)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            list: list,
            networkFailure: networkFailure, 
            cellTap: cellTap, 
            likeTap: likeTap
        )
    }
}
