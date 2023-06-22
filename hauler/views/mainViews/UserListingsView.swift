//
//  UserListingsView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct UserListingsView: View {
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var chatController : ChatController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var imageController : ImageController
    //@EnvironmentObject var listingController : ListingController
    @State private var isLoading = true
    @State var tabIndex = 0
    @Binding var rootScreen :RootView
    
    var body: some View {
//        if(isLoading){
//            ProgressView()
//                .onAppear {
//                    listingController.getAllUserListings(completion: {_, err in
//                        if let err = err{
//                            print(#function, err)
//                        }else{
//                            print(#function, "good to go, counts = \(listingController.userListings)")
//                        }
//                        isLoading = false
//                    })
//                }
//        }
//        else{
//            if(!listingController.userListings.isEmpty){
//                List{
//                    ForEach(Array(listingController.userListings.enumerated()), id:\.element){idx, item in
//                        HStack{
//                            Image(uiImage: (item.image ?? UIImage(systemName: "exclamationmark.triangle.fill"))!).resizable().frame(width: 100, height: 100)
//                            Spacer()
//                            VStack{
//                                Text(item.title).padding()
//                                Text("$" + String(item.price)).foregroundColor(Color(red: 0.302, green: 0.47, blue: 0.256, opacity: 0.756))
//                            }
//
//                        }
//                        .swipeActions(){
//                            Button("Delete"){
//                                print("delete activiated")
//                            }
//                            .tint(.red)
//                        }
//                        .padding()
//                        .background(Color("HaulerOrange"))
//                        .cornerRadius(15)
//                        .padding(.horizontal, 10)
//
//                    }
//                }
//                .scrollContentBackground(.hidden)
//                .onDisappear(){
//                    listingController.removeUserListener()
//                }
//            }else{
//                Text("Nothing To Show")
//            }
//        }
        VStack{
            if userProfileController.loggedInUserEmail != "" {
                CustomTopTabBarView(tabIndex: $tabIndex)
                if tabIndex == 0 {
                    AvailableListingsView(rootScreen: $rootScreen)
                }
                else {
                    SoldListingsView()
                }
                Spacer()
            }
            else {
                Text("Oops, looks like you are not logged in!!")
                    .padding(.bottom, 0.5)
                    .font(.system(size: 20))
                Text("Log in to see your listings.")
                
                NavigationLink(destination: LoginView(rootScreen: $rootScreen).environmentObject(authController).environmentObject(userProfileController)) {
                    Text("Login")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    
                }
                .padding(.horizontal, 20)
                .padding([.top], 10)
                .buttonStyle(.borderedProminent)
                .tint(Color(UIColor(named: "HaulerOrange") ?? .blue))
                
                HStack {
                    Text("Don't have an account? ")
                    NavigationLink(destination: SignUpView(rootScreen: $rootScreen).environmentObject(authController).environmentObject(userProfileController)) {
                        Text("SignUp")
                            .foregroundColor(Color(UIColor(named: "HaulerOrange") ?? .blue))
                            .fontWeight(.medium)
                    }
                }//HStack ends
                .padding([.top], 10)
            }
                }
        .frame(width: UIScreen.main.bounds.width - 24, alignment: .center)
                .padding(0)
        
    }
}


//struct UserListingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserListingsView()
//    }
//}
