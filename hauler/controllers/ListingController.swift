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



class ListingController : ObservableObject{
    
    
    @Published var listingsList = [Listing]()
    @Published var userListings = [Listing]()
    @Published var userAvailableListings = [Listing]()
    @Published var userSoldListings = [Listing]()
    @Published var sellerListings = [Listing]()
    @Published var adminMode = false
    @Published var searchText: String = ""
    @Published var selectedTokens : [ListingCategory] = []
    @Published var suggestedTokens : [ListingCategory] = ListingCategory.allCases
    @Published var favLists = [Listing]()
    
    
    private let store : Firestore
    private static var shared : ListingController?
    
    private let COLLECTION_LISTING : String = "Listing"
    private let FIELD_TITLE : String = "title"
    private let FIELD_DESC : String = "desc"
    private let FIELD_APPROVED : String = "approved"
    private let FIELD_PRICE : String = "price"
    private let FIELD_IMAGE : String = "imageURI"
    private let FIELD_CATEGORY : String = "category"
    private let FIELD_AVAILABLE : String = "available"
    private let FIELD_CREATEDATE : String = "createDate"
    private let FIELD_SELLDATE : String = "sellDate"
    
    private var all_listener : ListenerRegistration? = nil
    private var user_listener : ListenerRegistration? = nil
    
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
                .collection(COLLECTION_LISTING)
                .addDocument(from: listing)
        }catch let error as NSError{
            print(#function, "Unable to add document to firestore : \(error)")
        }
        //        }
    }
    
    func getAllListings(adminMode:Bool, completion: @escaping ([Listing]?, Error?) -> Void) {
        self.all_listener = self.store
            .collection(COLLECTION_LISTING)
            .whereField("approved", isEqualTo: !adminMode)
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
                DispatchQueue.main.async{
                    listings = listings.map{(li) -> Listing in
                        let dispatchGroup = DispatchGroup()
                        var img: UIImage? = nil
                        dispatchGroup.enter()
                        if let path = URL(string:li.imageURI){
                            path.fetchImage(completion: {
                                picData in
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
                        }
                        dispatchGroup.wait()
                        return Listing(id: li.id, title: li.title, desc: li.desc, price: li.price, email: li.email, image: img, imageURI: li.imageURI, category: li.category, available: li.available, createDate: li.createDate, sellDate: li.sellDate, locString: li.locString, locLong: li.locLong, locLat: li.locLat)
                    }
                    self.listingsList = listings
                    completion(listings, nil)
                }
                
                
            }
    }
    
    func getAllUserListings(completion: @escaping ([Listing]?, Error?) -> Void){
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
            self.user_listener = self
                .store
                .collection(COLLECTION_LISTING)
                .whereField("email", isEqualTo: loggedInUserEmail)
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
                    DispatchQueue.main.async {
                        listings = listings.map{(li) -> Listing in
                            let dispatchGroup = DispatchGroup()
                            var img: UIImage? = nil
                            dispatchGroup.enter()
                            if let path = URL(string: li.imageURI){
                                path.fetchImage(completion: {
                                    picData in
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
                            }
                            
                            dispatchGroup.wait()
                            return Listing(id: li.id, title: li.title, desc: li.desc, price: li.price, email: li.email, image: img, imageURI: li.imageURI, category: li.category, available: li.available, createDate: li.createDate, sellDate: li.sellDate, locString: li.locString, locLong: li.locLong, locLat: li.locLat)
                        }
                        self.userListings = listings
                        print(self.userListings)
                        completion(listings, nil)
                    }
        }
    }
    
    func getAllUserAvailableListings(completion: @escaping ([Listing]?, Error?) -> Void){
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
            self.user_listener = self
                .store
                .collection(COLLECTION_LISTING)
                .whereField("email", isEqualTo: loggedInUserEmail)
                .whereField("available", isEqualTo: true)
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
                    DispatchQueue.main.async {
                        listings = listings.map{(li) -> Listing in
                            let dispatchGroup = DispatchGroup()
                            var img: UIImage? = nil
                            dispatchGroup.enter()
                            if let link = URL(string: li.imageURI){
                                link.fetchImage(completion: {
                                    picData in
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
                            }
                            dispatchGroup.wait()
                            return Listing(id: li.id, title: li.title, desc: li.desc, price: li.price, email: li.email, image: img, imageURI: li.imageURI, category: li.category, available: li.available, createDate: li.createDate, sellDate: li.sellDate, locString: li.locString, locLong: li.locLong, locLat: li.locLat)
                        }
                        self.userAvailableListings = listings
                        //print(self.userListings)
                        completion(listings, nil)
                    }
        }
    }
    
    func getAllUserSoldListings(completion: @escaping ([Listing]?, Error?) -> Void){
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
            self.user_listener = self
                .store
                .collection(COLLECTION_LISTING)
                .whereField("email", isEqualTo: loggedInUserEmail)
                .whereField("available", isEqualTo: false)
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
                    DispatchQueue.main.async {
                        listings = listings.map{(li) -> Listing in
                            let dispatchGroup = DispatchGroup()
                            var img: UIImage? = nil
                            dispatchGroup.enter()
                            if let link = URL(string: li.imageURI){
                                link.fetchImage(completion: {
                                    picData in
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
                            }
                            dispatchGroup.wait()
                            return Listing(id: li.id, title: li.title, desc: li.desc, price: li.price, email: li.email, image: img, imageURI: li.imageURI, category: li.category, available: li.available, createDate: li.createDate, sellDate: li.sellDate, locString: li.locString, locLong: li.locLong, locLat: li.locLat)
                        }
                        self.userSoldListings = listings
                        //print(self.userListings)
                        completion(listings, nil)
                    }
        }
    }
    
    func getListingsByEmail(sellerEmail:String, completion: @escaping ([Listing]?, Error?) -> Void) {
        self.user_listener = self
            .store
            .collection(COLLECTION_LISTING)
            .whereField("email", isEqualTo: sellerEmail)
            .whereField("available", isEqualTo: true)
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
                DispatchQueue.main.async {
                    listings = listings.map{(li) -> Listing in
                        let dispatchGroup = DispatchGroup()
                        var img: UIImage? = nil
                        dispatchGroup.enter()
                        if let link = URL(string: li.imageURI){
                            link.fetchImage(completion: {
                                picData in
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
                        }
                        dispatchGroup.wait()
                        return Listing(id: li.id, title: li.title, desc: li.desc, price: li.price, email: li.email, image: img, imageURI: li.imageURI, category: li.category, available: li.available, createDate: li.createDate, sellDate: li.sellDate, locString: li.locString, locLong: li.locLong, locLat: li.locLat)
                    }
                    self.sellerListings = listings
                    //print(self.userListings)
                    completion(listings, nil)
                }
            }
    }
    
    func getListingByID(listingID:String, completion: @escaping (Listing?, Error?) -> Void) {
        self.favLists = []
        self
            .store
            .collection(COLLECTION_LISTING)
            .document(listingID)
            .getDocument { (document, error) in
                if let error = error {
                    print(#function, "Unable to retrieve data from Firestore : \(error)")
                    completion(nil, error)
                    return
                }
                
                var listing: Listing = Listing()
                
                
                    do {
                        listing = try document!.data(as: Listing.self)
                        listing.id = document?.documentID
                    } catch let error {
                        print(#function, "Unable to convert the document into object : \(error)")
                    }
                
                DispatchQueue.main.async {
                    
                        let dispatchGroup = DispatchGroup()
                        var img: UIImage? = nil
                        dispatchGroup.enter()
                        if let link = URL(string: listing.imageURI){
                            link.fetchImage(completion: {
                                picData in
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
                        }
                        dispatchGroup.wait()
                        listing = Listing(id: listing.id, title: listing.title, desc: listing.desc, price: listing.price, email: listing.email, image: img, imageURI: listing.imageURI, category: listing.category, available: listing.available, createDate: listing.createDate, sellDate: listing.sellDate, locString: listing.locString, locLong: listing.locLong, locLat: listing.locLat)
                    
                    self.favLists.append(listing)
                    //print(self.userListings)
                    completion(listing, nil)
                }
            }
    }
    
    func approveListings(listingsToUpdate: [Listing], completion: @escaping (Error?) -> Void){
        print(#function, "entered aprroving")
//        let dispatchGroup = DispatchGroup()
        for update in listingsToUpdate {
//            dispatchGroup.enter()
            self.store
                .collection(COLLECTION_LISTING)
                .document(update.id!)
                .updateData([
                    FIELD_APPROVED : true
                ], completion: {err in
                    if let err = err{
                        print(#function, "Update para failed")
                        completion(err)
                    }
//                    dispatchGroup.leave()
                }
                )
        }
//        dispatchGroup.wait()
        completion(nil)
    }
    
    func updateListing(listingToUpdate: Listing, newData: [String: Any]) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        self.store
            .collection(COLLECTION_LISTING)
            .document(listingToUpdate.id!)
            .setData(newData, merge: true) { error in
                if let error = error {
                    print(#function, "Unable to update document: \(error)")
                } else {
                    print(#function, "Successfully updated \(listingToUpdate) in Firestore")
                }
            }
    }
    
    
    func deleteListing(listingToDelete : Listing){
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        self.store
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
    
    func deleteAllUserListing(completion: @escaping () -> Void) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        let query =  self.store.collection(COLLECTION_LISTING).whereField("email", isEqualTo: loggedInUserEmail)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }

            guard let snapshot = snapshot else {
                print("No matching documents")
                return
            }

            // Iterate through each document and delete it
            for document in snapshot.documents {
                let documentRef = self.store.collection(self.COLLECTION_LISTING).document(document.documentID)

                documentRef.delete { error in
                    if let error = error {
                        print("Error deleting document \(documentRef.documentID): \(error)")
                    } else {
                        print("Document \(documentRef.documentID) successfully deleted")
                    }
                }
            }
            
            completion()
        }
        
    }
    
    func changeItemAvailabilityStatus(listingToUpdate: Listing, completion: @escaping (Error?) -> Void) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        self.store
            .collection(COLLECTION_LISTING)
            .document(listingToUpdate.id!)
            .updateData([
                FIELD_AVAILABLE : !listingToUpdate.available,
            ]) { error in
                if let error = error {
                    print(#function, "Unable to update document : \(error)")
                } else {
                    print(#function, "Successfully updated \(listingToUpdate) in the firestore")
                }
                completion(error)
            }
    }
    
    func removeAllListener(){
        self.all_listener?.remove()
    }
    func removeUserListener(){
        self.user_listener?.remove()
    }
    
//    func fetchImage(path: String, completion: @escaping (Data?) -> Void) {
//        print(#function, "fetch started")
//        if let imgPath = URL(string:path){
//            imgPath.asyncTask(Withcompletion: {retrievedData, httpResponse, error in
//                guard let data = retrievedData else {
//                    print("URLSession dataTask error:", error ?? "nil")
//                    return
//                }
//                if let error = error{
//                    print(#function, error)
//                }
//                if(retrievedData != nil){
//                    print(#function, "retrieved something")
//                    completion(data)
//                }else{
//                    print(#function, "nil returned")
//                }
//            })
//        }
//    }
}

