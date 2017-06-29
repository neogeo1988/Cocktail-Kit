//
//  SearchService.swift
//  Cocktail Kit
//
//  Created by Thibault Deutsch on 16/06/2017.
//  Copyright © 2017 ATKF. All rights reserved.
//

import Foundation
import AlgoliaSearch
import RealmSwift

class SearchService {
    static let shared = SearchService()

    private let client = Client(appID: "QJD6ORETUC", apiKey: "b4815357a61bd83281803add2cd9f51b")
    private let index: Index

    private let realm = try! Realm()

    private var nbOfRecords = 0

    let favorites: Results<CocktailRecord>

    private init() {
        index = client.index(withName: "Cocktail-Kit")
        index.searchCacheEnabled = true

        favorites = realm.objects(CocktailRecord.self).filter("favorite == true")
    }

    func search(query: String, completion: @escaping (_ cocktails: [CocktailRecord]) -> Void) {
        index.search(Query(query: query)) { (res, err) in
            guard let res = res else { return }
            guard let nbHits = res["nbHits"] as? Int else { return }
            guard let hits = res["hits"] as? [[String: AnyObject]] else { return }

            if query.isEmpty {
                self.nbOfRecords = nbHits
            }

            var cocktails = [CocktailRecord]()
            try! self.realm.write {
                for hit in hits {
                    let cocktail = CocktailRecord(value: hit)
                    self.realm.add(cocktail, update: true)
                    cocktails.append(cocktail)
                }
            }

            completion(cocktails)
        }
    }

    func pickRandom(completion: @escaping (_ cocktail: CocktailRecord) -> Void) {
        let id = Int(arc4random_uniform(UInt32(nbOfRecords)))
        index.getObject(withID: "\(id)") { (res, err) in
            guard let res = res else { return }

            let cocktail = CocktailRecord(value: res)
            try! self.realm.write {
                self.realm.add(cocktail, update: true)
            }
            completion(cocktail)
        }
    }

    func write(_ block: (() -> Void)) {
        try! realm.write {
            block()
        }
    }
}
