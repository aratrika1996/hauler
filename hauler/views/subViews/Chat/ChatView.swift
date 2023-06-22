//
//  ChatView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var chatController : ChatController
    @Binding var rootScreen :RootView
    @State var isLoading : Bool = true
    
    @State private var linkSelection : Int? = nil
    var body: some View {
        if(isLoading){
            SplashScreenView()
                .onAppear{
                    print("ChatAppear")
                        chatController.fetchChats(completion: {
                            chatController.chatDict.keys.forEach{
                                userProfileController.getUserByEmail(email: $0, completion: {_,_ in
                                    isLoading = false
                                })
                            }
                            
                        })
                        
                }
                .onDisappear{
                    print("ChatGone")
                }

        }else{
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
    
}






//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
