//
//  NotoficationView.swift
//  hauler
//
//  Created by Homing Lau on 2023-07-18.
//

import SwiftUI

struct NotoficationView: View {
    @EnvironmentObject var userProfileController : UserProfileController
    var body: some View {
        List(userProfileController.userProfile.uNotifications, id: \.self){noti in
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

struct NotoficationView_Previews: PreviewProvider {
    static var previews: some View {
        NotoficationView()
    }
}
