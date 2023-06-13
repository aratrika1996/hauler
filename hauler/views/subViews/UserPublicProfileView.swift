//
//  UserPublicProfileView.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-06-08.
//

import SwiftUI

struct UserPublicProfileView: View {
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var imageController : ImageController
    
    @State var sellerEmail : String
    @State private var name : String = ""
    @State private var email : String = ""
    @State private var profileImage: UIImage? = nil
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                
                    if profileImage != nil {
                        Image(uiImage: profileImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            .scaledToFit()
                    }
                    else {
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                            .padding(30)
                            .background(Color.gray)
                            .clipShape(Circle())
                    }
                VStack(alignment: .leading) {
                    Text(self.name)
                        .foregroundColor(Color(UIColor(named: "HaulerOrange") ?? .blue))
                        .font(.system(size: 22))
                        .fontWeight(.medium)
                        .padding(.bottom, 0.3)
                    Text(self.email)
                    HStack {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.yellow)
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.yellow)
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.yellow)
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.yellow)
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.yellow)
                        Text("5.0")
                        Text("(8)")
                    }
                }
                .padding(.leading, 10)
            }//HStack ends
                
        }
        .onAppear {
            self.userProfileController.getPublicProfileByEmail(email: sellerEmail) {_,_ in 
                self.name = self.userProfileController.publicProfile.uName
                self.email = self.userProfileController.publicProfile.uEmail
            }
        }
    }
}

//struct UserPublicProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserPublicProfileView()
//    }
//}
