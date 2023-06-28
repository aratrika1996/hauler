//
//  ChatListView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import SwiftUI
import Combine
import PromiseKit

struct ChatListView: View {
    @EnvironmentObject var chatController: ChatController
    @EnvironmentObject var userProfileController: UserProfileController
    @State private var selectedChat : String? = nil
    @State private var path : NavigationPath = NavigationPath()
    @State private var isLoading : Bool = false
    @State private var localProfileDict : [String:UserProfile] = [:]
    
    
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
                                Image(uiImage: self.userProfileController.userDict[key]?.uProfileImage ?? UIImage(systemName: "person")!)
                                    .resizable()
                                    .cornerRadius(100)
                                    .shadow(radius: 5, x:5, y:5)
                                    .frame(width: 50, height: 50)
                                HStack{
                                    VStack(alignment: .leading){
                                        HStack{
                                            Text(self.userProfileController.userDict[key]?.uName ?? "Unknown")
                                            Spacer()
                                            Text((chatController.chatDict[key]?.messages.last?.timestamp.dateValue().convertToDateOrTime()) ?? "")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 13))
                                                
                                        }
                                        .padding(.bottom, 1)
                                        .foregroundColor(.black)
                                        HStack{
                                            Text(chatController.chatDict[key]?.messages.last?.text ?? "")
                                                .foregroundColor(self.chatController.chatDict[key]?.unread ?? 0 > 0 ? .black : .gray)
                                                .lineLimit(1)
                                                .font(.system(size: 16))
                                            if(self.chatController.chatDict[key]?.unread ?? 0 > 0){
                                                Spacer()
                                                
                                                Text(self.chatController.chatDict[key]?.unread.formatted() ?? "")
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 5)
                                                    .foregroundColor(.white)
                                                    .background(Color("HaulerOrange"))
                                                    .cornerRadius(10)
                                            }
                                        }
                                        
                                    }
                                }
                                .padding(5)
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
                .listStyle(.plain)
                //List
                .navigationDestination(for: Optional<String>.self, destination: {key in
                    if let key = key{
                        ConversationView(chat: key)
                    }
                })
                .onAppear{
//                    localProfileDict = self.userProfileController.userDict
                    chatController.msgCount = 0
                    if chatController.newChatRoom{
                        print(#function, "NewChatRoom !!")
                        self.isLoading = true
                        chatController.newChatRoom = false
                        if let newId = chatController.toId{
                            Task{
                                await chatController.newChatRoom(id: newId, complete:{success in
//                                    chatController.fetchChats(completion: {_ in
                                        isLoading = false
                                        redirect(local: false)
//                                    })
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
        dateFormatter.dateFormat = "MMM d, yyyy"
        let formattedDate = dateFormatter.string(from: self)
        return formattedDate
    }
}
