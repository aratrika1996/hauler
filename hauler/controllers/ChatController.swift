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
    private static var shared : ChatController?
    private let COLLECTION_CHAT: String = "Chat"
    private var userId: String?
    private let db = Firestore.firestore()
    var loggedInUserEmail: String?

    init() {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
//        fetchChats()
//        sendMessage(chatId: "dasdasdasd")
    }
    
    static func getInstance() -> ChatController?{
        if (shared == nil){
            shared = ChatController()
        }
        
        return shared
    }

    func sendMessage(chatId: String) {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        guard let userId = loggedInUserEmail else {
            return
        }

        // Add the participants field to the message data
        let messageData: [String: Any] = [
            "fromId": userId,
            "toId": "test@email.com",
            "text": messageText, // messageText,
            "timestamp": Date(),
            "participants": [userId, "test2@email.com"] // Add the participants
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
            for document in documents {
                let chatId = document.documentID
//                let displayName = "name test" // Set the display name based on your logic
                dispatchGroup.enter()
                print("we are running")
                self.fetchMessages(for: chatId) { messages in
                    let chat = Chat(id: chatId, displayName: document.documentID, messages: messages)
                    fetchedChats.append(chat)
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main){
                print(#function, "chatrooms fetched: \(self.chats.count)")
                for room in self.chats{
                    print("chatrooms name: \(room.displayName)")
                }
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




