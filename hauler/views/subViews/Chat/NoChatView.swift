//
//  NoChatView.swift
//  hauler
//
//  Created by Homing Lau on 2023-06-11.
//

import SwiftUI

struct NoChatView: View{
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    @Binding var rootScreen :RootView
    var body :some View {
        VStack{
            Spacer()
            ChatImageLogo()
                .padding(.bottom, 50)
            VStack{
                Text("Chat")
                    .font(.title)
                    .padding(.bottom)
                VStack{
                    Text("Keep your message in one place.")
                    Text("Log in to manage your chats.")
                }
                .foregroundColor(.gray)
                .font(.subheadline)
            }
            Spacer()
            NavigationLink(destination: LoginView(rootScreen: $rootScreen)) {
                HStack(alignment: .center){
                    Spacer()
                    Text("Login")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    Spacer()
                }
                .background(Color("HaulerOrange"))
            }
            .padding(.horizontal, 20)
            .padding([.top], 10)
            .buttonStyle(.borderedProminent)
            
            HStack {
                Text("Don't have an account? ")
                NavigationLink(destination: SignUpView(rootScreen: $rootScreen)) {
                    Text("SignUp")
                        .font(.headline)
                        .foregroundColor(Color("HaulerOrange"))
                        .padding()
                }
            }//HStack ends
            Spacer()
        }
    }
}
