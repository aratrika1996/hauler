//
//  ChatController.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 26/05/2023.
//

import Foundation
import FirebaseFirestore
import Firebase

class ChatController: ObservableObject {
    @Published var chatDict : [String:Chat] = [:]
    @Published var chats: [Chat] = []
    @Published var messageText: String = ""
    @Published var toId : String? = nil
    @Published var selectedChar : Chat? = nil
    @Published var msgCount : Int = 0
    
    private static var shared : ChatController?
    private let COLLECTION_CHAT: String = "Chat"
    private var userId: String?
    private let db = Firestore.firestore()
    
    var loggedInUserEmail: String?
    var redirect : Bool = false
    var newChatRoom : Bool = false

    init() {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
    }
    
    static func getInstance() -> ChatController?{
        if (shared == nil){
            shared = ChatController()
        }
        
        return shared
    }

    func sendMessage(chatId: String, toId: String, complete: @escaping () -> Void) {
        if(messageText.trimmingCharacters(in: .whitespacesAndNewlines) != ""){
            loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
            guard let userId = loggedInUserEmail else {
                return
            }
            
            // Add the participants field to the message data
            let messageData: [String: Any] = [
                "fromId": userId,
                "toId": toId,
                "text": messageText, // messageText,
                "timestamp": Date()
            ]
            
            db.collection(COLLECTION_CHAT).document(chatId).collection("messages").addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                    complete()
                } else {
                    self.messageText = ""
                    print("Message sent successfully")
                    self.fetchChats(completion: {
                        complete()
                    })
                }
            }
        }
        
    }
    
    func newChatRoom(id: String, complete: @escaping (Bool) -> Void) async{
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        guard let userId = loggedInUserEmail else {
            return
        }
        let data : [String: Any] = [
            "participants": [userId, id] // Add the participants
        ]
        
        let newchatroom = db.collection(COLLECTION_CHAT).addDocument(data: data){error in
            if let error = error {
                print("Error creating new chatroom: \(error.localizedDescription)")
            } else {
                self.messageText = ""
                print("New Chatroom created successfully")
            }
            
            
        }
        let messageData: [String: Any] = [
            "fromId": userId,
            "toId": id,
            "text": self.messageText, // messageText,
            "timestamp": Date()
        ]
        self.db.collection(self.COLLECTION_CHAT).document(newchatroom.documentID).collection("messages").addDocument(data: messageData){err in
            if let err = err {
                complete(false)
                print("Error sending new msg after creating new chatroom: \(err.localizedDescription)")
            } else {
                complete(true)
                print("Message sent after chatroom creation successfully")
            }
            
        }
        
    }


    func fetchChats(completion: @escaping () -> Void){
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        guard let userId = loggedInUserEmail else {
            return
        }

        db.collection(COLLECTION_CHAT).whereField("participants", arrayContains: userId).addSnapshotListener { snapshot, error in
            print("started fetching data")
            if let error = error {
                print("Error fetching chats: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No chats found")
                return
            }
            documents.forEach{document in
                let chatId = document.documentID
                do{
                    let chatroom = try document.data(as: Chat.self)
                    print(chatroom.participants)
                }catch{
                    print(#function, "error")
                }
                self.fetchMessages(for: chatId) { messages in
                    print("chatId", chatId)
                    if(!messages.isEmpty){
                        let displayName = messages[0].toId == userId ? messages[0].fromId : messages[0].toId
                        let participants = [messages[0].toId, messages[0].fromId]
                        let chat = Chat(participants: participants, id: chatId, displayName: displayName, messages: messages)
                        print(#function, "chatId : \(chatId), name = \(displayName)")
                        self.chatDict[displayName] = chat
                    }
                    
                }
            }
            completion()
//            dispatchGroup.notify(queue: .main){
//                print(#function, "chatrooms fetched: \(self.chatDict.count)")
//                self.chatDict.forEach{
//                    print($0.value.displayName)
//                }
//                completion()
//            }
            
        }
    }



    private func fetchMessages(for chatId: String, completion: @escaping ([Message]) -> Void) {

        db.collection(COLLECTION_CHAT).document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener{ (snapshot, error) in
                if let error = error {
                    print("Error fetching messages for chat \(chatId): \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No messages found for chat \(chatId)")
                    completion([])
                    return
                }
                let messages = documents.compactMap { document -> Message? in
                    guard let messageDict = document.data() as? [String: Any] else {
                        return nil
                    }
                    var message = Message(dictionary: messageDict)
                    message?.id = document.documentID
//                    print("new msg id:\(message?.id)")
                    return message
                }
                if self.chatDict[chatId] != nil{
                    self.msgCount += 1
                }
                completion(messages)
            }
    }


}




