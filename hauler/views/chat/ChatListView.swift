//
//  ChatListView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var chatController: ChatController

    var body: some View {
        List{
            ForEach (self.chatController.chats, id:\.id){chat in
                
                NavigationLink(destination: ConversationView(chat: chat).environmentObject(chatController)) {
                    Text(chat.displayName)
                }
            }
        }
    
            .navigationTitle("Chats")
            .onAppear(){
                for chat in chatController.chats{
                    print("chatController.chats", chat)
                }
                
            }
    }
}
