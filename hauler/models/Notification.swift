//
//  Notification.swift
//  hauler
//
//  Created by Homing Lau on 2023-07-18.
//

import Foundation
import FirebaseFirestoreSwift
import SwiftUI
import FirebaseFirestore

struct Notification: Identifiable, Codable, Hashable {
    var id :String? = nil
    var createdBy : String = "system"
    var item : String? = nil
    var msg : String? = nil
    var timestamp : Timestamp = Timestamp.init()
    var unread : Bool = true
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdBy
        case item
        case msg
        case timestamp
        case unread
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.createdBy = try container.decode(String.self, forKey: .createdBy)
        self.item = try container.decodeIfPresent(String.self, forKey: .item)
        self.msg = try container.decodeIfPresent(String.self, forKey: .msg)
        self.timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        self.unread = try container.decode(Bool.self, forKey: .unread)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(createdBy)
        hasher.combine(item)
        hasher.combine(msg)
        hasher.combine(timestamp)
    }
}
