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
    @State var localDict : [String:UserProfile] = [:]
    @State var localChat : [String:Chat] = [:]
    @State private var selectedChat : String? = nil
    @State private var path : NavigationPath = NavigationPath()
    @State private var isLoading : Bool = false
    
    var body: some View {
        let currentDict = CurrentValueSubject<[String:UserProfile], Never>(userProfileController.userDict)
        NavigationStack(path:$path){
            VStack{
                List(Array(self.chatController.chatDict.keys), id:\.self, selection:$selectedChat){key in
                    Button(action: {
                        self.selectedChat = key
                        redirect(local: true)
                    }){
                        NavigationLink(value:key as String)
                        {
                            HStack{
                                Image(uiImage: localDict[key]?.uProfileImage ?? UIImage(systemName: "person")!)
                                    .resizable()
                                    .cornerRadius(100)
                                    .shadow(radius: 5, x:5, y:5)
                                    .frame(width: 50, height: 50)
                                HStack{
                                    VStack(alignment: .leading){
                                        HStack{
                                            Text(localDict[key]?.uName ?? "Unknown")
                                            Spacer()
                                            Text(convertDate(date: (chatController.chatDict[key]?.messages.last?.timestamp.dateValue())!))
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
                .onReceive(currentDict, perform: {dict in
                    localDict = dict
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
    
    func convertDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent

        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}