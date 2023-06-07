//
//  productDetailView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct productDetailView: View {
    @EnvironmentObject var chatController : ChatController
    @EnvironmentObject var userProfileController : UserProfileController
    @Environment(\.dismiss) var dismiss
    @State var isLoading : Bool = true
    @State var showAlert : Bool = false
    @State var inputText : String = "Hi, I am interested in the product with name "
    var listing : Listing
    var toChat : (String?) -> Void
    var body: some View {
        if(isLoading){
            ProgressView().onAppear(){
                if userProfileController.userDict[listing.email] == nil{
                    print(#function, "email not found, load profile")
                    userProfileController.getUserByEmail(email: listing.email, completion: {up, _ in
                        print(#function, "profile loaded: \(up)")
                        isLoading = false
                    })
                }else{
                    print(#function, "email found, ok")
                    isLoading = false
                }
            }
        }else{
            ScrollView(.vertical){
                Image(uiImage: (listing.image!)).resizable().aspectRatio(contentMode: .fill).cornerRadius(15)
                HStack{
                    VStack{
                        Text("\(listing.title)")
                        Text("\(listing.price)")
                    }
                    Spacer()
                    if(listing.email != chatController.loggedInUserEmail){
                        Image(uiImage: UIImage(systemName: "envelope")!)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(15)
                            .background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Circle())
                            .onTapGesture {
                                if(
                                    chatController.chatDict.keys.contains(where: {
                                        $0 == listing.email
                                    })){
                                    toChat(listing.email)
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
                        .background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Circle())
                }.padding()
                VStack{
                    HStack{
                        Text("Description").bold()
                        Spacer()
                    }
                    Text("\(listing.desc)")
                }.padding()
                VStack{
                    HStack{
                        Text("Where to meet").bold()
                        Spacer()
                    }
                    //Map
                    Rectangle().background(Color(.blue))
                }.padding()
                VStack{
                    HStack{
                        Text("About Seller").bold()
                        Spacer()
                        Button("View Profile"){
                            
                        }
                    }
                    
                    HStack{
                        Image(uiImage: (userProfileController.userDict[listing.email]?.uProfileImage!)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .cornerRadius(100)
                        VStack{
                            Text(userProfileController.userDict[listing.email]!.uName)
                                .foregroundColor(Color.black)
                            HStack{
                                ForEach(0..<4){_ in
                                    Image(uiImage: UIImage(systemName: "star.fill")!)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                }
                            }
                        }
                    }
                }.padding()
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
                        toChat(listing.email)
                    }else{
                        chatController.messageText = inputText + listing.title
                        toChat(listing.email)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel){}
            }
        }
        
    }
}

//struct productDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        productDetailView()
//    }
//}
