//
//  NotoficationView.swift
//  hauler
//
//  Created by Homing Lau on 2023-07-18.
//

import SwiftUI

struct NotoficationView: View {
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject private var viewRouter: ViewRouter
    @Environment(\.dismiss) var dismiss
    @Binding var rootScreen :RootView
    var body: some View {
        List(userProfileController.userProfile.uNotifications.sorted{$0.timestamp > $1.timestamp}, id: \.self){noti in
            if let list = listingController.listingsList.first(where: {$0.id == noti.item}){
                NavigationLink(destination: ProductDetailView(rootScreen: $rootScreen, listing: list)){
                    HStack{
                        VStack(alignment: .leading){
                            Text(noti.createdBy)
                                .font(.title2)
                            Text(noti.msg ?? "")
                                .font(.caption)
                        }
                        Spacer()
                        Text(noti.timestamp.convertToTag())
                        
                    }

                }
            }else{
                VStack{
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text(noti.createdBy)
                                .font(.title2)
                            Text(noti.msg ?? "")
                                .font(.caption)
                        }
                        Spacer()
                        Text(noti.timestamp.convertToTag())
                    }
                    
                    
                }
            }
            
        }
    }
}

//struct NotoficationView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotoficationView()
//    }
//}
