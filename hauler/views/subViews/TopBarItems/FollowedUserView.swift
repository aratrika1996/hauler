//
//  FollowedUserView.swift
//  hauler
//
//  Created by Homing Lau on 2023-07-18.
//

import SwiftUI

struct FollowedUserView: View {
    @EnvironmentObject var userProfileController : UserProfileController
    @Binding var rootScreen :RootView
    @State var selectedUser : String? = nil
    var body: some View {
        
        VStack{
            (userProfileController.userProfile.uFollowedUsers.isEmpty ?
             AnyView(
                VStack{
                    Text("Follow Someone!")
                }
             )
             :AnyView(
                VStack{
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(userProfileController.userProfile.uFollowedUsers, id: \.self){usr in
                                VStack{
                                    Circle()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(usr.email == self.selectedUser ? Color("HaulerOrange") : Color.gray)
                                        .shadow(radius: 5, x:5, y:5)
                                        .overlay{
                                            Image(uiImage: self.userProfileController.userDict[usr.email]?.uProfileImage ?? UIImage(systemName: "person")!)
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(100)
                                                .padding(5)
                                                .onTapGesture {
                                                    print("selected:\(usr)")
                                                    self.selectedUser = usr.email
                                                }
                                        }
                                    Text(self.userProfileController.userDict[usr.email]?.uName ?? usr.email)
                                        .fontWeight(.light)
                                        .font(.caption)
                                }
                                
                            }
                        }
                        
                        .padding()
                        
                    }.overlay(
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.gray, lineWidth: 0.2)
                                    .frame(height: 1)
                                    .padding(.horizontal)
                                , alignment: .bottom
                    )
                    
                    if let selected = self.selectedUser{
                        VStack{
                            UserPublicProfileView(passedInTitle: "Following", sellerEmail: selected, rootScreen: $rootScreen)
                                .id(selected)
                        }
                        .onChange(of: self.userProfileController.userProfile.uFollowedUsers, perform: {newlist in
                            if let usr = self.selectedUser{
                                if !self.userProfileController.userProfile.uFollowedUsers.isEmpty{
                                    if newlist.first(where: {$0.email == usr}) == nil{
                                        self.selectedUser = self.userProfileController.userProfile.uFollowedUsers.first?.email
                                    }
                                }else{
                                    self.selectedUser = nil
                                }
                            }
                            
                        })
                    }
                    
                    
                    
                }
                
             )
            )
        }
        .onAppear{
            if !userProfileController.userProfile.uFollowedUsers.isEmpty && self.selectedUser == nil{
                self.selectedUser = userProfileController.userProfile.uFollowedUsers.first?.email
            }
            userProfileController.userProfile.uFollowedUsers.forEach{usr in
                userProfileController.getUserByEmail(email: usr.email, completion: {_,_  in
                    
                })
            }
        }
    }
}

//struct FollowedUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        FollowedUserView(, rootScreen: <#Binding<RootView>#>)
//    }
//}
