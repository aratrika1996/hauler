//
//  ConversationView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import SwiftUI

struct ConversationView: View {
    let chat: String
    @EnvironmentObject var chatController: ChatController

    var body: some View {
        VStack {
            List {
                ForEach(chatController.chatMap[chat]!.messages.sorted{
                    $0.timestamp.dateValue() > $1.timestamp.dateValue()
                }){message in
                    HStack{
                        Text(message.text)
                        Spacer()
                        Text(message.timestamp.dateValue().formatted())
                    }
                }
                
                
            }
            HStack {
                TextField("Type your message", text: $chatController.messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    chatController.sendMessage(chatId: chat, msg: chatController.messageText)
                }) {
                    Text("Send")
                }
            }
            .padding()
        }
        .navigationTitle(chatController.chatMap[chat]!.displayName)
        .onAppear(){
            
        }
    }
}

