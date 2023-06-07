//
//  UserListingsView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct UserListingsView: View {
    @EnvironmentObject var listingController : ListingController
    @State private var isLoading = true
    @State var tabIndex = 0
    
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
                    CustomTopTabBarView(tabIndex: $tabIndex)
                    if tabIndex == 0 {
                        AvailableListingsView()
                    }
                    else {
                        SoldListingsView()
                    }
                    Spacer()
                }
        .frame(width: UIScreen.main.bounds.width - 24, alignment: .center)
                .padding(0)
        
    }
}


struct UserListingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserListingsView()
    }
}
