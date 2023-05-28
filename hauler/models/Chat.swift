//
//  Chat.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import Foundation
class Chat: Identifiable {
    var id: String
    var displayName: String
    var messages: [Message]
    
    init(id: String, displayName: String, messages: [Message]) {
        self.id = id
        self.displayName = displayName
        self.messages = messages
    }
}
