//
//  RealmRepository.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/25/24.
//

import Foundation
import RealmSwift

final class RealmRepository {
    
    static let shared = RealmRepository()
    private init() {}
    
    private let realm = try! Realm()
    
//    private let realm: Realm
//    init() throws {
//        self.realm = try Realm()
//    }
    
//    do {
//        let realm = try Realm()
//    } catch {
//        print("Realm 초기화 실패!")
//    }
    
    var fileURL: URL? {
        return realm.configuration.fileURL
    }
    
    var schemaVersion: UInt64? {
        guard let fileURL = fileURL else { return nil }
        return try? schemaVersionAtURL(fileURL)
    }
    
    // MARK: - Create
    func addItem(_ item: LikedPhoto) {
        do {
            try realm.write {
                realm.add(item)
                print("Realm Create!")
            }
        } catch {
            print("Realm Create Failed")
        }
    }
    
    // MARK: - Read
    func fetchAll(order: LikeSearchOrder, color: Set<SearchColor>) -> [LikedPhoto] {
        var value = realm.objects(LikedPhoto.self)
            .sorted(byKeyPath: "date", ascending: order == .ascending)
        for item in color {
            value = value.where {
                $0.color == item.colorValue
            }
        }
        return Array(value)
    }
    
    func fetchItem(_ id: String) -> LikedPhoto? {
        return realm.object(ofType: LikedPhoto.self, forPrimaryKey: id)
    }
    
    // MARK: - Update
    func updateItem(_ item: LikedPhoto) {
        //
    }
    
    // MARK: - Delete
    func deleteItem(_ id: String) {
        if let item = fetchItem(id) {
            do {
                try realm.write {
                    realm.delete(item)
                    print("Realm Delete!")
                }
            } catch {
                print("Realm Delete Failed")
            }
        }
    }
    
    func deleteAll() {
        do {
            try realm.write {
                let photos = realm.objects(LikedPhoto.self)
                for item in photos {
                    ImageFileManager.shared.deleteImageFile(filename: item.id)
                    ImageFileManager.shared.deleteImageFile(filename: item.id + "user")
                }
                realm.delete(photos)
                print("Realm Delete All!")
            }
        } catch {
            print("Realm Delete All Failed")
        }
    }
}
