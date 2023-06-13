//
//  productDetailView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct productDetailView: View {
    var listing : Listing
    var body: some View {
        VStack{
            Image(uiImage: (listing.image!)).resizable().aspectRatio(contentMode: .fill).cornerRadius(15)
            HStack{
                VStack{
                    Text("\(listing.title)")
                    Text("\(listing.title)")
                }
                Spacer()
                Image(uiImage: UIImage(systemName: "heart.fill")!)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(15)
                    .background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Circle())
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
                    NavigationLink(destination: UserPublicProfileView(sellerEmail: listing.email)) {
                        Text("View Profile")
                    }
//                    Button(action: {
//                        
//                    }){
//                        
//                    }
                }
                HStack{
                    Image(uiImage: UIImage(systemName: "person.fill")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .cornerRadius(100)
                    VStack{
                        Text(listing.email)
                            .foregroundColor(Color.white)
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
        
        
    }
}

//struct productDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        productDetailView()
//    }
//}
