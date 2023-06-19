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
    @State var hideParentNavigation : Visibility = .visible
    @State var isLoading : Bool = true
    
    @Binding var rootScreen :RootView
    
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
                                        .foregroundColor(Color(red: 180/255, green: 180/255, blue: 180/255))
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(red: 225/255, green: 225/255, blue: 225/255), lineWidth: 1))
                                        .onTapGesture {
                                            listingController.selectedTokens.append(ListingCategory(rawValue: item)!)
                                        }
                                }
                            }
                        }
                        .padding(.leading,15)
                        
                    }
                    VStack{
                        if(!listingController.filteredList.isEmpty){
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 15), GridItem(.flexible(), spacing: 15)], alignment: .center, spacing: 20){
                                ForEach(listingController.filteredList, id: \.self.id){item in
                                    NavigationLink(destination:
                                                    ProductDetailView(rootScreen: $rootScreen, listing: item)
                                        .environmentObject(viewRouter)
                                    ){
                                        VStack(alignment:.leading){
                                            Image(uiImage: (item.image ?? UIImage(systemName: "exclamationmark.triangle.fill"))!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 135)
                                                .cornerRadius(20, corners: [.topLeft, .topRight])
                                            VStack(alignment:.leading){
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
                                    }
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(color: Color.gray.opacity(0.2), radius: 5, x:2, y:4)
                                    
                                }
                            }
                            .padding(15)
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
                    Label("Search", systemImage: token.icon())
                })
                
            }
        }//NS
        .onAppear{
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
