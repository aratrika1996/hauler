//
//  productDetailView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct productDetailView: View {
    @EnvironmentObject var chatController : ChatController
    @Environment(\.dismiss) var dismiss
    @State var showAlert : Bool = false
    @State var inputText : String = "Hi, I am interested in the product with name "
    var listing : Listing
    var toChat : (String?) -> Void
    var body: some View {
        ScrollView(.vertical){
            Image(uiImage: (listing.image!)).resizable().aspectRatio(contentMode: .fill).cornerRadius(15)
            HStack{
                VStack{
                    Text("\(listing.title)")
                    Text("\(listing.price)")
                }
                Spacer()
                Image(uiImage: UIImage(systemName: "envelope")!)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(15)
                    .background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Circle())
                    .onTapGesture {
                        showAlert = true
                        
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
                    Image(uiImage: UIImage(systemName: "person.fill")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .cornerRadius(100)
                    VStack{
                        Text((listing.email != "") ? listing.email : "Empty Name")
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
                    chatController.chats.contains(where: {
                        $0.messages[0].fromId == listing.email || $0.messages[0].toId == listing.email
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

//struct productDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        productDetailView()
//    }
//}
