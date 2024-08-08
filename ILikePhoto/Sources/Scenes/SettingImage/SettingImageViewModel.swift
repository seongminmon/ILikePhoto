//
//  SettingImageViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 8/6/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingImageViewModel: ViewModelType {
    
    struct Input {
        let itemSelected: ControlEvent<IndexPath>
    }
    
    struct Output {
        let imageList: BehaviorRelay<[UIImage]>
        let itemSelected: ControlEvent<IndexPath>
    }
    
    func transform(input: Input) -> Output {
        return Output(
            imageList: BehaviorRelay(value: MyImage.profileImageList), 
            itemSelected: input.itemSelected
        )
    }
}

