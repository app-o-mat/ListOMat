//
//  ResetListIntentHandler.swift
//  ListOMatIntents
//
//  Created by Louis Franco on 1/20/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import Intents

@available(iOS 12, *)
class ResetListIntentHandler: ListOMatIntentsHandler, ResetListIntentHandling {

    func handle(intent: ResetListIntent, completion: @escaping (ResetListIntentResponse) -> Void) {
        // Load the lists
        var lists = loadLists()

        // Find the one we want to reset
        guard
            let listName = intent.list?.lowercased(),
            let listIndex = lists.index(where: { $0.name.lowercased() == listName})
            else {
                completion(ResetListIntentResponse(code: .failure, userActivity: nil))
                return
        }

        // Reset and save the lists
        resetList(from: &lists, atIndex: listIndex)
        save(lists: lists)

        // Respond back to Siri
        let response = ResetListIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }
}
