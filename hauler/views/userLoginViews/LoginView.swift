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
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var chatController : ChatController
    
    @Binding var rootScreen :RootView
    @Environment(\.presentationMode) var presentationMode
    
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    
    @State private var isUserInputInvalid = false
    @State private var errorMessage = ""
    
    @State private var showAlert = false
    @State private var authError: String = ""
    
    @State private var linkSelection: Int? = nil
    
    var body: some View {
        VStack {
            NavigationLink(destination: SignUpView(rootScreen: $rootScreen).environmentObject(authController).environmentObject(userProfileController), tag: 1, selection: self.$linkSelection){}
            
            
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
                      message: Text("\(self.authError)"),
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
        .onAppear(){
            print("rootScreen", rootScreen)
        }
    }
    
    func isUserInputValid() -> Bool {
        if self.emailAddress.isEmpty || self.password.isEmpty {
            return false
        }
        return true
    }
    
    func signIn(){
        authController.signIn(email: self.emailAddress, password: self.password) { result in
            switch result {
            case .success(_):
                print("Sign in success")
                userProfileController.getUserByEmail(email: emailAddress) { user, found in
                        DispatchQueue.main.async {
                            if found {
                                userProfileController.updateLoggedInUser()
                                chatController.fetchChats(completion: {})
                            } else {
                                print("User not found")
                                var userProfile = UserProfile()
                                userProfile.uEmail  = emailAddress
                                userProfileController.insertUserData(newUserData: userProfile)
                                userProfileController.updateLoggedInUser()

                            }
                        }
                    }
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error while signing in: \(error.localizedDescription)")
                self.authError = error.localizedDescription
                self.showAlert = true
            }
        }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
