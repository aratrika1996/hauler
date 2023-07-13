//
//  Favorites.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-07-12.
//

import Foundation
import FirebaseFirestoreSwift

struct Favorites : Identifiable, Codable, Hashable {
    @DocumentID var id : String? = UUID().uuidString
    var listingID : String = ""
    
    init() {}
    
    init(listingID: String) {
        self.listingID = listingID
    }
    
    init?(dictionary : [String : Any]) {
        guard let listingID = dictionary["listingID"] as? String else {
            print(#function, "Unable to read listingID from the object")
            return nil
        }
        
        self.init(listingID: listingID)
    }
}
