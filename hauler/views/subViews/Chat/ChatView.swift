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
                    if(chatController.chatDict.isEmpty){
                        chatController.fetchChats(completion: {
                            Task{
                                await userProfileController.getUsersByEmail(email: Array(chatController.chatDict.keys), completion: {success in
                                    if(success){
                                        isLoading = false
                                    }
                                })
                            }
                            
                        })
                    }else{
                        Task{
                            await userProfileController.getUsersByEmail(email: Array(chatController.chatDict.keys), completion: {success in
                                if(success){
                                    isLoading = false
                                }
                            })
                        }
                    }
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
