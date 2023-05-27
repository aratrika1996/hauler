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
    @Binding var rootScreen :RootView
    
    @State private var linkSelection : Int? = nil
    var body: some View {
        if userProfileController.loggedInUserEmail == ""{
            NoChatView(rootScreen: $rootScreen)
        }
        else{
            Text("")
        }
        
        }
}

struct NoChatView: View{
    @Binding var rootScreen :RootView
    var body :some View {
        VStack{
            Text("Chat")
                .font(.system(size: 30))
                .padding(.bottom, 20)
            Text("Keep your message in one place.")
            Text("Log in to manage your chats.")
            
            NavigationLink(destination: LoginView(rootScreen: $rootScreen)) {
                Text("Login")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()
            }
            .padding([.top], 30)
            .buttonStyle(.borderedProminent)
            .tint(Color(UIColor(named: "HaulerOrange") ?? .blue))
            
            HStack {
                Text("Don't have an account? ")
                NavigationLink(destination: SignUpView(rootScreen: $rootScreen)) {
                    Text("SignUp")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding()
                }
            }//HStack ends
        }
        .padding(15)
    }
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
