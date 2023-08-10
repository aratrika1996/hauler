//
//  SignUpView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI
import FirebaseFirestore

struct SignUpView: View {
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var chatController : ChatController
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var rootScreen :RootView
    
    @State private var name : String = ""
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var confirmPassword : String = ""
    @State private var phoneNumber : String = ""
    @State private var address : String = ""
    
    @State private var linkSelection : Int? = nil
    @State private var authError: String = ""
    @State private var showAlert : Bool = false
    @State private var isUserInputValid : Bool = false
    @State private var isSignInError : Bool = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Form {
                TextField("Enter Name", text: self.$name)
                    .textInputAutocapitalization(.never)
                
                TextField("Enter Email", text: self.$email)
                    .textInputAutocapitalization(.never)
                
                SecureField("Enter Password", text: self.$password)
                    .textInputAutocapitalization(.never)
                
                SecureField("Enter Password Again", text: self.$confirmPassword)
                    .textInputAutocapitalization(.never)
                
                Section {
                    TextField("Enter Phone number", text: self.$phoneNumber)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    TextField("Enter address", text: self.$address)
                        .textInputAutocapitalization(.never)
                }
                
                
                Section {
                    Button(action: {
                        
                        if validateData() {
                            self.signUp()
                        }
                        else if !validateData() || self.isSignInError {
                            self.showAlert = true
                        }
                    }) {
                        Text("Create Account")
                            .foregroundColor(Color.white)
                    }//button ends
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color(UIColor(named: "HaulerOrange") ?? .blue))
                    .alert(isPresented: self.$showAlert) {
                        if isSignInError {
                            return Alert(title: Text("Sign in failed"),
                                         message: Text("\(self.authError )"),
                                         dismissButton: .default(Text("OK")) {
                                   })
                        }
                        else {
                            return Alert(title: Text("Validation error"),
                                         message: Text("\(self.errorMessage)"),
                                         dismissButton: .default(Text("OK")) {
                                   })
                        }
                    }
                }
            }
            .disableAutocorrection(true)
            
        }
        
        .navigationTitle("Sign up")
    }
    
    func validateData() -> Bool {
        if self.email.isEmpty {
            self.errorMessage = "Email can not be empty"
            return false
        }
        else {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if emailPred.evaluate(with: email) {
                // if valid email check password
                if self.password.isEmpty || self.confirmPassword.isEmpty {
                    self.errorMessage = "Password can not be empty"
                    return false
                }
                else {
                    if self.password != self.confirmPassword {
                        self.errorMessage = "Password did not match"
                        return false
                    }
                    else if !self.phoneNumber.isEmpty {
                        let phoneRegex = #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#
                        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
                        if !phoneTest.evaluate(with: self.phoneNumber) {
                            errorMessage = "Invalid phone number"
                            return false
                        }
                    }
                }
            }
            else {
                self.errorMessage = "Invalid email id"
                return false
            }
        }
        return true
    }
    
    func signUp() {
        // Sign up the user with Firebase Auth
        authController.signUp(email: email, password: password) { result in
            switch result {
            case .success(_):
                // Navigate to the ContentView upon successful sign up
                print("Sign up success")
                let newUser = UserProfile(cName: self.name, cEmail: self.email, uPhone: self.phoneNumber, uAddress: self.address, uLong: 0.0, uLat: 0.0)
                self.userProfileController.insertUserData(newUserData: newUser)
                self.userProfileController.getAllUserData {
                    print("data retrieved")
                }
                userProfileController.updateLoggedInUser()
                if chatController.chatRef == nil{
                    chatController.fetchChats(completion: {keys in
                        print("keys return from fetch chat count = \(self.chatController.chatDict.count)")
                        keys.forEach{
                            userProfileController.getUserByEmail(email: $0, completion: {up,_ in
                                print(up?.uName)
                            })
                        }
                    })
                }else{
                    chatController.chatDict.keys.forEach{key in
                        userProfileController.getUserByEmail(email: key, completion: {up,_ in
                            print(up?.uName)
                        })
                    }
                }
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                // Display error message
                userProfileController.updateLoggedInUser()
                self.authError = error.localizedDescription
                self.isSignInError = true
            }
        }
        return
    }
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView()
//    }
//}
