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
    @Published var messageText: String = ""
    @Published var toId : String? = nil
    @Published var selectedChar : Chat? = nil
    @Published var msgCount : Int = 0
    @Published var sortedKeyDict : [String:Date] = [:]
    @Published var chatRef : ListenerRegistration? = nil
    @Published var msgRef : ListenerRegistration? = nil
    
    private static var shared : ChatController?
    private let COLLECTION_CHAT: String = "Chat"
    private var userId: String?
    private let db = Firestore.firestore()
    
    var loggedInUserEmail: String?
    var redirect : Bool = false
    var newChatRoom : Bool = false
    var sortedKey : [String]{
        get{
            sortedKeyDict.keys.sorted{
                sortedKeyDict[$0]! > sortedKeyDict[$1]!
            }
        }
    }
    
    init() {
        loggedInUserEmail = Auth.auth().currentUser?.email ?? ""
    }
    
    static func getInstance() -> ChatController?{
        if (shared == nil){
            shared = ChatController()
        }
        
        return shared
    }
    
    func loginInitialize(who: String){
        self.loggedInUserEmail = who
        self.fetchChats(completion: {_ in})
    }
    
    func logoutClear(){
        chatRef!.remove()
        chatRef = nil
        chatDict.removeAll()
        sortedKeyDict.removeAll()
        messageText = ""
        msgCount = 0
        toId = nil
        selectedChar = nil
        userId = nil
        loggedInUserEmail = nil
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
                "unread": true,
                "timestamp": Date()
            ]
            
            db.collection(COLLECTION_CHAT).document(chatId).collection("messages").addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    self.messageText = ""
                    print("Message sent successfully")
                }
                complete()
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
            "unread": true,
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
    
    func readAllUnread(userId:String){
        guard let chatroom = self.chatDict[userId] else{
            return
        }
        let msgs = chatroom.messages.filter{msg in return msg.unread == true && msg.toId == loggedInUserEmail}
        print("trying to unread msg with count \(msgs.count)...msgs = \(msgs)")
        if !msgs.isEmpty{
            msgs.forEach{msg in
                db.collection(COLLECTION_CHAT).document(chatroom.id).collection("messages").document(msg.id!).setData(["unread":false], merge: true)
            }
        }
    }
    
    func fetchChats(completion: @escaping ([String]) -> Void){
        loggedInUserEmail = Auth.auth().currentUser?.email ?? UserDefaults.standard.string(forKey: "KEY_EMAIL")
        guard let userId = loggedInUserEmail else {
            return
        }
        let dp = DispatchGroup()
        self.chatRef = db.collectionGroup("messages")
            .whereFilter(.orFilter([Filter.whereField("fromId", isEqualTo: userId),Filter.whereField("toId", isEqualTo: userId)]))
            .addSnapshotListener({snapshot, error in
                print("started fetching data")
                if let error = error {
                    print("Error fetching chats: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No chats found")
                    return
                }
                print(#function, "msg found: \(documents.count)")
                var key : [String] = []
                snapshot?.documentChanges.forEach{obj in
                    dp.enter()
                    guard let newmsg = Message(id: obj.document.documentID, dictionary: obj.document.data()) else{
                        return
                    }
                    guard let parentId = obj.document.reference.parent.parent?.documentID else{
                        return
                    }
                    let displayName = newmsg.fromId == self.loggedInUserEmail ? newmsg.toId : newmsg.fromId
                    if self.chatDict[displayName] == nil{
                        let pp = [newmsg.fromId, newmsg.toId]
                        self.chatDict[displayName] = Chat(participants: pp, id: parentId, displayName: displayName, messages: [])
                    }
                    switch(obj.type){
                    case .added:
                        print("got new msg, to\(newmsg.toId), me=\(userId)")
                        if newmsg.unread && newmsg.toId == userId{
                            self.chatDict[displayName]?.addUnread()
                            self.msgCount += 1
                            print("New Unread!, count=\(self.msgCount)")
                        }
                        self.chatDict[displayName]?.messages.append(newmsg)
                    case .modified:
                        if let modifiedMsgIdx = self.chatDict[displayName]?.messages.firstIndex(where: {msg in
                            msg.id == newmsg.id
                        }){
                            let copy = self.chatDict[displayName]?.messages[modifiedMsgIdx]
                            if copy?.unread ?? true && !newmsg.unread && newmsg.toId == userId{
                                self.msgCount -= 1
                                self.chatDict[displayName]?.minusUnread()
                                print("Unread changed to read, count=\(self.msgCount)")
                            }
                            self.chatDict[displayName]?.messages[modifiedMsgIdx] = newmsg
                            
                        }
                    case .removed:
                        if let modifiedMsgIdx = self.chatDict[displayName]?.messages.firstIndex(where: {msg in
                            msg.id == newmsg.id
                        }){
                            self.chatDict[displayName]?.messages.remove(at: modifiedMsgIdx)
                        }
                    }
//                    print("After changed, chatroom \(parentId) has \(self.chatDict[parentId]?.messages.count) msg")
                    self.chatDict[displayName]?.messages.sort{
                        $0.timestamp.dateValue() < $1.timestamp.dateValue()
                    }
                    if(displayName != self.loggedInUserEmail){
                        self.sortedKeyDict[displayName] = self.chatDict[displayName]?.messages.last?.timestamp.dateValue()
                    }
                    dp.leave()
                }
                let result = dp.wait(timeout: .now() + 5)
                if result.self == .success{
                    key = self.sortedKeyDict.keys.sorted{
                        $0 < $1
                    }
                    completion(key)
                }else{
                    key = self.sortedKeyDict.keys.sorted{
                        $0 < $1
                    }
                    completion(key)
                }
            })
        
    }
}




