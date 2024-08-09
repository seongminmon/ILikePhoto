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
    // TODO: - edit일때 처음 닉네임 세팅 안 되는 문제
    
    struct Input {
        let settingOption: BehaviorSubject<SettingOption>
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
    private var mbtiList = [Bool](repeating: false, count: MBTI.list.count)
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let imageIndex = BehaviorSubject(value: 0)
        let mbtiList = BehaviorSubject<[Bool]>(value: [])
        let savedNickname = BehaviorSubject(value: "")
        let nickNameValid = BehaviorSubject(value: false)
        let description = PublishSubject<String>()
        let confirmButtonEnabled = BehaviorSubject(value: false)
        
        input.settingOption
            .subscribe(with: self) { owner, option in
                print("input.settingOption", option)
                switch option {
                case .create:
                    imageIndex.onNext(Int.random(in: 0..<MyImage.profileImageList.count))
                case .edit:
                    imageIndex.onNext(UserDefaultsManager.profileImageIndex)
                    owner.mbtiList = UserDefaultsManager.mbti
                    savedNickname.onNext(UserDefaultsManager.nickname)
                }
                mbtiList.onNext(owner.mbtiList)
                confirmButtonEnabled.onNext(owner.totalValid)
            }
            .disposed(by: disposeBag)
        
        input.nickname
            .subscribe(with: self) { owner, value in
                print("input.nickname", value)
                description.onNext(owner.nicknameValidationResult(value))
                nickNameValid.onNext(owner.nicknameValid == nil)
                confirmButtonEnabled.onNext(owner.totalValid)
            }
            .disposed(by: disposeBag)
        
        input.mbtiSelected
            .subscribe(with: self) { owner, indexPath in
                print("input.mbtiSelected", indexPath)
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
        
        input.confirmButtonTap
            .withLatestFrom(input.nickname)
            .subscribe(with: self) { owner, value in
                print("input.confirmButtonTap", value)
                UserDefaultsManager.nickname = value
                let imageIndex = try? imageIndex.value()
                UserDefaultsManager.profileImageIndex = imageIndex ?? 0
                UserDefaultsManager.mbti = owner.mbtiList
                if UserDefaultsManager.signUpDate == nil {
                    UserDefaultsManager.signUpDate = Date()
                }
            }
            .disposed(by: disposeBag)
        
        input.saveButtonTap
            .withLatestFrom(input.nickname)
            .subscribe(with: self) { owner, value in
                print("input.saveButtonTap", value)
                UserDefaultsManager.nickname = value
                let imageIndex = try? imageIndex.value()
                UserDefaultsManager.profileImageIndex = imageIndex ?? 0
                UserDefaultsManager.mbti = owner.mbtiList
                if UserDefaultsManager.signUpDate == nil {
                    UserDefaultsManager.signUpDate = Date()
                }
            }
            .disposed(by: disposeBag)
        
        input.deleteAlertAction
            .bind(with: self) { owner, _ in
                print("input.deleteAlertAction")
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
