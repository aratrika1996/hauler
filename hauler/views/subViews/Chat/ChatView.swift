//
//  ChatView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI
import PromiseKit

struct ChatView: View {
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var chatController : ChatController
    @Binding var rootScreen :RootView
    @State var isLoading : Bool = true
    @State private var keycount : Int = 0
    
    @State private var linkSelection : Int? = nil
    let chatresult : [String] = []
    var body: some View {
        VStack{
            if userProfileController.loggedInUserEmail == ""{
                NoChatView(rootScreen: $rootScreen)
            }
            else if(chatController.chatDict.isEmpty && !chatController.newChatRoom){
                ZeroChatView()
            }
            else{
                ChatListView()
            }
            
        }
    }
}
//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
