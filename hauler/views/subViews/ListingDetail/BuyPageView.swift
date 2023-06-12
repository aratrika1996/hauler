//
//  BuyPage.swift
//  hauler
//
//  Created by Homing Lau on 2023-06-08.
//

import SwiftUI

struct BuyPageView: View {
    var body: some View {
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
            NavigationLink(destination: ManageItemView()) {
                HStack(alignment: .center){
                    Spacer()
                    Text("Login")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                .background(Color("HaulerOrange"))
            }
            .cornerRadius(40)
            .padding(10)
            
            HStack {
                Text("Don't have an account? ")
                NavigationLink(destination: ManageItemView()) {
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

struct BuyPagViewe_Previews: PreviewProvider {
    static var previews: some View {
        BuyPageView()
    }
}
