//
//  AddItemsIntentHandler.swift
//  ListOMatIntents
//
//  Created by Louis Franco on 1/15/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import Intents

class AddItemsIntentHandler: ListOMatIntentsHandler, INAddTasksIntentHandling {

    func resolveTargetTaskList(for intent: INAddTasksIntent, with completion: @escaping (INTaskListResolutionResult) -> Void) {

        guard let title = intent.targetTaskList?.title else {
            completion(.needsValue())
            return
        }

        let possibleLists = getPossibleLists(for: title)
        completeResolveTaskList(with: possibleLists, for: title, with: completion)
    }

    func handle(intent: INAddTasksIntent, completion: @escaping (INAddTasksIntentResponse) -> Void) {
        // Load the lists and find the index of the one we want
        var lists = loadLists()
        guard
            let taskList = intent.targetTaskList,
            let listIndex = lists.index(where: { $0.name.lowercased() == taskList.title.spokenPhrase.lowercased() }),
            let itemNames = intent.taskTitles, itemNames.count > 0
            else {
                completion(INAddTasksIntentResponse(code: .failure, userActivity: nil))
                return
        }

        // Get the list by index
        var list = lists[listIndex]

        // Add the items to the list
        var addedTasks = [INTask]()
        for item in itemNames {
            list.addItem(name: item.spokenPhrase, at: list.items.count)
            addedTasks.append(INTask(title: item, status: .notCompleted, taskType: .notCompletable, spatialEventTrigger: nil, temporalEventTrigger: nil, createdDateComponents: nil, modifiedDateComponents: nil, identifier: nil))
        }

        // Save the list
        lists[listIndex] = list
        save(lists: lists)

        // Respond back with the added items
        let response = INAddTasksIntentResponse(code: .success, userActivity: nil)
        response.addedTasks = addedTasks
        completion(response)

    }

}
