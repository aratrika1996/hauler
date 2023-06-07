//
//  ContentView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 1
    @State private var title : [String] = ["Hauler","Home", "Chats", "Posts", "Listings", "Profile"]
    @State var newChatId : String?
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var imageController : ImageController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var chatController : ChatController
    
    @Binding var rootScreen :RootView
    
    var body: some View {
        TabView(selection: self.$tabSelection) {
            HomeView(toChatPage: {id in
                if let id = id{
                    newChatId = id
                    tabSelection = 2
                }
            })
            .tabItem {
                Image(systemName: "house")
                Text(title[1])
            }
            .tag(1)
            
            ChatView(startNewChatWithId: newChatId,rootScreen: $rootScreen).tabItem {
                Image(systemName: "text.bubble")
                Text(title[2])
            }
            .tag(2)
            
            
            PostView().tabItem {
                Image(systemName: "camera")
                Text(title[3])
            }
            .tag(3)
            
            UserListingsView().tabItem{
                Image(systemName: "list.bullet.rectangle.portrait")
                Text(title[4])
                
            }
            .tag(4)
            
            ProfileView(rootScreen: $rootScreen).tabItem{
                Image(systemName: "person")
                Text(title[5])
            }
            .tag(5)
        }
        .navigationTitle($title[tabSelection])
        .navigationTitle(((tabSelection == 1) ? $title[0] : $title[tabSelection]))
        .toolbar(content: {
            if(tabSelection == 1){
                ToolbarItem(content: {
                    HStack{
                        //                        Text(title[tabSelection])
                        Spacer()
                        Image(uiImage: UIImage(systemName: "heart.fill")!)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(15)
                            .background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Circle())
                        Image(uiImage: UIImage(systemName: "bell")!)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(15)
                        //                        .background((adminMode ? Color(red: 0.5, green: 0.5, blue: 0.5) : Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Circle()))
                            .onTapGesture {
                                listingController.adminMode = !listingController.adminMode
                                listingController.removeAllListener()
                                listingController.getAllListings(adminMode: listingController.adminMode, completion: {_, err in if let err = err{print(err)}})
                            }
                    }
                    .padding(.horizontal, 10)
                })
            }
        })
        .onAppear() {
            UITabBar.appearance().backgroundColor = UIColor(named: "BackgroundGray") ?? .white
            
        }
        .environmentObject(authController)
        .environmentObject(listingController)
        .environmentObject(imageController)
        .environmentObject(userProfileController)
        .environmentObject(chatController)
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
