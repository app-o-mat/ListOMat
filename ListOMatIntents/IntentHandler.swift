//
//  IntentHandler.swift
//  ListOMatIntents
//
//  Created by Louis Franco on 1/13/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is CopyListIntent:
            return CopyListIntentHandler()
        case is INAddTasksIntent:
            return AddItemsIntentHandler()
        case is INSearchForNotebookItemsIntent:
            return SearchItemsIntentHandler()
        default:
            return self
        }
    }
    
}
