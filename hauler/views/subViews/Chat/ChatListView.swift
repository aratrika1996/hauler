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
    @State private var selectedChat : String? = nil
    @State private var path : NavigationPath = NavigationPath()
    @State private var isLoading : Bool = false
    
    var body: some View {
        NavigationStack(path:$path){
            VStack{
                List(Array(self.chatController.sortedKey), id:\.self, selection:$selectedChat){key in
                    Button(action: {
                        self.selectedChat = key
                        redirect(local: true)
                    }){
                        NavigationLink(value:key as String)
                        {
                            HStack{
                                Image(uiImage: userProfileController.userDict[key]?.uProfileImage ?? UIImage(systemName: "person")!)
                                    .resizable()
                                    .cornerRadius(100)
                                    .shadow(radius: 5, x:5, y:5)
                                    .frame(width: 50, height: 50)
                                HStack{
                                    VStack(alignment: .leading){
                                        HStack{
                                            Text(userProfileController.userDict[key]?.uName ?? "Unknown")
                                            Spacer()
                                            Text((chatController.chatDict[key]?.messages.last?.timestamp.dateValue().convertToDateOrTime()) ?? "")
                                                .foregroundColor(.gray)
                                                
                                        }
                                        .padding(.bottom, 2)
                                        .foregroundColor(.black)
                                        Text(chatController.chatDict[key]?.messages.last?.text ?? "")
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                .listStyle(.inset)
                //List
                .navigationDestination(for: Optional<String>.self, destination: {key in
                    if let key = key{
                        ConversationView(chat: key)
                    }
                })
                .onAppear{
                    chatController.msgCount = 0
                    if chatController.newChatRoom{
                        self.isLoading = true
                        chatController.newChatRoom = false
                        if let newId = chatController.toId{
                            Task{
                                await chatController.newChatRoom(id: newId, complete:{success in
                                    chatController.fetchChats(completion: {
                                        isLoading = false
                                        redirect(local: false)
                                    })
                                })
                            }
                        }
                    }else{
                        redirect(local: false)
                    }
                }

            }
        }
        
        .navigationTitle("Messages")
    }
    
    func redirect(local: Bool){
        if(!local){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if (self.chatController.redirect){
                    if(!path.isEmpty){
                        path.removeLast(path.count)
                    }
                    path.append(self.chatController.toId)
                    self.chatController.redirect = false
                }
            }
        }else{
            if(!path.isEmpty){
                path.removeLast(path.count)
            }
            path.append(self.selectedChat)
        }
    }
    
}

extension Date{
    func convertToDateOrTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        if(self.distance(to: .now) > 86400){
            dateFormatter.dateFormat = "dd/MM/YY"
        }else{
            dateFormatter.dateFormat = "HH:mm"
        }
        let formattedDate = dateFormatter.string(from: self)
        return formattedDate
    }
    func convertToTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "HH:mm"
        let formattedDate = dateFormatter.string(from: self)
        return formattedDate
    }
    func convertToTag() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "dd/MM"
        let formattedDate = dateFormatter.string(from: self)
        return formattedDate
    }
}
