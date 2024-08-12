//
//  TopicViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 8/8/24.
//

import Foundation
import RxSwift
import RxCocoa

final class TopicViewModel: ViewModelType {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let refreshEvent: ControlEvent<Void>
        let cellSelected: ControlEvent<IndexPath>
    }
    
    struct Output {
        let cellSelected: PublishSubject<PhotoResponse>
        let remainTime: PublishSubject<Void>
        let networkSuccess: PublishSubject<Void>
        let networkFailure: PublishSubject<Void>
    }
    
    // Section.allCases.count << 3
    var headerTitles = [String](repeating: "", count: 3)
    var list = [[PhotoResponse]](repeating: [], count: 3)
    private var recentNetworkTime: DispatchTime?
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let selectedData = PublishSubject<PhotoResponse>()
        let remainTime = PublishSubject<Void>()
        let networkSuccess = PublishSubject<Void>()
        let networkFailure = PublishSubject<Void>()
        
        Observable.merge(
            input.viewDidLoad,
            input.refreshEvent.asObservable()
        )
        .subscribe(with: self) { owner, _ in
            fetchTopic()
        }
        .disposed(by: disposeBag)
        
        input.cellSelected
            .subscribe(with: self) { owner, indexPath in
                selectedData.onNext(owner.list[indexPath.section][indexPath.item])
            }
            .disposed(by: disposeBag)
        
        func fetchTopic() {
            // 1분이 안 지났으면 통신 X
            if let recentNetworkTime, recentNetworkTime + 60 > .now() {
                remainTime.onNext(())
                return
            }
            
            // 토픽 3개 뽑기 (랜덤, 중복 X)
            var topicIDList = [String]()
            while topicIDList.count < 3 {
                let topicID = TopicIDQuery.list.keys.randomElement() ?? "golden-hour"
                if !topicIDList.contains(topicID) {
                    topicIDList.append(topicID)
                }
            }
            
            let dispatchGroup = DispatchGroup()
            
            // 3번 통신하기
            for i in 0..<3 {
                let topicID = topicIDList[i]
                dispatchGroup.enter()
                NetworkManager.shared.requestWithSingle(api: .topic(topicID: topicID), model: [PhotoResponse].self)
                    .subscribe(with: self) { owner, result in
                        switch result {
                        case .success(let data):
                            owner.headerTitles[i] = TopicIDQuery.list[topicID] ?? "골든 아워"
                            owner.list[i] = data
                        case .failure(_):
                            networkFailure.onNext(())
                        }
                        dispatchGroup.leave()
                    }
                    .disposed(by: disposeBag)
            }
            
            dispatchGroup.notify(queue: .main) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.recentNetworkTime = .now()
                    networkSuccess.onNext(())
                }
            }
        }
        
        return Output(
            cellSelected: selectedData,
            remainTime: remainTime, 
            networkSuccess: networkSuccess,
            networkFailure: networkFailure
        )
    }
}
