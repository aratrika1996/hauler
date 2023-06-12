//
//  ConversationView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import SwiftUI
import Combine

struct ConversationView: View {
    var chat: String
    @EnvironmentObject var chatController: ChatController
    @EnvironmentObject var userProfileController : UserProfileController
    @State private var shouldScrollToBottom = true
    @State private var messageCount = 0
    @State private var localChatDict : [String:Chat] = [:]

    var body: some View {
        let currentChatDict = CurrentValueSubject<[String:Chat], Never>(chatController.chatDict)
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(localChatDict[chat]?.messages ?? []) { message in
                            ChatMessageView(message: message, isSender: message.fromId == chatController.loggedInUserEmail)
                                .padding(.horizontal)
                                .id(message.id) // Assign a unique identifier to each message
                                .onChange(of: messageCount) { num in
                                    // Automatically scroll to the bottom when a new message arrives
                                    print("message ++ to :\(num)")
//                                    if shouldScrollToBottom {
                                        withAnimation {
                                            scrollViewProxy.scrollTo(chatController.chatDict[chat]!.messages.last?.id, anchor: .bottom)
                                        }
//                                    }
                                }
                                .onAppear {
                                    withAnimation {
                                        scrollViewProxy.scrollTo(chatController.chatDict[chat]!.messages.last?.id, anchor: .bottom)
                                    }
                                }
                        }
                    }
                }
                .onAppear{
                    localChatDict = chatController.chatDict
                }
                .onReceive(currentChatDict, perform: {dict in
                    localChatDict = dict
                })
            }

            HStack {
                TextField("Type your message", text: $chatController.messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    chatController.sendMessage(chatId: chatController.chatDict[chat]!.id, toId: chat, complete: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            shouldScrollToBottom = true // Set shouldScrollToBottom to true after sending a message
                            messageCount += 1 // Update the message count
                        })
                        
                    })
                }) {
                    Text("Send")
                }
            }
            .padding()
        }
        .navigationTitle("\(userProfileController.userDict[chat]!.uName) ")
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
