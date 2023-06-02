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
    @State private var shouldScrollToBottom = true
    @State private var messageCount = 0

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(chat.messages) { message in
                            ChatMessageView(message: message, isSender: message.fromId == chatController.loggedInUserEmail)
                                .padding(.horizontal)
                                .id(message.id) // Assign a unique identifier to each message
                                .onChange(of: messageCount) { _ in
                                    // Automatically scroll to the bottom when a new message arrives
                                    if shouldScrollToBottom {
                                        withAnimation {
                                            scrollViewProxy.scrollTo(chat.messages.last?.id, anchor: .bottom)
                                        }
                                    }
                                }
                        }
                    }
                    .onAppear {
                        // Scroll to the bottom initially
                        chatController.toId = chat.messages[0].toId == chatController.loggedInUserEmail ? chat.messages[0].fromId : chat.messages[0].toId
                        withAnimation {
                            scrollViewProxy.scrollTo(chat.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                TextField("Type your message", text: $chatController.messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    guard let toId = chatController.toId else{
                        return
                    }
                    chatController.sendMessage(chatId: chat.id, toId: toId)
                    shouldScrollToBottom = true // Set shouldScrollToBottom to true after sending a message
                    messageCount += 1 // Update the message count
                }) {
                    Text("Send")
                }
            }
            .padding()
        }
        .navigationTitle(chat.displayName)
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
