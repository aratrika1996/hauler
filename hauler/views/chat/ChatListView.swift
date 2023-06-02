//
//  ChatListView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var chatController: ChatController
    @EnvironmentObject var userProfileController: UserProfileController
    @State var selectedChat : Chat?
    @State var navigateToChat : Bool = false

    var body: some View {
        List(self.chatController.chats){chat in
            NavigationLink(destination: ConversationView(chat: chat).environmentObject(chatController)) {
                Text(chat.displayName)
            }
        }
        .navigationTitle("Chats")
        .onAppear(){
        }
    }
    
    func updateName (emailAddress: String){
        userProfileController.getUserByEmail(email: emailAddress) { user, found in
            DispatchQueue.main.async {
                if found {
                    userProfileController.updateLoggedInUser()
                    
                } else {
                    print("User not found")
                    var userProfile = UserProfile()
                    userProfile.uEmail  = emailAddress
                    userProfileController.insertUserData(newUserData: userProfile)
                    userProfileController.updateLoggedInUser()
                    
                }
            }
        }
    }
}
