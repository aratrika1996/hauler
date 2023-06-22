//
//  ConversationView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct ConversationView: View {
    var chat: String
    @EnvironmentObject var chatController: ChatController
    @EnvironmentObject var userProfileController : UserProfileController
    @State private var shouldScrollToBottom = true
    @State private var messageCount = 0
    @State private var lastDay : Date? = nil
    @State private var localChatDict : [String:Chat] = [:]

    var body: some View {
        let currentChatDict = CurrentValueSubject<[String:Chat], Never>(chatController.chatDict)
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(localChatDict[chat]?.messages ?? []) { message in
                            if let previousMessage = previousMessage(for: message) {
                                if isDifferentDay(date1: previousMessage.timestamp.dateValue(), date2: message.timestamp.dateValue()) {
                                    DayTagView(day: message.timestamp.dateValue().convertToTag())
                                }
                            }else{
                                DayTagView(day: message.timestamp.dateValue().convertToTag())
                            }
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
                TextField("Write a message ...", text: $chatController.messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
                Button(action: {
                    chatController.sendMessage(chatId: chatController.chatDict[chat]!.id, toId: chat, complete: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            shouldScrollToBottom = true // Set shouldScrollToBottom to true after sending a message
                            messageCount += 1 // Update the message count
                        })

                    })
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(7)
                        .background(Color("HaulerOrange"))
                        .cornerRadius(5)
                }
            }
            .padding(10)
            
            
        }
        .navigationTitle("\(userProfileController.userDict[chat]!.uName) ")
    }
    
    func previousMessage(for message: Message) -> Message? {
        guard let index = localChatDict[chat]?.messages.firstIndex(where: { $0.id == message.id }) else {
            return nil
        }
        
        return index > 0 ? localChatDict[chat]?.messages[index - 1] : nil
    }

    func isDifferentDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return !calendar.isDate(date1, inSameDayAs: date2)
    }

}

struct DayTagView : View{
    var day:String
    var body: some View{
        HStack{
            Spacer()
            Text(day)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .padding(.vertical, 10)
            Spacer()
        }
    }
}

struct ChatMessageView: View {
    let message: Message
    let isSender: Bool

    var body: some View {
        HStack {
            if isSender {
                Spacer()
                VStack(alignment: .trailing){
                    Text(message.text)
                        .padding()
                        .background(Color("HaulerOrange").opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    Text(message.timestamp.dateValue().convertToTime()).font(.caption).foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading){
                    Text(message.text)
                        .padding()
                        .background(Color.gray.opacity(0.6))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    Text(message.timestamp.dateValue().convertToTime()).font(.caption).foregroundColor(.gray)
                }
                .padding(.vertical, 20)
                Spacer()
            }
        }
    }
}
