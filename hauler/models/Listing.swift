//
//  Listing.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 19/05/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct Listing: Identifiable, Codable{
    
    @DocumentID var id :String? = UUID().uuidString
    var title : String = ""
    var desc : String = ""
    var price : Double = 0.0
    var imageURI : String = ""
    
    
    init(){
        
    }
    
    init(id: String? = nil, title: String, desc: String, price: Double, imageURI: String) {
        self.id = id
        self.title = title
        self.desc = desc
        self.price = price
        self.imageURI = imageURI
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.price = try container.decode(Double.self, forKey: .price)
        self.imageURI = try container.decode(String.self, forKey: .imageURI)
    }
    
    
    init?(dictionary: [String:Any]){
        
        guard let title = dictionary["title"] as? String else {
         print("unable to read title")
            return nil
        }
        
        guard let desc = dictionary["desc"] as? String else {
         print("unable to read desc")
            return nil
        }
        guard let price = dictionary["price"] as? Double else {
         print("unable to read price")
            return nil
        }
        guard let imageURI = dictionary["imageURI"] as? String else {
         print("unable to read image")
            return nil
        }
        
            self.init(title: title, desc: desc, price: price, imageURI: imageURI)
        }
    
    
    func printInfo()-> String{
        return("name: \(self.title)")
    }
}
