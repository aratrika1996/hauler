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
    @Published var chatMap : [String:Chat] = [:]
    @Published var messageText: String = ""
    private static var shared : ChatController?
    private let COLLECTION_CHAT: String = "Chat"
    private var userId: String?
    private let db = Firestore.firestore()
    var loggedInUserEmail: String?
    var listener : ListenerRegistration? = nil

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


    func fetchChats() {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
        guard let userId = loggedInUserEmail else {
            return
        }

        self.listener = db.collectionGroup("messages").whereField("participants", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
            print("started fetching data")
            if let error = error {
                print("Error fetching chats: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No chats found")
                return
            }
            let dispatchGroup = DispatchGroup()
            print(#function, "chatroom found: \(snapshot?.documents.count)")
            for document in documents {
                let parentId = document.reference.parent.parent?.documentID
                if self.chatMap[parentId!] == nil {
                    print(#function, "parentId: \(parentId) has no msg yet")
                    self.chatMap[parentId!] = Chat(id: parentId!, displayName: parentId!, messages: [])
                }else{
                    print(#function, "parentId: \(parentId) contains msg, count = \(self.chatMap[parentId!]?.messages.count)")
                }
                if let newmsg = Message(id: document.documentID, dictionary: document.data()){
                    print(#function, "Got new Msg: \(newmsg.text), id = \(newmsg.id)")
                    
                    if let chatroom = self.chatMap[parentId!]{
                        print(#function, "Chatroom id:\(chatroom.id) exist with msg:\(chatroom.messages)")
                        if(!chatroom.messages.contains(where: {
                            $0.id == newmsg.id
                        })){
                            chatroom.messages.append(newmsg)
                        }
                    }
                }
                dispatchGroup.enter()
            }
                
            dispatchGroup.notify(queue: .main){
                print(#function, "chatrooms fetched: \(self.chats.count)")
                for room in self.chats{
                    print("chatrooms name: \(room.displayName)")
                }
            }
            
        }
    }
    
    func removeListener(){
        self.listener?.remove()
    }
}




