//
//  FavoritesView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject private var viewRouter: ViewRouter
    @Binding var rootScreen :RootView
    
    var body: some View {
        VStack {
            if userProfileController.loggedInUserEmail != "" {
                if !userProfileController.userFavList.isEmpty {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 15), GridItem(.flexible(), spacing: 15)], alignment: .center, spacing: 20){
                        ForEach(listingController.favLists, id: \.self.id){item in
                            NavigationLink(destination:
                                            ProductDetailView(rootScreen: $rootScreen, listing: item)
                                .environmentObject(viewRouter)
                            ){
                                ZStack(alignment:.topTrailing) {
                                    VStack(alignment:.leading){
                                        Image(uiImage: (item.image ?? UIImage(systemName: "exclamationmark.triangle.fill"))!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 135)
                                            .cornerRadius(20, corners: [.topLeft, .topRight])
                                        VStack(alignment:.leading){
                                            Text(item.title)
                                                .font(.system(size: 18))
                                                .fontWeight(.medium)
                                                .foregroundColor(Color.black)
                                            Text("$" + String(item.price)).foregroundColor(Color(UIColor(named: "HaulerOrange") ?? .black))
                                                .font(.system(size: 15))
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.bottom, 10)
                                    }
                                    Image(systemName: "heart.fill")
                                        .resizable()
                                        .foregroundColor(.white)
                                        .frame(width: 15, height: 15)
                                        .padding(10)
                                        .background(Circle().fill(Color("HaulerOrange")))
                                        .padding(10)
                                        .onTapGesture {
                                            self.userProfileController.updateFavoriteList(listingToAdd: Favorites(listingID: item.id!), completion: {
                                                self.fetchData()
                                            })
                                            
                                        }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.gray.opacity(0.2), radius: 5, x:2, y:4)
                            
                        }
                    }
                    .padding(15)
                    Spacer(minLength: 0)
                }
                else {
                    VStack {
                        Text("Your haven't added anything in your list yet.")
                            .font(.system(size: 22))
                        
                            Button(action: {
                            }){
                                NavigationLink(destination: HomeView(rootScreen: $rootScreen)) {
                                    Text("Browse now")
                                        .font(.system(size: 18))
                                        .frame(maxWidth: 250)
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(UIColor(named: "HaulerOrange") ?? .blue))
                    
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                }
            }
            else {
                Text("Oops, looks like you are not logged in!!")
                    .padding(.bottom, 0.5)
                    .font(.system(size: 20))
                Text("Log in to see your favorites.")
                
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
        .navigationBarTitle("Favorites")
        .onAppear {
            self.fetchData()
        }
        .toolbar {
            if userProfileController.loggedInUserEmail != "" && !userProfileController.userFavList.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.userProfileController.removeAllFavourites(completion: {
                            listingController.favLists = []
                            fetchData()
                        })
                    }) {
                        Text("Remove All")
                    }
                }
            }
        }
    }
    
    func fetchData() {
        print("calling fetch data")
        userProfileController.getUserFavList()
        for (index, element) in userProfileController.userFavList.enumerated() {
            listingController.getListingByID(listingID: element.listingID, completion: {_,_  in
                print("fetched fav list")
            })
        }
    }
}

//struct FavoritesView_Previews: PreviewProvider {
//    static var previews: some View {
//        FavoritesView()
//    }
//}
