//
//  UserProfileController.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import Foundation
import FirebaseFirestore
import Firebase

class UserProfileController : ObservableObject{
    
    
    @Published var userProfile = UserProfile()
    private let store : Firestore
    private static var shared : UserProfileController?
    private let COLLECTION_PROFILE : String = "User_Profile"
    private let COLLECTION_HAULER : String = "Hauler"
        private let FIELD_NAME = "uName"
        private let FIELD_CONTACT_NUMBER = "uPhone"
        private let FIELD_ADDRESS = "uAddress"
        private let FIELD_LONG = "uLong"
        private let FIELD_LAT = "uLat"
    
    
    var loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
    
    init(store: Firestore) {
        self.store = store
    }
    
    static func getInstance() -> UserProfileController?{
        if (shared == nil){
            shared = UserProfileController(store: Firestore.firestore())
        }
        
        return shared
    }
    
    func insertUserData(newUserData: UserProfile){
        print(#function, "Trying to insert \(newUserData.uName) to DB")
        print(#function, "current email", loggedInUserEmail)
        
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        
        if loggedInUserEmail.isEmpty{
            print("Logged in user not identified")
        }
        else{
            do{
                try self.store
                    .collection(COLLECTION_HAULER).document(loggedInUserEmail)
                    .collection(COLLECTION_PROFILE).addDocument(from: newUserData)
            } catch let error as NSError {
                print("Unable to add document to firestore: \(error)")
            }
        }
        
    }
    
    
    func getAllUserData(completion: @escaping () -> Void) {
        
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        
        print(#function, "current email", loggedInUserEmail)
        
        self.store
            .collection(COLLECTION_HAULER).document(loggedInUserEmail)
            .collection(COLLECTION_PROFILE)
            .addSnapshotListener({ (querySnapshot, error) in
                guard let snapshot = querySnapshot else{
                    print("Unable to retrieve data from Firestore: ", error ?? "")
                    return
                }
                snapshot.documentChanges.forEach{(docChange) in
                    do{
                        var profileData = try docChange.document.data(as: UserProfile.self)
                        let docId = docChange.document.documentID
                        profileData.id = docId
                        
                        if docChange.type == .added{
                            self.userProfile = profileData
                            self.userProfile.id = docId
                            print("profileData has been added successfully!", profileData)
                        }
                        
                        if docChange.type == .modified{
                            self.userProfile = profileData
                        }
                    }
                    catch let err as Error{
                        print(#function, "Unable to convert the document into object", err)
                    }
                }
                completion() // call completion handler when data is retrieved
            })
    }

    func updateUserData(userProfileToUpdate: UserProfile, completion: @escaping (Error?) -> Void) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
                
        self.store
            .collection(COLLECTION_HAULER).document(loggedInUserEmail)
            .collection(COLLECTION_PROFILE).document(userProfileToUpdate.id!)
            .updateData(
                [
                    FIELD_NAME : userProfileToUpdate.uName,
                    FIELD_CONTACT_NUMBER : userProfileToUpdate.uPhone,
                    FIELD_ADDRESS : userProfileToUpdate.uAddress,
                    FIELD_LONG : userProfileToUpdate.uLong,
                    FIELD_LAT : userProfileToUpdate.uLat,
                ]
            ) { error in
                completion(error)
            }
    }

}

