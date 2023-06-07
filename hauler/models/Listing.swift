//
//  Listing.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 19/05/2023.
//

import Foundation
import FirebaseFirestoreSwift
import SwiftUI


enum ListingCategory: String, Hashable, CaseIterable, Codable, Identifiable {
    case electronics = "Electronics"
    case fashionAndClothing = "Fashion and Clothing"
    case homeAndFurniture = "Home and Furniture"
    case sportsAndFitness = "Sports and Fitness"
    case other = "Other"
    
    var id:String{rawValue}
    
    var displayName: String {
        return self.rawValue
    }
    
    func icon() -> String {
        switch self {
        case .electronics:
            return "iphone.gen3"
        case .fashionAndClothing:
            return "tshirt"
        case .homeAndFurniture:
            return "house.fill"
        case .sportsAndFitness:
            return "dumbbell"
        case .other:
            return "questionmark.app"
        }
    }
    func containsTag(cat:ListingCategory) -> Bool{
        return (self == cat) ? true : false
    }
    
}

struct Listing: Identifiable, Codable, Hashable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case desc
        case price
        case email
        case imageURI
        case category
        case approved
        case available
        case createDate
        case sellDate
    }
    
    @DocumentID var id: String? = nil
    var title: String = ""
    var desc: String = ""
    var price: Double = 0.0
    var imageURI: String = ""
    var image: UIImage? = nil
    var email: String = ""
    var approved: Bool = false
    var category: ListingCategory = .other
    var available : Bool = true
    var createDate : Date = Date.now
    var sellDate : Date = Date.now
    
    init() {
        
    }
    
    init(id: String? = nil, title: String, desc: String, price: Double, email:String, imageURI: String, category: ListingCategory, available: Bool, createDate: Date, sellDate: Date) {
        self.id = id
        self.title = title
        self.desc = desc
        self.price = price
        self.email = email
        self.imageURI = imageURI
        self.category = category
        self.available = available
        self.createDate = createDate
        self.sellDate = sellDate
    }
    
    init(itemToApprove: Listing) {
        self.id = itemToApprove.id
        self.title = itemToApprove.title
        self.desc = itemToApprove.desc
        self.price = itemToApprove.price
        self.email = itemToApprove.email
        self.imageURI = itemToApprove.imageURI
        self.category = itemToApprove.category
        self.approved = true
        self.available = itemToApprove.available
        self.createDate = itemToApprove.createDate
        self.sellDate = itemToApprove.sellDate
    }
    
    init(id: String? = nil, title: String, desc: String, price: Double, email:String, image: UIImage?, imageURI: String, category: ListingCategory, available: Bool, createDate: Date, sellDate: Date) {
        self.id = id
        self.title = title
        self.desc = desc
        self.price = price
        self.image = image
        self.email = email
        self.imageURI = imageURI
        self.category = category
        self.available = available
        self.createDate = createDate
        self.sellDate = sellDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.price = try container.decode(Double.self, forKey: .price)
        self.email = try container.decode(String.self, forKey: .email)
        self.imageURI = try container.decode(String.self, forKey: .imageURI)
        self.category = try container.decode(ListingCategory.self, forKey: .category)
        self.approved = try container.decode(Bool.self, forKey: .approved)
        self.available = try container.decode(Bool.self, forKey: .available)
        self.createDate = try container.decode(Date.self, forKey: .createDate)
        self.sellDate = try container.decode(Date.self, forKey: .sellDate)
    }
    
    
    init?(dictionary: [String: Any]) {
        
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
        
        guard let categoryString = dictionary["category"] as? String,
              let category = ListingCategory(rawValue: categoryString) else {
            print("unable to read category")
            return nil
        }
        
        guard let email = dictionary["email"] as? String else {
            print("unable to read email")
            return nil
        }
        
        guard let available = dictionary["available"] as? Bool else {
            print("unable to read listing status")
            return nil
        }
        
        guard let createDate = dictionary["createDate"] as? Date else {
            print("unable to read creation date")
            return nil
        }
        
        guard let sellDate = dictionary["sellDate"] as? Date else {
            print("unable to read selling date")
            return nil
        }
        
        self.init(title: title, desc: desc, price: price, email: email, imageURI: imageURI, category: category, available: available, createDate: createDate, sellDate: sellDate)
    }
    
    
    func printInfo() -> String {
        return "name: \(self.title)"
    }
}
