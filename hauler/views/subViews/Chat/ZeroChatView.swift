//
//  ZeroChatView.swift
//  hauler
//
//  Created by Homing Lau on 2023-06-11.
//

import SwiftUI

struct ZeroChatView: View{
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var viewController : ViewRouter
    
    @Environment(\.dismiss) var dismiss
    var body :some View {
        VStack{
            ChatImageLogo()
                .padding(.bottom)
            Text("Send a message")
                .font(.title)
                .padding(.bottom)
            Text("Start a chat by browsing new stuffs.")
            HStack{
                Spacer()
                Text("Start Browsing")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(12)
                    .onTapGesture {
                        viewController.currentView = .main
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                Spacer()
            }
            .background(Color("HaulerOrange"))
            .cornerRadius(15)
            .padding([.top], 30)
        }
        
        .padding(15)
    }
}

struct ZeroChatView_Previews: PreviewProvider {
    static var previews: some View {
        ZeroChatView()
    }
}
