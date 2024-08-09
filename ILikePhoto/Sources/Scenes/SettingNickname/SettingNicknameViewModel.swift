//
//  SettingNicknameViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingNicknameViewModel: ViewModelType {
    
    struct Input {
        let settingOption: Observable<SettingOption>
        let viewWillAppear: ControlEvent<Bool>
        let nickname: ControlProperty<String>
        let mbtiSelected: ControlEvent<IndexPath>
        let confirmButtonTap: ControlEvent<Void>
        let saveButtonTap: ControlEvent<Void>
        let withdrawButtonTap: ControlEvent<Void>
        let deleteAlertAction: PublishSubject<Void>
    }
    
    struct Output {
        let imageIndex: BehaviorSubject<Int>
        let mbtiList: BehaviorSubject<[Bool]>
        let savedNickname: BehaviorSubject<String>
        let nickNameValid: BehaviorSubject<Bool>
        let description: PublishSubject<String>
        let confirmButtonEnabled: BehaviorSubject<Bool>
        let confirmButtonTap: ControlEvent<Void>
        let saveButtonTap: ControlEvent<Void>
        let withdrawButtonTap: ControlEvent<Void>
    }
    
    private var nicknameValid: NicknameValidationError?
    private var mbtiValid: Bool {
        return mbtiList.filter { $0 }.count == 4
    }
    private var totalValid: Bool {
        return nicknameValid == nil && mbtiValid
    }
    var imageIndex: Int = 0
    private var mbtiList = [Bool]()
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let imageIndex = BehaviorSubject(value: imageIndex)
        let mbtiList = BehaviorSubject<[Bool]>(value: [])
        let savedNickname = BehaviorSubject(value: "")
        let nickNameValid = BehaviorSubject(value: false)
        let description = PublishSubject<String>()
        let confirmButtonEnabled = BehaviorSubject(value: false)
        
        input.settingOption
            .subscribe(with: self) { owner, option in
                print("옵션에 따라 초기 세팅", option)
                switch option {
                case .create:
                    owner.imageIndex = Int.random(in: 0..<MyImage.profileImageList.count)
                    owner.mbtiList = [Bool](repeating: false, count: MBTI.list.count)
                case .edit:
                    owner.imageIndex = UserDefaultsManager.profileImageIndex
                    owner.mbtiList = UserDefaultsManager.mbti
                    savedNickname.onNext(UserDefaultsManager.nickname)
                }
                imageIndex.onNext(owner.imageIndex)
                mbtiList.onNext(owner.mbtiList)
                confirmButtonEnabled.onNext(owner.totalValid)
            }
            .disposed(by: disposeBag)
        
        input.viewWillAppear
            .subscribe(with: self) { owner, value in
                if value {
                    imageIndex.onNext(owner.imageIndex)
                } else {
                    
                }
            }
            .disposed(by: disposeBag)
        
        input.nickname
            .subscribe(with: self) { owner, value in
                print("닉네임 입력", value)
                description.onNext(owner.nicknameValidationResult(value))
                nickNameValid.onNext(owner.nicknameValid == nil)
                confirmButtonEnabled.onNext(owner.totalValid)
            }
            .disposed(by: disposeBag)
        
        input.mbtiSelected
            .subscribe(with: self) { owner, indexPath in
                print("mbti셀 선택", indexPath)
                if owner.mbtiList[indexPath.item] {
                    owner.mbtiList[indexPath.item] = false
                } else {
                    owner.mbtiList[indexPath.item] = true
                    owner.mbtiList[(indexPath.item + 4) % 8] = false
                }
                mbtiList.onNext(owner.mbtiList)
                confirmButtonEnabled.onNext(owner.totalValid)
            }
            .disposed(by: disposeBag)
        
        Observable.merge(
            input.confirmButtonTap.asObservable(),
            input.saveButtonTap.asObservable()
        )
        .withLatestFrom(input.nickname)
        .subscribe(with: self) { owner, value in
            print("확인 or 저장 버튼 탭", value)
            UserDefaultsManager.nickname = value
            UserDefaultsManager.profileImageIndex = owner.imageIndex
            UserDefaultsManager.mbti = owner.mbtiList
            // 여기서 분기 처리가 되어 있어서 merge를 해도 됨
            if UserDefaultsManager.signUpDate == nil {
                UserDefaultsManager.signUpDate = Date()
            }
        }
        .disposed(by: disposeBag)
        
        input.deleteAlertAction
            .bind(with: self) { owner, _ in
                print("회원탈퇴 얼럿 액션 -> 지우기")
                RealmRepository.shared.deleteAll()
                UserDefaultsManager.removeAll()
            }
            .disposed(by: disposeBag)
        
        return Output(
            imageIndex: imageIndex,
            mbtiList: mbtiList,
            savedNickname: savedNickname, 
            nickNameValid: nickNameValid,
            description: description,
            confirmButtonEnabled: confirmButtonEnabled, 
            confirmButtonTap: input.confirmButtonTap,
            saveButtonTap: input.saveButtonTap,
            withdrawButtonTap: input.withdrawButtonTap
        )
    }
    
    private enum NicknameValidationError: Error, LocalizedError {
        case length
        case invalidCharacter
        case number
        case whitespace
        
        var errorDescription: String {
            switch self {
            case .length: "2글자 이상 10글자 미만으로 설정해주세요"
            case .invalidCharacter: "닉네임에 @, #, $, % 는 포함할 수 없어요"
            case .number: "닉네임에 숫자는 포함할 수 없어요"
            case .whitespace: "닉네임에 공백은 포함할 수 없어요"
            }
        }
    }
    
    private func nicknameValidationResult(_ text: String) -> String {
        do {
            if try checkNickname(text) {
                nicknameValid = nil
                return "사용할 수 있는 닉네임이에요"
            }
        } catch let error as NicknameValidationError {
            nicknameValid = error
            return error.errorDescription
        } catch {
            print("알 수 없는 에러!")
        }
        return "알 수 없는 에러!"
    }
    
    private func checkNickname(_ text: String) throws -> Bool {
        // 1) 2글자 이상 10글자 미만
        guard text.count >= 2 && text.count < 10 else {
            throw NicknameValidationError.length
        }
        // 2) @, #, $, % 사용 불가
        let invalidCharacters = "@#$%"
        guard text.filter({ invalidCharacters.contains($0) }).isEmpty else {
            throw NicknameValidationError.invalidCharacter
        }
        // 3) 숫자 사용 불가
        guard text.filter({ $0.isNumber }).isEmpty else {
            throw NicknameValidationError.number
        }
        // 4) 공백 사용 불가
        guard text.filter({ $0.isWhitespace }).isEmpty else {
            throw NicknameValidationError.whitespace
        }
        return true
    }
}
