//
//  PostControler.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import Foundation
import FirebaseFirestore
import Firebase

class ListingController : ObservableObject{
    
    
    @Published var listingsList = [Listing]()
    private let store : Firestore
    private static var shared : ListingController?
    private let COLLECTION_LISTING : String = "Listing"
    private let COLLECTION_HAULER : String = "Hauler"
    private let FIELD_TITLE : String = "title"
    private let FIELD_DESC : String = "desc"
    private let FIELD_PRICE : String = "price"
    private let FIELD_IMAGE : String = "imageURI"
    private let FIELD_CATEGORY : String = "category"
    
    
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
        if (loggedInUserEmail.isEmpty){
            print(#function, "Logged in user not identified")
        }else{
            do{
                try self.store
                    .collection(COLLECTION_HAULER).document(loggedInUserEmail)
                    .collection(COLLECTION_LISTING)
                    .addDocument(from: listing)
            }catch let error as NSError{
                print(#function, "Unable to add document to firestore : \(error)")
            }
        }
    }
    
    
    func getAllListings(completion: @escaping ([Listing]?, Error?) -> Void) -> ListenerRegistration? {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        let listener = self.store.collection(COLLECTION_HAULER).document(loggedInUserEmail)
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
                print("orders: \(listings.count)")
                completion(listings, nil)
            }
        
        return listener
    }

    func updateListing(listingToUpdate: Listing, completion: @escaping (Error?) -> Void) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        self.store
            .collection(COLLECTION_HAULER).document(loggedInUserEmail)
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
}

