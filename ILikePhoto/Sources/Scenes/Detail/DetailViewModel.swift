//
//  DetailViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit

final class DetailViewModel: BaseViewModel {
    
    // Input
    var inputViewDidLoad = Observable<Void?>(nil)
    var inputLikeButtonTapped = Observable<UIImage?>(nil)
    
    // Output
    // 이전 화면에서 전달
    var outputPhoto = Observable<PhotoResponse?>(nil)
    // 네트워크 통신
    var outputStatistics = Observable<StatisticsResponse?>(nil)
    var outputButtonToggle = Observable(false)
    var outputToast = Observable(false)
    var outputFailure = Observable<Void?>(nil)
    
    override func transform() {
        inputViewDidLoad.bind { [weak self] _ in
            guard let self, let imageID = outputPhoto.value?.id else { return }
            outputButtonToggle.value = RealmRepository.shared.fetchItem(imageID) != nil
            NetworkManager.shared.request(
                api: .statistics(imageID: imageID),
                model: StatisticsResponse.self
            ) { [weak self] response in
                guard let self else { return }
                switch response {
                case .success(let data):
                    outputStatistics.value = data
                case .failure(_):
                    outputFailure.value = ()
                }
            }
        }
        
        inputLikeButtonTapped.bind { [weak self] image in
            guard let self, let photo = outputPhoto.value else { return }
            if RealmRepository.shared.fetchItem(photo.id) != nil {
                ImageFileManager.shared.deleteImageFile(filename: photo.id)
                RealmRepository.shared.deleteItem(photo.id)
                outputButtonToggle.value = false
                outputToast.value = false
            } else {
                let item = photo.toLikedPhoto()
                RealmRepository.shared.addItem(item)
                let image = image ?? MyImage.star
                ImageFileManager.shared.saveImageFile(image: image, filename: photo.id)
                outputButtonToggle.value = true
                outputToast.value = true
            }
        }
    }
}
