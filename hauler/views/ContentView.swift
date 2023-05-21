//
//  ContentView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 1
    
    var body: some View {
        NavigationView {
            TabView(selection: self.$tabSelection) {
                HomeView().tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(1)
                
                ChatView().tabItem {
                    Image(systemName: "text.bubble")
                    Text("Chats")
                }
                .tag(2)
                
                PostView().tabItem {
                    Image(systemName: "camera")
                    Text("Posts")
                }
                .tag(3)
                
                UserListingsView().tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait")
                    Text("Listings")
                }
                .tag(4)
                
                ProfileView().tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(5)
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
