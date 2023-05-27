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
    private let COLLECTION_PROFILE : String = "UserProfile"
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
                    .collection(COLLECTION_PROFILE)
                    .document(loggedInUserEmail)
                    .setData(from: newUserData)
            } catch let error as NSError {
                print("Unable to add document to firestore: \(error)")
            }
        }
        
    }
    
    
    func getAllUserData(completion: @escaping () -> Void) {
        guard let loggedInUserEmail = Auth.auth().currentUser?.email else {
            print("Logged in user not identified")
            return
        }
        
        print(#function, "current email", loggedInUserEmail)
        
        self.store
            .collection(COLLECTION_PROFILE)
            .whereField("uEmail", isEqualTo: loggedInUserEmail)
            .addSnapshotListener({ (querySnapshot, error) in
                guard let snapshot = querySnapshot else{
                    print("Unable to retrieve data from Firestore: ", error ?? "")
                    return
                }
                
                do {
                    var profileData = try snapshot.data(as: UserProfile.self)
                    let docId = snapshot.documentID
                    profileData.id = docId
                    
                    if snapshot.exists {
                        self.userProfile = profileData
                        self.userProfile.id = docId
                        print("profileData has been added/modified successfully!", profileData)
                    } else {
                        print("Document does not exist.")
                    }
                } catch let error  {
                    print(#function, "Unable to convert the document into an object:", error)
                }
                
                completion() // call completion handler when data is retrieved
            }
    }



    func updateUserData(userProfileToUpdate: UserProfile, completion: @escaping (Error?) -> Void) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
                
        self.store
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
    
    func deleteUserData(completion: @escaping () -> Void) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        self.store
            .collection(COLLECTION_PROFILE)
            .document(loggedInUserEmail)
            .delete {error in
                if let error = error {
                    print(#function, "Unable to delete user : \(error)")
                }
                else {
                    print(#function, "Successfully deleted user from firestore")
                }
                completion()
            }
    }

}



