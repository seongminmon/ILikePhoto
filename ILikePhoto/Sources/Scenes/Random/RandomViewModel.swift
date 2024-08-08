//
//  RandomViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/27/24.
//

import UIKit
import Kingfisher

final class RandomViewModel: BaseViewModel {
    
    // Input
    var inputViewDidLoad = CustomObservable<Void?>(nil)
    var inputLikeButtonTap = CustomObservable<(Int?, UIImage?)>((nil, nil))
    
    // Output
    var outputList = CustomObservable<[PhotoResponse]>([])
    var outputButtonToggle = CustomObservable<Bool>(false)
    var outputFailure = CustomObservable<Void?>(nil)
    
    override func transform() {
        inputViewDidLoad.bind { [weak self] _ in
            guard let self else { return }
            NetworkManager.shared.request(
                api: .random,
                model: [PhotoResponse].self
            ) { [weak self] response in
                guard let self else { return }
                switch response {
                case .success(let data):
                    outputList.value = data
                case .failure(_):
                    outputFailure.value = ()
                }
            }
        }
        
        inputLikeButtonTap.bind { [weak self] index, image in
            guard let self, let index else { return }
            let photo = outputList.value[index]
            if RealmRepository.shared.fetchItem(photo.id) != nil {
                ImageFileManager.shared.deleteImageFile(filename: photo.id)
                ImageFileManager.shared.deleteImageFile(filename: photo.id + "user")
                RealmRepository.shared.deleteItem(photo.id)
                outputButtonToggle.value = false
            } else {
                let item = photo.toLikedPhoto()
                RealmRepository.shared.addItem(item)
                let image = image ?? MyImage.star
                ImageFileManager.shared.saveImageFile(image: image, filename: photo.id)
                if let url = URL(string: item.photographerImage) {
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        switch result {
                        case .success(let imageResult):
                            let profileImage = imageResult.image
                            ImageFileManager.shared.saveImageFile(image: profileImage, filename: photo.id + "user")
                        case .failure(_):
                            print("작가 이미지 변환 실패")
                        }
                    }
                }
                outputButtonToggle.value = true
            }
        }
    }
}
