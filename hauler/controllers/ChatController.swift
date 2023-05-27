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
    private let COLLECTION_CHAT: String = "Chat"
    private var userId: String?
    private let db = Firestore.firestore()
    var loggedInUserEmail: String?

    init() {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        fetchChats()
        sendMessage(chatId: "dasdasdasd")
    }

    func sendMessage(chatId: String) {
        guard let userId = loggedInUserEmail else {
            return
        }

        // Add the participants field to the message data
        let messageData: [String: Any] = [
            "fromId": userId,
            "toId": "test_id",
            "text": "genkwqnd test", // messageText,
            "timestamp": Date(),
            "participants": [userId, "test2@email.com"] // Add the participants
        ]

        db.collection(COLLECTION_CHAT).document(chatId).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                self.messageText = ""
                print("Message sent successfully")
            }
        }
    }


    private func fetchChats() {
        guard let userId = loggedInUserEmail else {
            return
        }

        db.collection(COLLECTION_CHAT).whereField("participants", arrayContains: userId).addSnapshotListener { snapshot, error in
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

            for document in documents {
                let chatId = document.documentID
                let displayName = "name test" // Set the display name based on your logic

                dispatchGroup.enter()
                self.fetchMessages(for: chatId) { messages in
                    print(messages)
                    let chat = Chat(id: chatId, displayName: displayName, messages: messages)
                    fetchedChats.append(chat)
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
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
                    return Message(dictionary: messageDict)
                }

                completion(messages)
            }
    }


}




