//
//  User.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import Foundation



struct UserProfile: Identifiable, Codable {
    var id :String? = UUID().uuidString
    var uName: String = ""
    var uEmail : String = ""
    var uPhone : String = ""
    var uAddress : String = ""
    var uLong : Double = 0.0
    var uLat : Double = 0.0
    var uProfileImageURL : String? = ""
    
    init(){
        
    }
    
    init(id: String? = nil, cName: String, cEmail: String, uPhone: String, uAddress: String, uLong: Double, uLat: Double, uProfileImageURL: String? = "") {
        self.id = id
        self.uName = cName
        self.uEmail = cEmail
        self.uAddress = uAddress
        self.uPhone = uPhone
        self.uLong = uLong
        self.uLat = uLat
        self.uProfileImageURL = uProfileImageURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.uName = try container.decode(String.self, forKey: .uName)
        self.uEmail = try container.decode(String.self, forKey: .uEmail)
        self.uAddress = try container.decode(String.self, forKey: .uAddress)
        self.uPhone = try container.decode(String.self, forKey: .uPhone)
        self.uLong = try container.decode(Double.self, forKey: .uLong)
        self.uLat = try container.decode(Double.self, forKey: .uLat)
        self.uProfileImageURL = try container.decode(String.self, forKey: .uProfileImageURL)
    }
    
    init?(dictionary : [String : Any]) {
        guard let name = dictionary["uName"] as? String else {
            print(#function, "Unable to read name from the object")
            return nil
        }
        
        guard let address = dictionary["uAddress"] as? String else {
            print(#function, "Unable to read address from the object")
            return nil
        }
        
        guard let email = dictionary["uEmail"] as? String else {
            print(#function, "Unable to read email from the object")
            return nil
        }
        
        guard let phone = dictionary["uPhone"] as? String else {
            print(#function, "Unable to read phone number from the object")
            return nil
        }
        
        guard let long = dictionary["uLong"] as? Double else {
            print(#function, "Unable to read longitude from the object")
            return nil
        }
        
        guard let lat = dictionary["uLat"] as? Double else {
            print(#function, "Unable to read latitude from the object")
            return nil
        }
        
        guard let profileImageURL = dictionary["uProfileImageURL"] as? String else {
            print(#function, "Unable to read latitude from the object")
            return nil
        }
        
        self.init(cName: name, cEmail: email, uPhone: phone, uAddress: address, uLong: long, uLat: lat, uProfileImageURL: profileImageURL)
    }
}
