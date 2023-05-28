//
//  Chat.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import Foundation
struct Chat: Identifiable {
    var id: String
    var displayName: String
    var messages: [Message]
}
