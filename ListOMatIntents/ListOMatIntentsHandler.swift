//
//  ListOMatIntentsHandler.swift
//  ListOMatIntents
//
//  Created by Louis Franco on 1/15/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import Intents

class ListOMatIntentsHandler: NSObject {

    func getPossibleLists(for listName: INSpeakableString) -> [INSpeakableString] {
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

    public func completeResolveTaskList(with possibleLists: [INSpeakableString],
                                        for listName: INSpeakableString,
                                        with completion: @escaping (INTaskListResolutionResult) -> Void) {

        // Convert the possibleLists into an array of INTaskList
        let taskLists = possibleLists.map {
            return INTaskList(title: $0, tasks: [], groupName: nil, createdDateComponents: nil, modifiedDateComponents: nil, identifier: nil)
        }

        // Look at the count of lists and respond accordingly
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
