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
    
    var fileURL: URL? {
        return realm.configuration.fileURL
    }
    
    var schemaVersion: UInt64? {
        guard let fileURL = fileURL else { return nil }
        return try? schemaVersionAtURL(fileURL)
    }
    
    // MARK: - Create
    func addItem(_ item: LikedPhoto) {
        try! realm.write {
            realm.add(item)
            print("Realm Create!")
        }
    }
    
    // MARK: - Read
    func fetchAll(_ ascending: Bool) -> [LikedPhoto] {
        let value = realm.objects(LikedPhoto.self)
            .sorted(byKeyPath: "date", ascending: ascending)
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
            try! realm.write {
                realm.delete(item)
                print("Realm Delete!")
            }
        }
    }
    
    func deleteAll() {
        try! realm.write {
            let photos = realm.objects(LikedPhoto.self)
            realm.delete(photos)
            print("Realm Delete All!")
        }
    }
}
