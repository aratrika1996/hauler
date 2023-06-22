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
                List(Array(self.chatController.sortedKey), id:\.self, selection:$selectedChat){key in
                    Button(action: {
                        self.selectedChat = key
                        redirect(local: true)
                    }){
                        NavigationLink(value:key as String)
                        {
                            HStack{
                                if ((localDict[key]?.uProfileImage) != nil) {
                                    //Text((localDict[key]?.uProfileImage!)! as! DateInterval)
                                    Image(uiImage: (localDict[key]?.uProfileImage)!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 65, height: 65)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                        .scaledToFit()
                                }
                                else {
                                    //Text((localDict[key]?.uProfileImage!)! as! DateInterval)
                                    Image(systemName: "person")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.black)
                                        .padding(20)
                                        .background(Color.gray)
                                        .clipShape(Circle())
                                }
                                
                                HStack{
                                    VStack(alignment: .leading){
                                        HStack{
                                            Text(localDict[key]?.uName ?? "Unknown")
                                                .font(.system(size: 18))
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text((chatController.chatDict[key]?.messages.last?.timestamp.dateValue().convertToDateOrTime())!)
                                                .foregroundColor(.gray)
                                                .font(.system(size: 13))
                                                
                                        }
                                        .padding(.bottom, 1)
                                        .foregroundColor(.black)
                                        Text(chatController.chatDict[key]?.messages.last?.text ?? "")
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                            .font(.system(size: 16))
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
