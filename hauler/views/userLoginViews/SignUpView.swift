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
    @ObservedObject private var userProfileController = UserProfileController.getInstance() ?? UserProfileController(store: Firestore.firestore())
    
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var confirmPassword : String = ""
    @State private var phoneNumber : String = ""
    @State private var address : String = ""
    
    @State private var linkSelection : Int? = nil
    @State private var authError: SignUpAuthError?
    @State private var showAlert : Bool = false
    @State private var isUserInputValid : Bool = false
    @State private var isSignInError : Bool = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            NavigationLink(destination: ContentView().environmentObject(authController), tag: 1, selection: $linkSelection) {}
            Form {
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
                                         message: Text("\(self.authError?.localizedDescription ?? "Unknown error")"),
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
        self.authController.signUp(email: self.email, password: self.password) { result in
            switch result {
            case .failure(let error):
                print("Sign up failed")
                self.authError = error
                self.isSignInError = true
            case .success( _):
                print("Sign up success")
                let newUser = UserProfile(cName: "", cEmail: self.email, uPhone: self.phoneNumber, uAddress: self.address, uLong: 0.0, uLat: 0.0)
                self.userProfileController.insertUserData(newUserData: newUser)
                self.linkSelection = 1
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
