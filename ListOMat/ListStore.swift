//
//  ListStore.swift
//  ListOMat
//
//  Created by Louis Franco on 2/11/18.
//  Copyright © 2018 App-o-Mat. All rights reserved.
//

import Foundation

private let fileName = "lists.json"

func loadLists() -> Lists {
    guard let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return []
    }

    let url = docsDir.appendingPathComponent(fileName, isDirectory: false)

    guard FileManager.default.fileExists(atPath: url.path) else {
        return []
    }

    if let listsData = FileManager.default.contents(atPath: url.path) {
        let decoder = JSONDecoder()
        do {
            let lists = try decoder.decode(Lists.self, from: listsData)
            return lists
        } catch {
            return []
        }
    } else {
        return []
    }

}

func save(lists: Lists) {
    guard let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        fatalError("no docs dir")
    }

    let url = docsDir.appendingPathComponent(fileName, isDirectory: false)

    let encoder = JSONEncoder()
    do {
        let listData = try encoder.encode(lists)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        FileManager.default.createFile(atPath: url.path, contents: listData, attributes: nil)
    } catch {
        fatalError(error.localizedDescription)
    }
}
