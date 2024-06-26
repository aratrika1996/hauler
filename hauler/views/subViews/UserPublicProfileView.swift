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
    @EnvironmentObject private var viewRouter: ViewRouter
    var passedInTitle : String? = nil
    @State var sellerEmail : String
    @State private var name : String = ""
    @State private var email : String = ""
    @State private var profileImage: UIImage? = nil
    
    @Binding var rootScreen :RootView
    
    
    var body: some View {
        VStack(alignment: .leading) {
//            Profile overview
            ZStack(alignment: .topTrailing){
//                Button(action: {
//                    if let uIdx = userProfileController.userProfile.uFollowedUsers.firstIndex(where: {$0.email == email}){
//                        userProfileController.userProfile.uFollowedUsers.remove(at: uIdx)
//                    }else{
//                        userProfileController.userProfile.uFollowedUsers.append(FollowedUser(email: email))
//                    }
//                    userProfileController.updateFollowedUsers()
//                }){
//                    (userProfileController.userProfile.uFollowedUsers.contains(where: {$0.email == email}) ?
//                     Text("Unfollow")
//                     .foregroundColor(Color(.red))
//                     :
//                        Text("Follow")
//                        .foregroundColor(Color("HaulerOrange"))
//                     )
//
//                }
//                .background(.white)
                HStack(alignment: .center) {
                    
                        if profileImage != nil {
                            Image(uiImage: self.profileImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                .scaledToFit()
                        }
                        else {
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.black)
                                .padding(15)
                                .background(Color.gray)
                                .clipShape(Circle())
                        }
                    VStack(alignment: .leading) {
                        Text(self.name)
                            .foregroundColor(Color(UIColor(named: "HaulerOrange") ?? .blue))
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                            .padding(.bottom, 0.3)
                        Text(self.email)
                        
                    }
                    .padding(.leading, 8)
                    Spacer()
                    Button(action: {
                        if let uIdx = userProfileController.userProfile.uFollowedUsers.firstIndex(where: {$0.email == email}){
                            userProfileController.userProfile.uFollowedUsers.remove(at: uIdx)
                        }else{
                            userProfileController.userProfile.uFollowedUsers.append(FollowedUser(email: email))
                        }
                        userProfileController.updateFollowedUsers()
                    }) {
                        (userProfileController.userProfile.uFollowedUsers.contains(where: {$0.email == email}) ?
                         HStack {
                             Image(systemName: "checkmark")
                                 .frame(width: 10, height: 10)
                                 .foregroundColor(.white)
                             Text("Following")
                                 .foregroundColor(.white)
                                 
                         }
                         .padding(.vertical, 7)
                         .padding(.horizontal, 15)
                         .background(Color("HaulerOrange"))
                         :
                        HStack {
                            Image(systemName: "plus")
                                .frame(width: 10, height: 10)
                                .foregroundColor(.black)
                            Text("Follow")
                                .foregroundColor(.black)
                                
                        }
                        .padding(.vertical, 7)
                        .padding(.horizontal, 20)
                        .background(Color(red: 217/255, green: 217/255, blue: 217/255))
                         )
                    }
                    
                }//HStack ends
                .padding(.bottom, 20)
            }
            
            
//            Listing view
            VStack {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 15), GridItem(.flexible(), spacing: 15)], alignment: .center, spacing: 15){
                    ForEach(Array(listingController.sellerListings.enumerated()), id:\.element){idx, item in
                        NavigationLink(destination: ProductDetailView(rootScreen: $rootScreen, listing: item).environmentObject(viewRouter)){
                            VStack(alignment:.leading){
                                Image(uiImage: (item.image ?? UIImage(systemName: "exclamationmark.triangle.fill"))!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 135)
                                    .cornerRadius(20, corners: [.topLeft, .topRight])
                                
                                VStack(alignment:.leading) {
                                    Text(item.title)
                                        .font(.system(size: 18))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.black)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Text("$" + String(item.price)).foregroundColor(Color(UIColor(named: "HaulerOrange") ?? .black))
                                        .font(.system(size: 15))
                                }
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                                
                            }
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.gray.opacity(0.2), radius: 5, x:2, y:4)
                            
                        }
                    }
                }
            }
            Spacer()
                
        }
        .navigationTitle(passedInTitle == nil ? "Owner's Page" : passedInTitle!)
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .onAppear {
            self.userProfileController.getPublicProfileByEmail(email: sellerEmail) {_,_ in
                self.name = self.userProfileController.publicProfile.uName
                self.email = self.userProfileController.publicProfile.uEmail
                self.loadImage(from: self.userProfileController.publicProfile.uProfileImageURL ?? "")
            }
            
            self.listingController.getListingsByEmail(sellerEmail: sellerEmail, completion: {_, err in
                if let err = err{
                    print(#function, err)
                }else{
                    print(#function, "good to go, counts = \(listingController.sellerListings)")
                }
                //isLoading = false
            })
        }
    }
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            // Handle invalid URL
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                // Handle error during image loading
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            
            if let imageData = data, let loadedImage = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.profileImage = loadedImage
                }
            }
        }.resume()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//struct UserPublicProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserPublicProfileView()
//    }
//}
