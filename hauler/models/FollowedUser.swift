//
//  FollowedUser.swift
//  hauler
//
//  Created by Homing Lau on 2023-07-18.
//

import Foundation
import FirebaseFirestoreSwift
import SwiftUI
import FirebaseFirestore

struct FollowedUser: Identifiable, Codable, Hashable {
    var id :String? = nil
    var email :String = ""
    var timestamp : Date = Date()
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case timestamp
    }
    
    init(email: String){
        self.email = email
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.timestamp, forKey: .timestamp)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.email)
        hasher.combine(self.timestamp)
    }
}
