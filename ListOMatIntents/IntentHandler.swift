//
//  IntentHandler.swift
//  ListOMatIntents
//
//  Created by Louis Franco on 2/19/18.
//  Copyright © 2018 App-o-Mat. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any? {
        switch intent {
        case is INSearchForNotebookItemsIntent:
            return SearchItemsIntentHandler()
        case is INAddTasksIntent:
            return AddItemsIntentHandler()
        default:
            return nil
        }
    }
}

class ListOMatIntentsHandler: NSObject {
    public func getPossibleLists(for listName: INSpeakableString) -> [INSpeakableString] {
        var possibleLists = [INSpeakableString]()
        for l in loadLists() {
            if l.name.lowercased() == listName.spokenPhrase.lowercased() {
                return [INSpeakableString(spokenPhrase: l.name)]
            }
            if l.name.lowercased().contains(listName.spokenPhrase.lowercased()) || listName.spokenPhrase.lowercased() == "all" {
                possibleLists.append(INSpeakableString(spokenPhrase: l.name))
            }
        }
        return possibleLists
    }

    public func completeResolveListName(with possibleLists: [INSpeakableString], for listName: INSpeakableString, with completion: @escaping (INSpeakableStringResolutionResult) -> Void) {
        switch possibleLists.count {
        case 0:
            completion(.unsupported())
        case 1:
            if possibleLists[0].spokenPhrase.lowercased() == listName.spokenPhrase.lowercased() {
                completion(.success(with: possibleLists[0]))
            } else {
                completion(.confirmationRequired(with: possibleLists[0]))
            }
        default:
            completion(.disambiguation(with: possibleLists))
        }
    }

    public func completeResolveTaskList(with possibleLists: [INSpeakableString], for listName: INSpeakableString, with completion: @escaping (INTaskListResolutionResult) -> Void) {

        let taskLists = possibleLists.map {
            return INTaskList(title: $0, tasks: [], groupName: nil, createdDateComponents: nil, modifiedDateComponents: nil, identifier: nil)
        }

        switch possibleLists.count {
        case 0:
            completion(.unsupported())
        case 1:
            if possibleLists[0].spokenPhrase.lowercased() == listName.spokenPhrase.lowercased() {
                completion(.success(with: taskLists[0]))
            } else {
                completion(.confirmationRequired(with: taskLists[0]))
            }
        default:
            completion(.disambiguation(with: taskLists))
        }
    }

}
