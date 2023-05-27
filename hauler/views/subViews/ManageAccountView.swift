//
//  ManageAccountView.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-05-24.
//

import SwiftUI

struct ManageAccountView: View {
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var listingController : ListingController
    
    @Binding var rootScreen :RootView
    
    @State private var showAlert : Bool = false
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: ChangePasswordView().environmentObject(userProfileController).environmentObject(authController)) {
                    Text("Change Password")
                }
            }
            
            Section {
                Button(action: {
                    self.showAlert = true
                }){
                    Text("Delete Account")
                        .foregroundColor(.red)
                }
                .alert(isPresented: self.$showAlert) {
                    Alert(title: Text("Delete Account"),
                          message: Text("Confirm?"),
                          primaryButton: .default(
                              Text("No")
                          ),
                          secondaryButton: .destructive(
                              Text("Yes"),
                              action: deleteUser
                          )
                    )
                }
            }
        }
    }
    
    func deleteUser() {
        self.userProfileController.deleteUserData() {
            self.listingController.deleteAllUserListing() {
                self.authController.deleteUser()
                self.rootScreen = .LOGIN
            }
        }
        
    }
}

//struct ManageAccountView_Previews: PreviewProvider {
//    static var previews: some View {
//        ManageAccountView()
//    }
//}
