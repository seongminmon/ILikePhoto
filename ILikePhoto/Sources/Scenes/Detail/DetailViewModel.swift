//
//  DetailViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailViewModel: ViewModelType {
    
    private enum Info: String, CaseIterable {
        case size = "크기"
        case viewCount = "조회수"
        case downloadCount = "다운로드"
    }
    
    struct DetailCellData {
        let title: String
        let description: String
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let likeTap: ControlEvent<Void>
        let segmentIndex: ControlProperty<Int>
    }
    
    struct Output {
        let photographerImage: Observable<UIImage>
        let photographerName: Observable<String>
        let createAt: Observable<String>
        let mainImage: Observable<UIImage>
        let likeButtonState: Observable<Bool>
        let list: PublishSubject<[DetailCellData]>
        let networkFailure: Observable<Void>
        let realmToast: Observable<Bool>
        let segmentIndex: ControlProperty<Int>
        let chartData: PublishSubject<StatisticsResponse>
    }
    
    // 이전 화면에서 전달
    var photo: PhotoResponse?
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let photographerImage = BehaviorSubject<UIImage>(value: MyImage.star)
        let photographerName = BehaviorSubject<String>(value: "")
        let createAt = BehaviorSubject<String>(value: "")
        let mainImage = BehaviorSubject<UIImage>(value: MyImage.star)
        
        let likeButtonState = BehaviorSubject<Bool>(value: false)
        let list = PublishSubject<[DetailCellData]>()
        let networkFailure = PublishSubject<Void>()
        let realmToast = PublishSubject<Bool>()
        let chartData = PublishSubject<StatisticsResponse>()
        
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                guard let photo = owner.photo else { return }
                
                if RealmRepository.shared.fetchItem(photo.id) == nil {
                    // url로 불러오기
                    photo.user.profileImage.medium.urlToUIImage { image in
                        photographerImage.onNext(image ?? MyImage.star)
                    }
                    photo.urls.small.urlToUIImage { image in
                        mainImage.onNext(image ?? MyImage.star)
                    }
                } else {
                    // 파일로 불러오기
                    photographerImage.onNext(ImageFileManager.shared.loadImageFile(filename: photo.id + "user") ?? MyImage.star)
                    mainImage.onNext(ImageFileManager.shared.loadImageFile(filename: photo.id) ?? MyImage.star)
                }
                photographerName.onNext(photo.user.name)
                createAt.onNext(photo.createdAt.dateToString())
                likeButtonState.onNext(RealmRepository.shared.fetchItem(photo.id) != nil)
            }
            .disposed(by: disposeBag)
        
        input.viewDidLoad
            .withUnretained(self)
            .compactMap { _ in self.photo?.id }
            .flatMap { NetworkManager.shared.requestWithSingle(api: .statistics(imageID: $0), model: StatisticsResponse.self) }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    list.onNext(owner.changeData(data))
                    chartData.onNext(data)
                case .failure(_):
                    networkFailure.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        input.likeTap
            .subscribe(with: self) { owner, _ in
                guard let photo = owner.photo else { return }
                if RealmRepository.shared.fetchItem(photo.id) != nil {
                    ImageFileManager.shared.deleteImageFile(filename: photo.id)
                    ImageFileManager.shared.deleteImageFile(filename: photo.id + "user")
                    RealmRepository.shared.deleteItem(photo.id)
                    likeButtonState.onNext(false)
                    realmToast.onNext(false)
                } else {
                    let item = photo.toLikedPhoto()
                    RealmRepository.shared.addItem(item)
                    ImageFileManager.shared.saveImageFile(url: item.smallURL, filename: item.id)
                    ImageFileManager.shared.saveImageFile(url: item.photographerImage, filename: item.id + "user")
                    likeButtonState.onNext(true)
                    realmToast.onNext(true)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            photographerImage: photographerImage,
            photographerName: photographerName,
            createAt: createAt,
            mainImage: mainImage,
            likeButtonState: likeButtonState,
            list: list,
            networkFailure: networkFailure,
            realmToast: realmToast, 
            segmentIndex: input.segmentIndex,
            chartData: chartData
        )
    }
    
    private func changeData(_ data: StatisticsResponse) -> [DetailCellData] {
        var ret = [DetailCellData]()
        for i in 0..<3 {
            let title = Info.allCases[i].rawValue
            var description = ""
            switch i {
            case 0:
                if let photo {
                    description = "\(photo.width) x \(photo.height)"
                }
            case 1:
                description = data.views.total.formatted()
            case 2:
                description = data.downloads.total.formatted()
            default:
                break
            }
            ret.append(DetailCellData(title: title, description: description))
        }
        return ret
    }
}
