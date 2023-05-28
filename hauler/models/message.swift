//
//  message.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import Foundation
import FirebaseFirestoreSwift
import SwiftUI
import FirebaseFirestore



struct Message: Identifiable, Codable, Equatable {
    var id: String? = UUID().uuidString
    var fromId: String = ""
    var toId: String = ""
    var text: String = ""
    var timestamp: Timestamp

    init() {
        self.timestamp = Timestamp.init()
    }

    init(id: String? = nil, fromId: String, toId: String, text: String, timestamp: Timestamp) {
        self.id = id
        self.fromId = fromId
        self.toId = toId
        self.text = text
        self.timestamp = timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.fromId = try container.decode(String.self, forKey: .fromId)
        self.toId = try container.decode(String.self, forKey: .toId)
        self.text = try container.decode(String.self, forKey: .text)
        self.timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
    }

    init?(dictionary: [String: Any]) {
        guard let fromId = dictionary["fromId"] as? String else {
            print(#function, "Unable to read fromId from the object")
            return nil
        }

        guard let toId = dictionary["toId"] as? String else {
            print(#function, "Unable to read toId from the object")
            return nil
        }

        guard let text = dictionary["text"] as? String else {
            print(#function, "Unable to read text from the object")
            return nil
        }
        guard let timestamp = dictionary["timestamp"] as? Timestamp else {
            print(#function, "Unable to read timestamp from the object")
            return nil
        }

        self.init(fromId: fromId, toId: toId, text: text, timestamp: timestamp)
    }
}
