//
//  LoginView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI
import FirebaseFirestore

struct LoginView: View {
    @EnvironmentObject var authController : AuthController
    @ObservedObject private var userProfileController = UserProfileController.getInstance() ?? UserProfileController(store: Firestore.firestore())
    
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    
    @State private var isUserInputInvalid = false
    @State private var errorMessage = ""
    
    @State private var showAlert = false
    @State private var authError: SignInAuthError?
    
    @State private var linkSelection: Int? = nil
    
    var body: some View {
            VStack {
                NavigationLink(destination: SignUpView().environmentObject(authController), tag: 1, selection: self.$linkSelection){}
                
                NavigationLink(destination: ContentView().environmentObject(authController), tag: 2, selection: self.$linkSelection){}
                
                Spacer()
                
                Text("Sign in")
                    .font(.system(size: 32))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Enter an email address", text: $emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                SecureField("Enter password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if isUserInputInvalid {
                    Text("Email address / password cannot be empty.")
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    isUserInputInvalid = false
                    
                    if isUserInputValid() {
                        signIn()
                    } else {
                        self.isUserInputInvalid = true
                    }
                    
                }){
                    Text("Sign In")
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity)
                    
                }//Button ends
                .padding([.top], 30)
                .buttonStyle(.borderedProminent)
                .tint(Color(UIColor(named: "HaulerOrange") ?? .blue))
                .alert(isPresented: self.$showAlert){
                    Alert(title: Text("Sign in failed"),
                          message: Text("\(self.authError?.localizedDescription ?? "Unknown error")"),
                          dismissButton: .default(Text("OK")) {
                    })
                }
                
                Spacer()
                
                HStack {
                    Text("Don't have an account? ")
                    Button(action: {
                        linkSelection = 1
                    }){
                        Text("Sign up")
                            .foregroundColor(Color(UIColor(named: "HaulerOrange") ?? .blue))
                    }//Button ends
                }//HStack ends
                
            }//VStack ends
            .padding(30)
            
    }
    
    func isUserInputValid() -> Bool {
        if self.emailAddress.isEmpty || self.password.isEmpty {
            return false
        }
        return true
    }
    
    func signIn(){
        authController.signIn(email: self.emailAddress, password: self.password) { (result) in
            switch result {
            case .failure(let error):
                print("Sign in failed")
                self.authError = error
                self.showAlert = true
            case .success( _):
                print("Sign in success")
                linkSelection = 2
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
