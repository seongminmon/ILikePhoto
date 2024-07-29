//
//  SettingNicknameViewModel.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import Foundation

enum NicknameValidationError: Error, LocalizedError {
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

final class SettingNicknameViewModel: BaseViewModel {
    
    var nicknameValid: NicknameValidationError?
    
    // Input
    var inputViewDidLoad = Observable<SettingOption?>(nil)
    var inputProfileImageTap = Observable<Void?>(nil)
    var inputTextChange = Observable("")
    var inputCellSelected = Observable(0)
    var inputConfirmButtonTap = Observable<String>("")
    var inputDeleteButtonTap = Observable<Void?>(nil)
    
    // Output
    var outputImageIndex = Observable<Int?>(nil)
    var outputMbtiList = Observable<[Bool]>([])
    var outputNickname = Observable("")
    var outputDescriptionText = Observable("")
    var outputConfirmButtonEnabled = Observable(false)
    var outputPushSelectImageVC = Observable<Void?>(nil)
    var outputDeleteAll = Observable<Void?>(nil)
    
    override func transform() {
        inputViewDidLoad.bind { [weak self] option in
            guard let self, let option else { return }
            switch option {
            case .create:
                outputImageIndex.value = Int.random(in: 0..<MyImage.profileImageList.count)
                outputMbtiList.value = [Bool](repeating: false, count: MBTI.list.count)
            case .edit:
                outputImageIndex.value = UserDefaultsManager.profileImageIndex
                outputMbtiList.value = UserDefaultsManager.mbti
                outputNickname.value = UserDefaultsManager.nickname
            }
            nicknameValidationResult(outputNickname.value)
            outputConfirmButtonEnabled.value = checkConfirmEnabled()
        }
        
        inputProfileImageTap.bind { [weak self] _ in
            guard let self else { return }
            outputPushSelectImageVC.value = ()
        }
        
        inputTextChange.bind { [weak self] text in
            guard let self else { return }
            nicknameValidationResult(text)
            outputConfirmButtonEnabled.value = checkConfirmEnabled()
        }
        
        inputCellSelected.bind { [weak self] index in
            guard let self else { return }
            if outputMbtiList.value[index] {
                outputMbtiList.value[index] = false
            } else {
                outputMbtiList.value[index] = true
                outputMbtiList.value[(index + 4) % 8] = false
            }
            outputConfirmButtonEnabled.value = checkConfirmEnabled()
        }
        
        inputConfirmButtonTap.bind { [weak self] nickname in
            guard let self else { return }
            UserDefaultsManager.nickname = nickname
            UserDefaultsManager.profileImageIndex = outputImageIndex.value ?? 0
            UserDefaultsManager.mbti = outputMbtiList.value
            if UserDefaultsManager.signUpDate == nil {
                UserDefaultsManager.signUpDate = Date()
            }
        }
        
        inputDeleteButtonTap.bind { [weak self] _ in
            guard let self else { return }
            RealmRepository.shared.deleteAll()
            UserDefaultsManager.removeAll()
            outputDeleteAll.value = ()
        }
    }
    
    private func nicknameValidationResult(_ text: String) {
        do {
            if try checkNickname(text) {
                nicknameValid = nil
                outputDescriptionText.value = "사용할 수 있는 닉네임이에요"
            }
        } catch let error as NicknameValidationError {
            nicknameValid = error
            outputDescriptionText.value = error.errorDescription
        } catch {
            print("알 수 없는 에러!")
        }
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
    
    private func checkMBTI() -> Bool {
        return outputMbtiList.value.filter { $0 }.count == 4
    }
    
    private func checkConfirmEnabled() -> Bool {
        return nicknameValid == nil && checkMBTI()
    }
}
