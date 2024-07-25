//
//  UserDefaultsManager.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

enum UserDefaultsManager {
    
    private enum Key: String, CaseIterable {
        case nickname
        case profileImageIndex
        case mbti
        case signUpDate
    }
    
    @UserDefault(key: Key.nickname.rawValue, defaultValue: "")
    static var nickname: String
    
    @UserDefault(key: Key.profileImageIndex.rawValue, defaultValue: 0)
    static var profileImageIndex: Int
    
    @UserDefault(key: Key.mbti.rawValue, defaultValue: [])
    static var mbti: [Bool]
    
    @UserDefault(key: Key.signUpDate.rawValue, defaultValue: nil)
    static var signUpDate: Date?
    
    static func removeAll() {
        UserDefaults.standard.dictionaryRepresentation().keys.forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }
}
