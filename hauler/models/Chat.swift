//
//  Chat.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import Foundation
struct Chat: Identifiable, Hashable {
    var id: String
    var displayName: String
    var messages: [Message]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(displayName)
        hasher.combine(messages)
    }
}
