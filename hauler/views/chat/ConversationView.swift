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
    @State private var shouldScrollToBottom = true
    @State private var messageCount = 0

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(chatController.chatDict[chat]!.messages) { message in
                            ChatMessageView(message: message, isSender: message.fromId == chatController.loggedInUserEmail)
                                .padding(.horizontal)
                                .id(message.id) // Assign a unique identifier to each message
                                .onChange(of: messageCount) { _ in
                                    // Automatically scroll to the bottom when a new message arrives
                                    if shouldScrollToBottom {
                                        withAnimation {
                                            scrollViewProxy.scrollTo(chatController.chatDict[chat]!.messages.last?.id, anchor: .bottom)
                                        }
                                    }
                                }
                        }
                    }
                    .onAppear {
                        print("Got Chat")
                        // Scroll to the bottom initially
                        withAnimation {
                            scrollViewProxy.scrollTo(chatController.chatDict[chat]!.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                TextField("Type your message", text: $chatController.messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    chatController.sendMessage(chatId: chatController.chatDict[chat]!.id, toId: chatController.toId!)
                    shouldScrollToBottom = true // Set shouldScrollToBottom to true after sending a message
                    messageCount += 1 // Update the message count
                }) {
                    Text("Send")
                }
            }
            .padding()
        }
        .onAppear{
            print("entered")
        }
        .navigationTitle(chatController.chatDict[chat]!.displayName)
    }
}



struct ChatMessageView: View {
    let message: Message
    let isSender: Bool

    var body: some View {
        HStack {
            if isSender {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                Text(message.text)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                Spacer()
            }
        }
    }
}
