//
//  Chat.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import Foundation
struct Chat: Codable, Identifiable, Hashable {
    var participants: [String]
    var id: String
    var displayName: String
    var messages: [Message]
    var unread: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case participants
        case id
        case displayName
        case messages
    }
    
    init(participants: [String], id: String, displayName: String, messages: [Message]){
        self.participants = participants
        self.id = id
        self.displayName = displayName
        self.messages = messages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.participants = try container.decode([String].self, forKey: .participants)
        self.messages = try container.decode([Message].self, forKey: .messages)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        //
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(displayName)
        hasher.combine(messages)
    }
    
    mutating func addUnread () {
        self.unread += 1
    }
    
    mutating func minusUnread () {
        self.unread -= 1
    }
    
    mutating func resetUnread () {
        self.unread = 0
    }
}
