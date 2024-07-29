//
//  RandomViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/27/24.
//

import UIKit

final class RandomViewModel: BaseViewModel {
    
    // Input
    var inputViewDidLoad = Observable<Void?>(nil)
    var inputLikeButtonTap = Observable<(Int?, UIImage?)>((nil, nil))
    
    // Output
    var outputList = Observable<[PhotoResponse]>([])
    var outputButtonToggle = Observable<Bool>(false)
    var outputFailure = Observable<Void?>(nil)
    
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
                RealmRepository.shared.deleteItem(photo.id)
                outputButtonToggle.value = false
            } else {
                let item = photo.toLikedPhoto()
                RealmRepository.shared.addItem(item)
                let image = image ?? MyImage.star
                ImageFileManager.shared.saveImageFile(image: image, filename: photo.id)
                outputButtonToggle.value = true
            }
        }
    }
}
