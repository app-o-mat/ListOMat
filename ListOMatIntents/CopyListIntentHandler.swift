//
//  CopyListIntentHandler.swift
//  ListOMatIntents
//
//  Created by Louis Franco on 6/10/18.
//  Copyright © 2018 App-o-Mat. All rights reserved.
//

import Foundation
import Intents

@available(iOS 12, *)
class CopyListIntentHandler: ListOMatIntentsHandler, CopyListIntentHandling {

    func handle(intent: CopyListIntent, completion: @escaping (CopyListIntentResponse) -> Void) {
        var lists = loadLists()
        guard
            let listName = intent.list?.lowercased(),
            let listIndex = lists.index(where: { $0.name.lowercased() == listName})
        else {
            completion(CopyListIntentResponse(code: .failure, userActivity: nil))
            return
        }

        copyList(from: &lists, atIndex: listIndex, toIndex: 0)
        save(lists: lists)
        let response = CopyListIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }

}
