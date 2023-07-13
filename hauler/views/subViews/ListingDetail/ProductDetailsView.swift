//
//  productDetailView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI
import MapKit

struct ProductDetailView: View {
    @EnvironmentObject var chatController : ChatController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var viewRouter : ViewRouter
    @Environment(\.dismiss) var dismiss
    
    @State var isLoading : Bool = true
    @State var showAlert : Bool = false
    @State var showMore : Bool = false
    @State var path : NavigationPath = NavigationPath()
    @State var inputText : String = "Hi, I am interested in the product with name "
    @State private var openEditSheet = false
    
    @Binding var rootScreen :RootView
    
    let listing : Listing
    
    var body: some View {
        NavigationView(){
            if(isLoading){
                SplashScreenView()
                    .onAppear{
                        Task{
                            print(#function, "task start")
                            if userProfileController.userDict[listing.email] == nil{
                                print(#function, "email not found, load profile")
                                userProfileController.getUserByEmail(email: listing.email, completion: {_,_ in
                                    isLoading = false
                                })
                                
                            }else{
                                print(#function, "email found, ok")
                                isLoading = false
                            }
                        }
                    }
            }else{
                ZStack(alignment: .bottom){
                    ScrollView(.vertical){
                        Image(uiImage: (listing.image!)).resizable().frame(height: 320).aspectRatio(contentMode: .fill)
                        HStack{
                            VStack(alignment: .leading){
                                Text("\(listing.title)")
                                    .font(.system(size: 22))
                                    .fontWeight(.bold)
                                Text("$\(listing.price.formatted())")
                                    .foregroundColor(Color("HaulerOrange"))
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                            }
                            Spacer()
                            if(listing.email != chatController.loggedInUserEmail && userProfileController.loggedInUserEmail != ""){
                                Image(uiImage: UIImage(systemName: "text.bubble")!)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(15)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 5))
                                    .cornerRadius(5)
                                    .shadow(color: Color.gray.opacity(0.4), radius: 5, x:2, y:4)
                                    .onTapGesture {
                                        if(
                                            chatController.chatDict.keys.contains(where: {
                                                $0 == listing.email
                                            })){
                                            viewRouter.currentView = .chat
                                            chatController.toId = listing.email
                                            chatController.redirect = true
                                            dismiss()
                                        }
                                        else{
                                            showAlert = true
                                        }
                                    }
                            }
                            Image(uiImage: UIImage(systemName: "heart.fill")!)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(15)
                                .background(.white, in: RoundedRectangle(cornerRadius: 5))
                                .cornerRadius(5)
                                .shadow(color: Color.gray.opacity(0.4), radius: 5, x:2, y:4)
                        }
                        .padding()
                        VStack(alignment: .leading){
                            HStack(){
                                Text("Description").font(.system(size: 19)).fontWeight(.medium)
                                Spacer()
                            }
                            ExpandableText("\(listing.desc)")
                                .font(.body)
                                .foregroundColor(.gray)
                                .lineLimit(3)
                                .moreButtonText("More detailed")
                                .moreButtonColor(Color("HaulerOrange"))
                                .lessButtonText("less")
                                .expandAnimation(.default)
                                .trimMultipleNewlinesWhenTruncated(true)
                            
                        }.padding()
                        VStack{
                            HStack{
                                Text("Where to meet").font(.system(size: 19)).fontWeight(.medium)
                                Spacer()
                            }
                            Text((listing.locString == "Unknown" ? "Contact User" : listing.locString))
                            MapView(nb_location: CLLocation(latitude: listing.locLat, longitude: listing.locLong) )
                                .frame(height: 150)
                                .blur(radius: (listing.locString == "Unknown" ? 10 : 0))
                                .disabled((listing.locString == "Unknown" ? true : false))
                        }.padding()
                        (listing.email == self.userProfileController.loggedInUserEmail ? nil : VStack{
                            HStack{
                                Text("About Seller").font(.system(size: 19)).fontWeight(.medium)
                                Spacer()
                                NavigationLink(destination: UserPublicProfileView(sellerEmail: listing.email, rootScreen: $rootScreen)){
                                    Text("View Profile").font(.system(size: 19)).fontWeight(.medium)
                                }
                                
                            }
                            
                            HStack(alignment: .center){
                                if (userProfileController.userDict[listing.email]?.uProfileImage != nil) {
                                    Image(uiImage: (userProfileController.userDict[listing.email]?.uProfileImage!)!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .background(Color.gray)
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
                                
                                VStack(alignment: .leading){
                                    Text(userProfileController.userDict[listing.email]!.uName)
                                        .foregroundColor(Color.black)
                                    Text(userProfileController.userDict[listing.email]!.uEmail)
                                        .foregroundColor(Color.black)
                                }
                                Spacer()
                            }
                        }.padding())
                        
                    }
                    .background(Color("HaulerDarkMode"))
                }
                
                .alert("Notify The Seller", isPresented: $showAlert){
                    TextField(text: $inputText){
                        Text("Any Comment?")
                    }
                    Button("Send"){
                        if(chatController.chatDict.keys.contains(where: {
                            $0 == listing.email
                        })){
                            chatController.newChatRoom = false
                        }else{
                            chatController.messageText = inputText + listing.title
                            chatController.newChatRoom = true
                        }
                        viewRouter.currentView = .chat
                        print(viewRouter.currentView)
                        chatController.toId = listing.email
                        chatController.redirect = true
                        dismiss()
                    }
                    Button("Cancel", role: .cancel){}
                }
                .toolbar(){
                    ToolbarItemGroup(placement: .bottomBar){
                        if(listing.email == chatController.loggedInUserEmail){
                            Button(action:{
                                self.openEditSheet = true
                            }){
                                Text("Manage Item")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 20)
                            .padding([.top], 10)
                            .buttonStyle(.borderedProminent)
                        }
                        else if(userProfileController.loggedInUserEmail != ""){
                            
                            //                            Button(action:{}){
                            //                                NavigationLink(destination: BuyPageView()) {
                            //                                    Text("Buy Now")
                            //                                        .font(.system(size: 20))
                            //                                        .foregroundColor(.white)
                            //                                        .frame(maxWidth: .infinity)
                            //                                }
                            //
                            //                            }
                            //                            .padding(.horizontal, 20)
                            //                            .padding([.top], 10)
                            //                            .buttonStyle(.borderedProminent)
                        }
                        else{
                            //                            Button(action:{}){
                            //                                NavigationLink(destination: BuyPageView()) {
                            //                                    Text("Buy Now")
                            //                                        .font(.system(size: 20))
                            //                                        .foregroundColor(.white)
                            //                                        .frame(maxWidth: .infinity)
                            //                                }
                            //
                            //                            }
                            //                            .padding(.horizontal, 20)
                            //                            .padding([.top], 10)
                            //                            .buttonStyle(.borderedProminent)
                            //
                            //                            Spacer()
                            Button(action:{}){
                                NavigationLink(destination: LoginView(rootScreen: $rootScreen)) {
                                    Text("Login to Chat")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                }
                                
                            }
                            .padding(.horizontal, 20)
                            .padding([.top], 10)
                            .buttonStyle(.borderedProminent)
                            .tint(Color(UIColor(named: "HaulerOrange") ?? .blue))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: self.$openEditSheet){
            EditListingView(listing: listing)
        }
        .onDisappear{
            if(chatController.newChatRoom){
                viewRouter.currentView = .chat
            }
        }
    }
    
    func startChat(){
        self.showAlert = true
    }
    
    func gotoLogin(){
        rootScreen = .LOGIN
        self.dismiss()
    }
}

//struct productDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        productDetailView()
//    }
//}
