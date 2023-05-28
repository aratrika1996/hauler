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
            ForEach (Array(self.chatController.chatMap.keys), id:\.self){key in
                
                NavigationLink(destination: ConversationView(chat: self.chatController.chatMap[key]!).environmentObject(chatController)) {
                    Text(self.chatController.chatMap[key]!.displayName)
                }
            }
        }
    
            .navigationTitle("Chats")
    }
}
