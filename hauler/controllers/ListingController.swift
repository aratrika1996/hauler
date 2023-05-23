//
//  PostControler.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import Foundation
import FirebaseFirestore
import Firebase
import Combine

extension URL {
    func asyncTask(Withcompletion completion: @Sendable @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()){
        URLSession.shared
            .dataTask(with: self, completionHandler: completion)
            .resume()
    }
}

class ListingController : ObservableObject{
    
    
    @Published var listingsList = [Listing]()
    private let store : Firestore
    private static var shared : ListingController?
    private let COLLECTION_LISTING : String = "Listing"
    private let COLLECTION_HAULER : String = "Hauler"
    private let COLLECTION_ITEM : String = "items"
    private let FIELD_TITLE : String = "title"
    private let FIELD_DESC : String = "desc"
    private let FIELD_PRICE : String = "price"
    private let FIELD_IMAGE : String = "imageURI"
    private let FIELD_CATEGORY : String = "category"
    private var all_listener : ListenerRegistration? = nil
    private var user_listener : ListenerRegistration? = nil
    @Published var searchText: String = ""
    @Published var selectedTokens : [ListingCategory] = []
    @Published var suggestedTokens : [ListingCategory] = ListingCategory.allCases

    var filteredList: [Listing]{
        var list = self.listingsList
        if(selectedTokens.count > 0){
            for token in selectedTokens {
                    list = list.filter{$0.category.containsTag(cat: token)}
            }
        }
        if(searchText.count > 0){
            list = list.filter{$0.title.localizedCaseInsensitiveContains(searchText)}
        }
        return list
    }
    
    var loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
    
    init(store: Firestore) {
        self.store = store
    }
    
    static func getInstance() -> ListingController?{
        if (shared == nil){
            shared = ListingController(store: Firestore.firestore())
        }
        
        return shared
    }
    
    func insertListing(listing : Listing){
//        if (loggedInUserEmail.isEmpty){
//            print(#function, "Logged in user not identified")
//        }else{
            do{
                try self.store
                    .collection(COLLECTION_HAULER)
                    .document(COLLECTION_ITEM)
                    .collection(COLLECTION_LISTING)
                    .addDocument(from: listing)
            }catch let error as NSError{
                print(#function, "Unable to add document to firestore : \(error)")
            }
//        }
    }
    
    func getAllListings(completion: @escaping ([Listing]?, Error?) -> Void) {
        self.all_listener = self.store
            .collection(COLLECTION_HAULER)
            .document(COLLECTION_ITEM)
            .collection(COLLECTION_LISTING)
            .whereField("approved", isEqualTo: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print(#function, "Unable to retrieve data from Firestore : \(error)")
                    completion(nil, error)
                    return
                }
                
                var listings: [Listing] = []
                
                querySnapshot?.documents.forEach { document in
                    do {
                        var listing: Listing = try document.data(as: Listing.self)
                        listing.id = document.documentID
                        listings.append(listing)
                    } catch let error {
                        print(#function, "Unable to convert the document into object : \(error)")
                    }
                }
                
                listings = listings.map{(li) -> Listing in
                    let dispatchGroup = DispatchGroup()
                    var img: UIImage? = nil
                    dispatchGroup.enter()
                    self.fetchImage(path: li.imageURI, completion: {picData in
                        if let picData = picData{
                            if let Uiimage = UIImage(data: picData){
                                img = Uiimage
                                dispatchGroup.leave()
                            }else{
                                print(#function, "Cast uiImage Error")
                            }
                        }else{
                            print(#function, "no picData")
                        }
                    })
                    dispatchGroup.wait()
                    return Listing(id: li.id, title: li.title, desc: li.desc, price: li.price, email: li.email, image: img, imageURI: li.imageURI, category: li.category)
                }
                
                self.listingsList = listings
                completion(listings, nil)
            }
    }
    
    
    
    
    func getAllUserListings(completion: @escaping ([Listing]?, Error?) -> Void) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        self.user_listener = self.store.collection(COLLECTION_HAULER).document(loggedInUserEmail)
            .collection(COLLECTION_LISTING).addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print(#function, "Unable to retrieve data from Firestore : \(error)")
                    completion(nil, error)
                    return
                }
                
                var listings: [Listing] = []
                
                querySnapshot?.documents.forEach { document in
                    do {
                        var listing: Listing = try document.data(as: Listing.self)
                        listing.id = document.documentID
                        
                        listings.append(listing)
                    } catch let error {
                        print(#function, "Unable to convert the document into object : \(error)")
                    }
                }
                DispatchQueue.main.async {
                    self.listingsList = self.listingsList.map{(li) -> Listing in
                        let dispatchGroup = DispatchGroup()
                        var img: UIImage? = nil
                        dispatchGroup.enter()
                        self.fetchImage(path: li.imageURI, completion: {picData in
                            if let picData = picData{
                                if let Uiimage = UIImage(data: picData){
                                    img = Uiimage
                                    dispatchGroup.leave()
                                }else{
                                    print(#function, "Cast uiImage Error")
                                }
                            }else{
                                print(#function, "no picData")
                            }
                        })
                        return Listing(title: li.title, desc: li.desc, price: li.price, email: li.email, image: img, imageURI: li.imageURI, category: li.category)
                    }
                    
                }
                print("orders: \(listings.count)")
                completion(listings, nil)
            }
    }
    
    
    func updateListing(listingToUpdate: Listing, completion: @escaping (Error?) -> Void) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        self.store
            .collection(COLLECTION_HAULER)
            .document(loggedInUserEmail)
            .collection(COLLECTION_LISTING)
            .document(listingToUpdate.id!)
            .updateData([
                FIELD_TITLE : listingToUpdate.title,
                FIELD_PRICE : listingToUpdate.price,
                FIELD_DESC : listingToUpdate.desc,
                FIELD_IMAGE : listingToUpdate.imageURI,
                FIELD_CATEGORY : listingToUpdate.category,
            ]) { error in
                if let error = error {
                    print(#function, "Unable to update document : \(error)")
                } else {
                    print(#function, "Successfully updated \(listingToUpdate) in the firestore")
                }
                completion(error)
            }
    }
    
    
    func deleteListing(listingToDelete : Listing){
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        self.store
            .collection(COLLECTION_HAULER).document(loggedInUserEmail)
            .collection(COLLECTION_LISTING)
            .document(listingToDelete.id!)
            .delete{error in
                
                if let error = error {
                    print(#function, "Unable to delete document : \(error)")
                }else{
                    print(#function, "Successfully deleted \(listingToDelete) from the firestore")
                }
                
            }
    }
    
    func removeAllListener(){
        self.all_listener?.remove()
    }
    func removeUserListener(){
        self.user_listener?.remove()
    }
    
    func fetchImage(path: String, completion: @escaping (Data?) -> Void) {
        print(#function, "fetch started")
        if let imgPath = URL(string:path){
            imgPath.asyncTask(Withcompletion: {retrievedData, httpResponse, error in
                guard let data = retrievedData else {
                    print("URLSession dataTask error:", error ?? "nil")
                    return
                }
                if(retrievedData != nil){
                    print(#function, "retrieved something")
                    completion(data)
                }else{
                    print(#function, "nil returned")
                }
            })
        }
    }
}

