//
//  FavoritesView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var userProfileController : UserProfileController
    
    var body: some View {
        VStack {
            List(listingController.favLists) { favItem in
                VStack(alignment: .leading) {
                    HStack {
                        Image(uiImage: (favItem.image ?? UIImage(systemName: "exclamationmark.triangle.fill"))!).resizable().frame(width: 100, height: 100)
                            .cornerRadius(10)
                        
                        VStack (alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(favItem.title)
                                        .font(.system(size: 21))
                                        .fontWeight(.medium)
                                    
                                    Text("$" + String(favItem.price))
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(UIColor(named: "HaulerOrange") ?? .blue))
                                        .fontWeight(.medium)
                                }
                            }
                            .padding(.bottom, 0.1)
                            
                        }
                        
                    }
                }
            }
        }
        .onAppear {
            userProfileController.getUserFavList()
            for (index, element) in userProfileController.userFavList.enumerated() {
                listingController.getListingByID(listingID: element.listingID, completion: {_,_  in
                    print("fetched fav list")
                })
            }
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
