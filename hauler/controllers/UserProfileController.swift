//
//  UserProfileController.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import Foundation
import FirebaseFirestore
import Firebase
//import Combine

class UserProfileController : ObservableObject{
    
    
    @Published var userProfile = UserProfile()
    @Published var publicProfile = UserProfile()
    
    @Published var userDict : [String : UserProfile] = [:]
    
    @Published var loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
    private let store : Firestore
    private static var shared : UserProfileController?
    private let COLLECTION_PROFILE : String = "UserProfile"
    private let FIELD_NAME = "uName"
    private let FIELD_CONTACT_NUMBER = "uPhone"
    private let FIELD_ADDRESS = "uAddress"
    private let FIELD_LONG = "uLong"
    private let FIELD_LAT = "uLat"
    private let FIELD_PROFILE_IMAGE = "uProfileImageURL"
    private let db = Firestore.firestore()
    
    
    init(store: Firestore) {
        self.store = store
        self.loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
    }
    
    static func getInstance() -> UserProfileController?{
        if (shared == nil){
            shared = UserProfileController(store: Firestore.firestore())
        }
        
        return shared
    }
    
    func loginInitialize(who: String){
        self.loggedInUserEmail = who
    }
    
    func logoutClear(){
        userProfile = UserProfile()
        publicProfile = UserProfile()
        DispatchQueue.main.async {
            self.userDict.removeAll()
        }
        loggedInUserEmail = ""
    }
    
    func updateLoggedInUser(){
        self.loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
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
    
    func getPublicProfileByEmail(email: String, completion: @escaping (UserProfile?, Bool) -> Void) {
        let db = Firestore.firestore()
        
        db.collection(COLLECTION_PROFILE).document(email).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user document: \(error)")
                completion(nil, false)
                return
            }
            
            if let data = snapshot?.data(), let user = try? Firestore.Decoder().decode(UserProfile.self, from: data) {
                self.publicProfile = user
                completion(user, true)
            } else {
                completion(nil, false)
            }
        }
    }
    
    func getUserByEmail(email: String, completion: @escaping (UserProfile?, Bool) -> Void) {
        
        if loggedInUserEmail == email{
            print(#function, "finished with myself")
            completion(userProfile, true)
        }
        if let localprofile = self.userDict[email]{
            print(#function, "finished with local userdict")
            completion(localprofile, true)
            return
        }
        print(#function, "fetch new up: \(email)")
        DispatchQueue.main.async {
            self.store.collection(self.COLLECTION_PROFILE)
                .document(email)
                .getDocument { [weak self] snapshot, error in
                    print(#function, "start fetching")
                    guard let self = self else { return } // Make sure self is captured weakly
                    if let error = error {
                        print("Error fetching user document: \(error)")
                        //                    completion(nil, false)
                        return
                    }
                    
                    
                    if let snapshot = snapshot {
                        print(#function, "got snapshot, id=\(snapshot.documentID)")
                    } else {
                        print(#function, "Cannot get snapshot")
                        //                    completion(nil, false)
                        return
                    }
                    
                    if let data = snapshot?.data() {
                        if let tempuser = UserProfile(dictionary: data) {
                            var user = tempuser
                            if email == self.loggedInUserEmail && self.userProfile.uProfileImage != nil {
                                self.userProfile = user
                                completion(user, true)
                            } else {
                                self.putUserInDict(userIn: user, completion: {userWithPic in
                                    print(#function, "added \(userWithPic.uName) with Pic")
                                    completion(userWithPic, true)
                                })
                            }
                            
                        }
                    } else {
                        print(#function, "Return with nil, reason: data = nil")
                        completion(nil, false)
                    }
                }
        }
        
        
    }
    
    func putUserInDict(userIn: UserProfile, completion: @escaping (UserProfile) -> Void){
        
        var user = userIn
        if let userimgpath = user.uProfileImageURL {
            if !userimgpath.isEmpty && userimgpath != "" {
                if let userimgurl = URL(string: userimgpath) {
                    userimgurl.fetchImage(completion: { [weak self] data in
                        guard let self = self else { return } // Make sure self is captured weakly
                        if let data = data {
                            if let userimg = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    user = UserProfile(up: user, img: userimg)
                                    self.userDict[user.uEmail] = user
                                    completion(user)
                                }
                            }
                        }
                    })
                }
            }
            
            user = UserProfile(up: user, img: UIImage(systemName: "person")!)
            self.userDict[user.uEmail] = user
            completion(user)
        }
        
    }
    
    func getAllUserData(completion: @escaping () -> Void) {
        
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        
        print(#function, "current email", loggedInUserEmail)
        
        self.store
            .collection(COLLECTION_PROFILE)
            .whereField("uEmail", isEqualTo: loggedInUserEmail)
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
                        self.putUserInDict(userIn: profileData, completion: {userWithPic in
                            self.userDict[self.loggedInUserEmail] = userWithPic
                            
                        })
                        print(self.userDict)
                        
                        if docChange.type == .added{
                            self.userProfile = profileData
                            self.userProfile.id = docId
                            print("profileData has been added successfully!", profileData)
                        }
                        
                        if docChange.type == .modified{
                            self.userProfile = profileData
                        }
                    }
                    catch let err{
                        print(#function, "Unable to convert the document into object", err)
                    }
                }
                completion() // call completion handler when data is retrieved
            })
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
    
    func updateUserProfileImage(imageURLToUpdate: String, completion: @escaping (Error?) -> Void) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        self.store
            .collection(COLLECTION_PROFILE).document(loggedInUserEmail)
            .updateData(
                [
                    FIELD_PROFILE_IMAGE : imageURLToUpdate
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


