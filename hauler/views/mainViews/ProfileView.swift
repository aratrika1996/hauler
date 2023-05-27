//
//  ProfileView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var listingController : ListingController
    
    @State private var name : String = ""
    @State private var email : String = ""
    @Binding var rootScreen :RootView
    
    var body: some View {
        VStack {
            Form {
                Section {
                    HStack(alignment: .center) {
                        ZStack(alignment: .bottomTrailing) {
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                                .padding(30)
                                .background(Color.gray)
                                .clipShape(Circle())
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                        }
                        VStack(alignment: .leading) {
                            Text(self.name)
                            Text(self.email)
                            HStack {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.yellow)
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.yellow)
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.yellow)
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.yellow)
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.yellow)
                                Text("5.0")
                                Text("(8)")
                            }
                        }
                        .padding(.leading, 10)
                    }//HStack ends
                }
                .listRowBackground(Color.white.opacity(0))
                .listRowInsets(EdgeInsets())
                
                Section(header: Text("Profile details")) {
                    NavigationLink(destination: PersonalDetailsView().environmentObject(userProfileController)) {
                        Text("Personal details")
                    }
                }
                
                Section(header: Text("Account settings")) {
                    NavigationLink(destination: ManageAccountView(rootScreen: $rootScreen).environmentObject(userProfileController).environmentObject(authController).environmentObject(listingController)) {
                        Text("Manage account")
                    }
                    Text("Notification preferences")
                }
                
                Section(header: Text("General information")) {
                    Text("Terms of use")
                    Text("Privacy policy")
                    Text("Help")
                }
                
                Section(header: Text("Display settings")) {
                    Text("App theme")
                }
                
                Section {
                    
                    Button(action: {
                        authController.signOut()
                        userProfileController.updateLoggedInUser()
                            self.rootScreen = .HOME
                        
                        
                    }){
                        Text("Log out")
                            .font(.system(size: 20))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                        
                    }//Button ends
                }
                .listRowBackground(Color(UIColor(named: "HaulerOrange") ?? .blue))
            }
        }
        .onAppear {
            self.name = self.userProfileController.userProfile.uName
            self.email = UserDefaults.standard.value(forKey: "KEY_EMAIL") as! String
        }
        
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
