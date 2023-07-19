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
                Text(noti.createdBy)
                Text(noti.timestamp.dateValue().formatted())
            }
        }
    }
}

struct NotoficationView_Previews: PreviewProvider {
    static var previews: some View {
        NotoficationView()
    }
}
