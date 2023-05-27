//
//  ContentView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 1
    @State private var title : [String] = ["","Home", "Chats", "Posts", "Listings", "Profile"]
    
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var imageController : ImageController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var chatController : ChatController
    
    @Binding var rootScreen :RootView
    
    var body: some View {
            TabView(selection: self.$tabSelection) {
                Group {
                HomeView()
                    .tabItem {
                    Image(systemName: "house")
                    Text(title[1])
                }
                .tag(1)
                
                    ChatView(rootScreen: $rootScreen).environmentObject(authController).environmentObject(userProfileController).environmentObject(chatController).tabItem {
                    Image(systemName: "text.bubble")
                    Text(title[2])
                }
                .tag(2)
                
                
                PostView().environmentObject(imageController).environmentObject(listingController).tabItem {
                    Image(systemName: "camera")
                    Text(title[3])
                }
                .tag(3)
                
                UserListingsView().tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait")
                    Text(title[4])
                        
                }
                .tag(4)
                
                ProfileView().environmentObject(authController).environmentObject(userProfileController).tabItem {
                    Image(systemName: "person")
                    Text(title[5])
                        
                    }
                    .tag(5)
                }
                
            }

            .navigationTitle($title[tabSelection])
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
            .onChange(of: tabSelection, perform: {tabint in
                if(tabint != 1){
                    listingController.removeAllListener()
                }else if(tabint != 4){
                    listingController.removeUserListener()
                }
            })
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
