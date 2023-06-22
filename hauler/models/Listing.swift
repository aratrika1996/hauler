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
        case locString
        case locLong
        case locLat
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
    var locString : String = ""
    var locLong : Double = 0.0
    var locLat : Double = 0.0
    
    init() {
        
    }
    
    init(id: String? = nil, title: String, desc: String, price: Double, email:String, imageURI: String, category: ListingCategory, available: Bool, createDate: Date, sellDate: Date, locString: String, locLong: Double, locLat : Double ) {
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
        self.locString = locString
        self.locLong = locLong
        self.locLat = locLat
    }
    
    init(id: String? = nil, title: String, desc: String, price: Double, email:String, image: UIImage?, imageURI: String, category: ListingCategory, available: Bool, createDate: Date, sellDate: Date , locString: String, locLong: Double, locLat : Double) {
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
        self.locString = locString
        self.locLong = locLong
        self.locLat = locLat
    }
    
//    public func encode(to encoder: Encoder) throws{
//        //
//    }
    
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
        self.locString = try container.decodeIfPresent(String.self, forKey: .locString) ?? "Unknown"
        self.locLong = try container.decodeIfPresent(Double.self, forKey: .locLong) ?? -79.5428673
        self.locLat = try container.decodeIfPresent(Double.self, forKey: .locLat) ?? 43.718371
        
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
        var locStr = "Unknown"
        var lon = 43.718371
        var lat = 79.5428673
        if let str = dictionary["locString"] as? String{
            locStr = str
        }else{
            print("unable to read loc String")
            print("casted to unknown")
        }
        
        if let Long = dictionary["locLong"] as? Double{
            lon = Long
        }else{
            print("unable to read loc long")
            print("casted to unknown")
        }
        
        if let Lat = dictionary["locLat"] as? Double{
            lat = Lat
        }else{
            print("unable to read loc lat")
            print("casted to unknown")
        }
        
        self.init(title: title, desc: desc, price: price, email: email, imageURI: imageURI, category: category, available: available, createDate: createDate, sellDate: sellDate, locString: locStr, locLong: lon, locLat: lat)
    }
    
    
    func printInfo() -> String {
        return "name: \(self.title)"
    }
}
