//
//  HomeView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject private var viewRouter: ViewRouter
    @Environment(\.dismiss) var dismiss
    @State var catagories : [String] = ListingCategory.allCases.map{(i) -> String in return i.displayName}
    @State var selection : Listing?
    @State var alert : Alert? = nil
    @State var activeLink : Bool = false
//    @State var path : NavigationPath = NavigationPath()
    @State var hideParentNavigation : Visibility = .visible
    @State var isLoading : Bool = true
    
    @State var gridFormmats : [[GridItem]] = [Array(repeating: GridItem(.flexible(), spacing: 20), count: 2) ,[GridItem(.fixed(30)), GridItem(.fixed(150)), GridItem(.fixed(30)), GridItem(.fixed(150))]]
    
    var body: some View {
        NavigationView{
            if(isLoading){
                SplashScreenView()
            }else{
                ScrollView(.vertical){
                    HStack{
                        ScrollView(.horizontal){
                            HStack{
                                ForEach(catagories, id: \.self){item in
                                    Text(item)
                                        .foregroundColor(Color.white)
                                        .padding().background(Color("HaulerOrange"), in: Rectangle()).cornerRadius(15)
                                        .onTapGesture {
                                            listingController.selectedTokens.append(ListingCategory(rawValue: item)!)
                                        }
                                }
                            }
                        }.padding(.horizontal,10)
                        
                    }
                    VStack{
                        if(!listingController.filteredList.isEmpty){
                            LazyVGrid(columns: gridFormmats[0] , alignment: .center, spacing: 50){
                                ForEach(listingController.filteredList, id: \.self.id){item in
                                    NavigationLink(destination:
                                        ProductDetailView(listing: item)
                                        .environmentObject(viewRouter)
                                    ){
                                        VStack{
                                            Image(uiImage: (item.image ?? UIImage(systemName: "exclamationmark.triangle.fill"))!)
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(8)
                                            HStack{
                                                VStack(alignment:.leading){
                                                    Text(item.title)
                                                    Text("$" + String(item.price)).foregroundColor(Color(red: 0.302, green: 0.47, blue: 0.256, opacity: 0.756))
                                                }
                                                Spacer()
                                            }
                                            .padding()
                                        }
                                    }
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .padding(.horizontal, 10)
                                    .shadow(radius: 15, x:15, y:15)
                                    
                                }
                            }
                            Spacer(minLength: 0)
                        }else{
                            Text("Item No Found")
                            Button("Go back"){
                                listingController.searchText = ""
                                listingController.selectedTokens = []
                            }
                        }
                        Spacer()
                    }
                }
                .searchable(text: $listingController.searchText,
                            tokens: $listingController.selectedTokens,
                            suggestedTokens: $listingController.suggestedTokens,
                            token: { token in
                    Label(token.rawValue, systemImage: token.icon())
                    
                })
            }
        }//NS
        .onAppear(){
            if(listingController.listingsList.isEmpty){
                listingController.getAllListings(adminMode: listingController.adminMode,completion: {_, err in
                    if let err = err{
                        print(err)
                    }
                    isLoading = false
                })
            }else{
                isLoading = false
            }
            
        }
    }
}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
