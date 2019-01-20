//
//  CopyListIntentHandler.swift
//  ListOMatIntents
//
//  Created by Louis Franco on 1/19/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import Intents

@available(iOS 12, *)
class CopyListIntentHandler: ListOMatIntentsHandler, CopyListIntentHandling {

    func handle(intent: CopyListIntent, completion: @escaping (CopyListIntentResponse) -> Void) {
        // Load the lists
        var lists = loadLists()

        // Find the one we want to copy
        guard
            let listName = intent.list?.lowercased(),
            let listIndex = lists.index(where: { $0.name.lowercased() == listName})
            else {
                completion(CopyListIntentResponse(code: .failure, userActivity: nil))
                return
        }

        // Copy and save the lists
        copyList(from: &lists, atIndex: listIndex, toIndex: 0)
        save(lists: lists)

        // Respond back to Siri
        let response = CopyListIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }
}
