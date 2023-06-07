//
//  ChatListView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import SwiftUI
import Combine

struct ChatListView: View {
    @EnvironmentObject var chatController: ChatController
    @EnvironmentObject var userProfileController: UserProfileController
//    @State var selectedChat : Chat?
    @State var navigateToChat : Bool = false
    @State var selectedChat : String? = nil
    @State var isLoading : Bool = true
    
    var body: some View {
        VStack{
            if(isLoading){
                SplashScreenView()
                    .onAppear{
                        if(chatController.chatDict.isEmpty){
                            chatController.fetchChats(completion: {
                                Task{
                                    await userProfileController.getUserInfoAndStore(email: Array(chatController.chatDict.keys), completion: {success in
                                        if(success){
                                            isLoading = false
                                        }
                                    })
                                }
                                
                            })
                        }else{
                            Task{
                                await userProfileController.getUserInfoAndStore(email: Array(chatController.chatDict.keys), completion: {success in
                                    if(success){
                                        isLoading = false
                                    }
                                })
                            }
                        }
                    }
            }else{
                List(Array(self.chatController.chatDict.keys), id:\.self, selection:$selectedChat){key in
                    
                    NavigationLink(destination: ConversationView(chat: key), tag: key, selection: $selectedChat) {
                        HStack{
                            Image(uiImage: userProfileController.userDict[key]?.uProfileImage ?? UIImage(systemName: "person")!)
                                .resizable().frame(width: 50, height: 50)
                            Spacer()
                            Text(userProfileController.userDict[key]?.uName ?? "Unknown")
                        }
                    }
                }
            }
        }
        .navigationTitle("Chats")
        
    }
}
