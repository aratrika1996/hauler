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
                                Circle()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(usr == self.selectedUser ? Color("HaulerOrange") : Color.gray)
                                    .shadow(radius: 5, x:5, y:5)
                                    .overlay{
                                        Image(uiImage: self.userProfileController.userDict[usr]?.uProfileImage ?? UIImage(systemName: "person")!)
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(100)
                                            .padding(5)
                                            .onTapGesture {
                                                print("selected:\(usr)")
                                                self.selectedUser = usr
                                            }
                                    }
                                
                                
                                
                            }
                        }
                        .padding()
                    }
                    
                    if let selected = self.selectedUser{
                        VStack{
                            UserPublicProfileView(sellerEmail: selected, rootScreen: $rootScreen)
                                .id(selected)
                                .navigationTitle(Text("Following"))
                        }
                    }
                    
                    
                    
                }
                
             )
            )
        }
        .onAppear{
            if !userProfileController.userProfile.uFollowedUsers.isEmpty && self.selectedUser == nil{
                self.selectedUser = userProfileController.userProfile.uFollowedUsers.first
            }
            userProfileController.userProfile.uFollowedUsers.forEach{usr in
                userProfileController.getUserByEmail(email: usr, completion: {_,_  in
                    
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