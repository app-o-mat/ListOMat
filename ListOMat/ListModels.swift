//
//  ListModels.swift
//  ListOMat
//
//  Created by Louis Franco on 2/11/18.
//  Copyright © 2018 App-o-Mat. All rights reserved.
//

import Foundation

struct ListItem: Decodable, Encodable {
    let name: String
    let done: Bool
}

struct List: Decodable, Encodable {
    let name: String
    let items: [ListItem]
}

typealias Lists = [List]

func addList(to lists: inout Lists, name: String, at index: Int) {
    lists.insert(List(name: name, items: []), at: index)
    save(lists: lists)
}

func removeList(from lists: inout Lists, at index: Int) {
    lists.remove(at: index)
    save(lists: lists)
}
