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
    @Published var chats: [Chat] = []
    @Published var messageText: String = ""
    @Published var toId : String? = nil
    @Published var selectedChar : Chat? = nil
    private static var shared : ChatController?
    private let COLLECTION_CHAT: String = "Chat"
    private var userId: String?
    private let db = Firestore.firestore()
    var loggedInUserEmail: String?

    init() {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
//        fetchChats()
//        sendMessage(chatId: "32io4nkl324n")
    }
    
    static func getInstance() -> ChatController?{
        if (shared == nil){
            shared = ChatController()
        }
        
        return shared
    }

    func sendMessage(chatId: String, toId: String) {
        if(messageText.trimmingCharacters(in: .whitespacesAndNewlines) != ""){
            loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
            guard let userId = loggedInUserEmail else {
                return
            }
//            let data : [String: Any] = [
//                "participants": [userId, toId] // Add the participants
//            ]
//
//            db.collection(COLLECTION_CHAT).document(chatId).setData(data) { error in
//                if let error = error {
//                    print("Error sending message: \(error.localizedDescription)")
//                } else {
//                    self.messageText = ""
//                    print("Message sent successfully")
//                    self.fetchChats()
//
//                }
//            }
            
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
                } else {
                    self.messageText = ""
                    print("Message sent successfully")
                    self.fetchChats()
                    
                }
            }
        }
        
    }
    
    func newChatRoom(id: String) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        guard let userId = loggedInUserEmail else {
            return
        }
        let data : [String: Any] = [
            "participants": [userId, id] // Add the participants
        ]
        
        let newchatroom = db.collection(COLLECTION_CHAT).addDocument(data: data){error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                self.messageText = ""
                print("Message sent successfully")
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
                print("Error sending message: \(err.localizedDescription)")
            } else {
                print("Message sent successfully")
            }
            
        }
        
    }


    func fetchChats() {
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

            var fetchedChats: [Chat] = []
            let dispatchGroup = DispatchGroup()
            print(#function, "chatroom found: \(snapshot?.documents.count)")
            for (index, document) in documents.enumerated() {
                let chatId = document.documentID
                dispatchGroup.enter()
                self.fetchMessages(for: chatId) { messages in
                    print("chatId", chatId)
                    let displayName = messages[0].toId == userId ? messages[0].fromId : messages[0].toId
                    let chat = Chat(id: chatId, displayName: displayName, messages: messages)
                    fetchedChats.append(chat)
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main){
                print(#function, "chatrooms fetched: \(self.chats.count)")
                for room in self.chats{
                    print("chatrooms name: \(room.displayName)")
                }
                self.chats = []
                    self.chats = fetchedChats
            }
            
        }
    }



    private func fetchMessages(for chatId: String, completion: @escaping ([Message]) -> Void) {

        db.collection(COLLECTION_CHAT).document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .getDocuments { (snapshot, error) in
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

                    return message
                }

                completion(messages)
            }
    }


}




