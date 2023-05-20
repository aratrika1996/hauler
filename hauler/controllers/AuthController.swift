//
//  Auth.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import Foundation
import FirebaseAuth

class AuthController : ObservableObject {
    @Published var user : User?{
        didSet{
            objectWillChange.send()
        }
    }
    
    func listenToAuthState(){
        Auth.auth().addStateDidChangeListener{[weak self] _, user in
            guard let self = self else{
                // no change in state
                return
            }
            self.user = user
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<AuthDataResult?, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password){[self] authResult, error in
            guard let result = authResult else{
                print(#function, "Error while singing up the user: \(String(describing: error))")
                completion(.failure(error!))
                return
            }
            
            print("AuthResult: \(result)")
            
            switch authResult{
            case .none :
                print("Unable to create the account")
                completion(.failure(error!))
            case .some(_) :
                print("Successfully created the account")
                self.user = authResult?.user
                
                UserDefaults.standard.set(user?.email, forKey: "KEY_EMAIL")
                UserDefaults.standard.set(password, forKey: "KEY_PASSWORD")
                completion(.success(authResult))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                let error = NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to get user information."])
                completion(.failure(error))
                return
            }
            print("saving the user on sign in ",user.email ?? "")
            UserDefaults.standard.set(user.email, forKey: "KEY_EMAIL")
            UserDefaults.standard.set(password, forKey: "KEY_PASSWORD")
            completion(.success(user))
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError{
            print("unable to sign out", signOutError)
        }
    }
}
