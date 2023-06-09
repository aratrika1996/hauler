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
    @EnvironmentObject var viewRouter : ViewRouter
    @Environment(\.dismiss) var dismiss
    
    @State var isLoading : Bool = true
    @State var showAlert : Bool = false
    @State var showMore : Bool = false
    @State var path : NavigationPath = NavigationPath()
    @State var inputText : String = "Hi, I am interested in the product with name "
    
    @Binding var rootScreen :RootView
    
    var listing : Listing
    
    var body: some View {
        NavigationView(){
            if(isLoading){
                SplashScreenView()
                    .onAppear{
                        Task{
                            print(#function, "task start")
                            if userProfileController.userDict[listing.email] == nil{
                                print(#function, "email not found, load profile")
                                await userProfileController.getUsersByEmail(email: [listing.email], completion: {success in
                                    if(success){
                                        isLoading = false
                                    }
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
                        Image(uiImage: (listing.image!)).resizable().aspectRatio(contentMode: .fill).cornerRadius(15)
                        HStack{
                            VStack(alignment: .leading){
                                Text("\(listing.title)").bold().fontWeight(.heavy)
                                Text("$\(listing.price.formatted())").foregroundColor(Color("HaulerOrange"))
                            }
                            Spacer()
                            if(listing.email != chatController.loggedInUserEmail){
                                Image(uiImage: UIImage(systemName: "envelope")!)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(15)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 5))
                                    .cornerRadius(5)
                                    .shadow(radius: 5, x: 5,y: 5)
                                    .onTapGesture {
                                        if(userProfileController.loggedInUserEmail.isEmpty){
                                            gotoLogin()
                                        }else{
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
                                
                            }
                            
                            Image(uiImage: UIImage(systemName: "heart.fill")!)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(15)
                                .background(.white, in: RoundedRectangle(cornerRadius: 5))
                                .cornerRadius(5)
                                .shadow(radius: 5, x: 5,y: 5)
                        }
                        .padding()
                        VStack(alignment: .leading){
                            HStack(){
                                Text("Description").bold()
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
                                Text("Where to meet").bold()
                                Spacer()
                            }
                            //Map
                            MapView(location: CLLocation(latitude: 43.6896109, longitude: -79.3889326))
                                .frame(height: 150)
                        }.padding()
                        VStack{
                            HStack{
                                Text("About Seller").bold()
                                Spacer()
                                Button("View Profile"){
                                    viewRouter.currentView = .list
                                    self.dismiss()
                                }
                            }
                            
                            HStack(alignment: .center){
                                Image(uiImage: (userProfileController.userDict[listing.email]?.uProfileImage!)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .padding(15)
                                    .background(Color(.white),in: Circle())
                                    .shadow(radius: 5, x:5, y:5)
                                VStack(alignment: .leading){
                                    Text(userProfileController.userDict[listing.email]!.uName)
                                        .foregroundColor(Color.black)
                                    HStack{
                                        ForEach(0..<4){_ in
                                            Image(uiImage: UIImage(systemName: "star.fill")!)
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }
                                        Image(uiImage: UIImage(systemName: "star")!)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("4")
                                        Text("(8)")
                                    }
                                }
                                Spacer()
                            }
                        }.padding()
                    }
                }
                .alert("Notify The Seller", isPresented: $showAlert){
                    TextField(text: $inputText){
                        Text("Any Comment?")
                    }
                    Button("Send"){
                        if(
                            chatController.chatDict.keys.contains(where: {
                                $0 == listing.email
                            })){
                            viewRouter.currentView = .chat
                            chatController.toId = listing.email
                            chatController.redirect = true
                        }else{
                            chatController.messageText = inputText + listing.title
                            viewRouter.currentView = .chat
                            chatController.toId = listing.email
                            chatController.redirect = true
                        }
                        dismiss()
                    }
                    Button("Cancel", role: .cancel){}
                }
                .toolbar(){
                    ToolbarItemGroup(placement: .bottomBar){
                        
                        Button(action: {
                            
                        }){
                            Text("Buy Now")
                        }
                        .padding()
                        .background(Color(.black), in: RoundedRectangle(cornerRadius: 8))
                        .padding()
                        if(userProfileController.loggedInUserEmail.isEmpty){
                            Spacer()
                            Button(action: {
                                authController.user != nil ? startChat() : gotoLogin()
                            }){
                                Text(authController.user != nil ? "Chat with seller" : "Log in to chat with seller")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color("HaulerOrange"), in: RoundedRectangle(cornerRadius: 8))
                            .padding()
                        }
                    }
                    
                }
            }
        }
    }
    
    func startChat(){
        
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
