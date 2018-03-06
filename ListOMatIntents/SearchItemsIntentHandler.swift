//
//  SearchItemsIntentHandler.swift
//  ListOMatIntents
//
//  Created by Louis Franco on 2/21/18.
//  Copyright © 2018 App-o-Mat. All rights reserved.
//

import Intents

class SearchItemsIntentHandler: ListOMatIntentsHandler, INSearchForNotebookItemsIntentHandling {

    func resolveItemType(for intent: INSearchForNotebookItemsIntent,
                         with completion: @escaping (INNotebookItemTypeResolutionResult) -> Void) {

        completion(.success(with: .taskList))
    }

    func resolveTitle(for intent: INSearchForNotebookItemsIntent, with completion: @escaping (INSpeakableStringResolutionResult) -> Void) {
        guard let title = intent.title else {
            completion(.needsValue())
            return
        }

        let possibleLists = getPossibleLists(for: title)
        completeResolveListName(with: possibleLists, for: title, with: completion)
    }

    func confirm(intent: INSearchForNotebookItemsIntent, completion: @escaping (INSearchForNotebookItemsIntentResponse) -> Void) {
        completion(INSearchForNotebookItemsIntentResponse(code: .success, userActivity: nil))
    }

    func handle(intent: INSearchForNotebookItemsIntent, completion: @escaping (INSearchForNotebookItemsIntentResponse) -> Void) {
        guard
            let title = intent.title,
            let list = loadLists().filter({ $0.name.lowercased() == title.spokenPhrase.lowercased()}).first
        else {
            completion(INSearchForNotebookItemsIntentResponse(code: .failure, userActivity: nil))
            return
        }

        let response = INSearchForNotebookItemsIntentResponse(code: .success, userActivity: nil)
        response.tasks = list.items.map {
            return INTask(title: INSpeakableString(spokenPhrase: $0.name),
                          status: $0.done ? INTaskStatus.completed : INTaskStatus.notCompleted,
                          taskType: INTaskType.notCompletable,
                          spatialEventTrigger: nil,
                          temporalEventTrigger: nil,
                          createdDateComponents: nil,
                          modifiedDateComponents: nil,
                          identifier: "\(list.name)\t\($0.name)")
        }
        completion(response)
    }
}
