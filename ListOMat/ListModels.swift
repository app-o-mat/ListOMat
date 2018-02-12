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
    var items: [ListItem]

    mutating func addItem(name: String, at index: Int) {
        items.insert(ListItem(name: name, done: false), at: index)
    }

    mutating func removeItem(at index: Int) {
        items.remove(at: index)
    }
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

func addListItem(to list: inout List, name: String, at index: Int) {
    list.addItem(name: name, at: index)
}

func removeListItem(from list: inout List, at index: Int) {
    list.removeItem(at: index)
}
