//
//  ChatListView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import SwiftUI

struct ChatListView: View {
    var chatController: ChatController = ChatController()

    var body: some View {
            List(chatController.chats) { chat in
                NavigationLink(destination: ConversationView(chat: chat).environmentObject(chatController)) {
                    Text(chat.displayName)
                }
            }
            .navigationTitle("Chats")
    }
}
