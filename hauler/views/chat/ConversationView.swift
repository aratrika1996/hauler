//
//  ConversationView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import SwiftUI

struct ConversationView: View {
    let chat: Chat
    @EnvironmentObject var chatController: ChatController

    var body: some View {
        VStack {
            List(chat.messages) { message in
                Text(message.text)
            }
            HStack {
                TextField("Type your message", text: $chatController.messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    chatController.sendMessage(chatId: chat.id)
                }) {
                    Text("Send")
                }
            }
            .padding()
        }
        .navigationTitle(chat.displayName)
    }
}

