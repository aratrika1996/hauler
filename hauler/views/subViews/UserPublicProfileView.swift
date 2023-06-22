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
    
    @State var sellerEmail : String
    @State private var name : String = ""
    @State private var email : String = ""
    @State private var profileImage: UIImage? = nil
    
    @Binding var rootScreen :RootView
    
    
    var body: some View {
        VStack(alignment: .leading) {
//            Profile overview
            HStack(alignment: .center) {
                
                    if profileImage != nil {
                        Image(uiImage: self.profileImage!)
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
            .padding(.bottom, 20)
            
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
        .navigationTitle("Owner's Page")
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
