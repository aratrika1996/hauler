//
//  ChangePasswordView.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-05-26.
//

import SwiftUI

struct ChangePasswordView: View {
    @State private var oldPassword : String = ""
    @State private var newPassword : String = ""
    @State private var confirmNewPassword : String = ""
    @State private var showAlertText : String = ""
    @State private var isValid : Bool = false
    @State private var showAlert : Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    Text("Current")
                        .frame(width: 90, alignment: .leading)
                    SecureField("required", text: self.$oldPassword)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
                
                HStack {
                    Text("New")
                        .frame(width: 90, alignment: .leading)
                    SecureField("enter password", text: self.$newPassword)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
                
                HStack {
                    Text("Verify")
                        .frame(width: 90, alignment: .leading)
                    SecureField("re-enter password", text: self.$confirmNewPassword)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
            }
            
            Button(action: {
                self.verifyPassword()
                self.showAlert = true
            }) {
                Text("Update Password")
            }
            .alert(isPresented: self.$showAlert){
                if isValid {
                    return Alert(title: Text("Update Password"),
                          message: Text("Confirm?"),
                          primaryButton: .default(
                              Text("No")
                          ),
                          secondaryButton: .destructive(
                              Text("Yes"),
                              action: updatePassword
                          )
                    )
                }
                else {
                    return Alert(title: Text("Result"),
                          message: Text("\(self.showAlertText)"),
                          dismissButton: .default(Text("OK!")))
                }
                
            }
        }
        .navigationTitle("Change Password")
    }
    
    func verifyPassword() {
        
        if self.oldPassword.isEmpty || self.newPassword.isEmpty || self.confirmNewPassword.isEmpty {
            self.showAlertText = "Password fields can not be empty"
            self.isValid = false
        }
//        else if self.fireDBController.newUser.password != self.oldPassword {
//            self.showAlertText = "Old password did not match"
//            self.isValid = false
//        }
        else if self.newPassword != self.confirmNewPassword {
            self.showAlertText = "New password and confirm password did not match"
            self.isValid = false
        }
        else {
            self.isValid = true
        }
        
    }
    
    func updatePassword() {
        self.authController.updatePassword(newPassword: newPassword, oldPassword: oldPassword)
        dismiss()
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}
