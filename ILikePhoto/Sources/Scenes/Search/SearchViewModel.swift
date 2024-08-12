//
//  SearchViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 8/9/24.
//

import Foundation
import RxSwift

final class SearchViewModel: ViewModelType {
    
    struct Input {
        let searchButtonTap: Observable<Void>
        let searchText: Observable<String?>
        let sortButtonTap: Observable<Void>
        let colorCellTap: Observable<IndexPath>
        let prefetchItems: Observable<[IndexPath]>
        let searchCellTap: Observable<IndexPath>
        let likeButtonTap: Observable<PhotoResponse>
    }
    
    struct Output {
        let searchOrder: BehaviorSubject<SearchOrder>
        let colorList: BehaviorSubject<[SearchColor]>
        let searchList: BehaviorSubject<[PhotoResponse]>
        let networkFailure: PublishSubject<Void>
        let emptyText: BehaviorSubject<String>
        let emptyQuery: PublishSubject<Void>
        let emptyResponse: BehaviorSubject<Bool>
        let scrollToTop: PublishSubject<Void>
        let searchCellTap: PublishSubject<PhotoResponse?>
        let likeButtonTap: PublishSubject<Bool>
    }
    
    var searchParameter = SearchParameter()
    var searchResponse: SearchResponse?
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let searchOrder = BehaviorSubject<SearchOrder>(value: .relevant)
        let colorList = BehaviorSubject<[SearchColor]>(value: SearchColor.allCases)
        let searchList = BehaviorSubject<[PhotoResponse]>(value: [])
        let networkFailure = PublishSubject<Void>()
        let emptyText = BehaviorSubject<String>(value: "사진을 검색해보세요.")
        let emptyQuery = PublishSubject<Void>()
        let emptyResponse = BehaviorSubject<Bool>(value: true)
        let scrollToTop = PublishSubject<Void>()
        let searchCellTap = PublishSubject<PhotoResponse?>()
        let likeButtonTap = PublishSubject<Bool>()
        
        func fetchSearch(_ searchParameter: SearchParameter) {
            NetworkManager.shared.requestWithSingle(
                api: .search(searchParameter: searchParameter),
                model: SearchResponse.self
            )
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    successAction(data, searchParameter.page)
                case .failure(_):
                    failureAction()
                }
            }
            .disposed(by: disposeBag)
        }
        
        func successAction(_ data: SearchResponse, _ page: Int) {
            // 새 통신과 페이지네이션 분기 처리, 데이터 변경
            if page == 1 {
                searchResponse = data
            } else {
                searchResponse?.photoResponse.append(contentsOf: data.photoResponse)
            }
            
            // list가 비어있다는 신호 보내기
            guard let list = searchResponse?.photoResponse, !list.isEmpty else {
                emptyResponse.onNext(true)
                return
            }
            
            emptyResponse.onNext(false)
            searchList.onNext(list)

            // 첫 통신이었다면 스크롤 올리기
            if page == 1 {
                scrollToTop.onNext(())
            }
        }
        
        func failureAction() {
            networkFailure.onNext(())
        }
        
        input.searchButtonTap
            .withUnretained(self)
            .withLatestFrom(input.searchText)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { self.validateQuery($0) }
            .compactMap { text in
                if text == nil { emptyQuery.onNext(()) }
                return text
            }
            .subscribe(with: self) { owner, query in
                emptyText.onNext("검색 결과가 없습니다.")
                owner.searchParameter.query = query
                owner.searchParameter.page = 1
                fetchSearch(owner.searchParameter)
            }
            .disposed(by: disposeBag)
        
        input.sortButtonTap
            .subscribe(with: self) { owner, _ in
                owner.searchParameter.order = owner.searchParameter.order == .relevant ? .latest : .relevant
                owner.searchParameter.page = 1
                searchOrder.onNext(owner.searchParameter.order)
                fetchSearch(owner.searchParameter)
            }
            .disposed(by: disposeBag)
        
        input.colorCellTap
            .subscribe(with: self) { owner, indexPath in
                let color = SearchColor.allCases[indexPath.item]
                owner.searchParameter.color = owner.searchParameter.color == color ? nil : color
                owner.searchParameter.page = 1
                // 데이터 리로드를 위해 고정 값 보내기
                colorList.onNext(SearchColor.allCases)
                fetchSearch(owner.searchParameter)
            }
            .disposed(by: disposeBag)
        
        input.prefetchItems
            .subscribe(with: self) { owner, indexPaths in
                guard let list = owner.searchResponse else { return }
                for indexPath in indexPaths {
                    if indexPath.item == list.photoResponse.count - 4 && owner.searchParameter.page < list.totalPages {
                        owner.searchParameter.page += 1
                        fetchSearch(owner.searchParameter)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.searchCellTap
            .subscribe(with: self) { owner, indexPath in
                let data = owner.searchResponse?.photoResponse[indexPath.item]
                searchCellTap.onNext(data)
            }
            .disposed(by: disposeBag)
        
        input.likeButtonTap
            .subscribe(with: self) { owner, data in
                if RealmRepository.shared.fetchItem(data.id) != nil {
                    ImageFileManager.shared.deleteImageFile(filename: data.id)
                    ImageFileManager.shared.deleteImageFile(filename: data.id + "user")
                    RealmRepository.shared.deleteItem(data.id)
                    likeButtonTap.onNext(false)
                } else {
                    let item = data.toLikedPhoto()
                    RealmRepository.shared.addItem(item)
                    ImageFileManager.shared.saveImageFile(url: item.smallURL, filename: data.id)
                    ImageFileManager.shared.saveImageFile(url: item.photographerImage, filename: data.id + "user")
                    likeButtonTap.onNext(true)
                }
            }
            .disposed(by: disposeBag)
                
        return Output(
            searchOrder: searchOrder,
            colorList: colorList, 
            searchList: searchList,
            networkFailure: networkFailure,
            emptyText: emptyText,
            emptyQuery: emptyQuery,
            emptyResponse: emptyResponse,
            scrollToTop: scrollToTop,
            searchCellTap: searchCellTap,
            likeButtonTap: likeButtonTap
        )
    }
    
    private func validateQuery(_ query: String?) -> String? {
        guard let query = query else { return nil }
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        return trimmedQuery.isEmpty ? nil : trimmedQuery
    }
}
