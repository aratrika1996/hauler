//
//  UserListingsView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct UserListingsView: View {
    @EnvironmentObject var listingController : ListingController
    
    var body: some View {
        ScrollView(.vertical){
            VStack{
                if(!listingController.userListings.isEmpty){
//                    LazyHGrid(rows: [GridItem()], alignment: .center){
                        ForEach(listingController.userListings, id: \.self.id){item in
    //                        NavigationLink(destination: productDetailView(listing: item)){
                                HStack{
                                    Image(uiImage: (item.image ?? UIImage(systemName: "exclamationmark.triangle.fill"))!).resizable().frame(width: 100, height: 100)
                                    Spacer()
                                    VStack{
                                        Text(item.title).padding()
                                        Text("$" + String(item.price)).foregroundColor(Color(red: 0.302, green: 0.47, blue: 0.256, opacity: 0.756))
                                    }
                                    
                                }
                                
    //                        }
                                .padding().background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Rectangle()).cornerRadius(15).padding()
                            .onLongPressGesture(perform: {
                                print("Long Pressed")
                            })
                        }
//                    }
                }else{
                    Text("Nothing To Show")
                }
                Spacer()
            }
        }
        .onAppear(){
            listingController.getAllUserListings(completion: {_, err in
                if let err = err{
                    print(#function, err)
                }
            })
        }
        .onDisappear(){
            listingController.removeUserListener()
        }
    }
}

struct UserListingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserListingsView()
    }
}
