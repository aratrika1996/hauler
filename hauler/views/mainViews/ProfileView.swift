//
//  ProfileView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userProfileController : UserProfileController
    var body: some View {
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
                        Text("John Doe")
                        Text("john.doe@gmail.com")
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
                NavigationLink(destination: ManageAccountView().environmentObject(userProfileController)) {
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
                    
                    //self.rootScreen = .LOGIN
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
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
