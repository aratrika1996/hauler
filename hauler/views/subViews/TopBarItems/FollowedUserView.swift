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
                                    if self.userProfileController.userDict[usr.email]?.uProfileImage != nil {
                                        Image(uiImage: (self.userProfileController.userDict[usr.email]?.uProfileImage!)!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(usr.email == self.selectedUser ? Color("HaulerOrange") : Color.white, lineWidth: 4))
                                            .scaledToFit()
                                            .onTapGesture {
                                                print("selected:\(usr)")
                                                self.selectedUser = usr.email
                                            }
                                    }
                                    else {
                                        Image(systemName: "person")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.black)
                                            .padding(15)
                                            .background(Color.gray)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(usr.email == self.selectedUser ? Color("HaulerOrange") : Color.white, lineWidth: 4))
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
