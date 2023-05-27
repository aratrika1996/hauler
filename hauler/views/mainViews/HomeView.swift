//
//  HomeView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var listingController : ListingController
    //    @Environment(\.isSearching) var isSearching
    //    @Environment(\.dismissSearch) var dismissSearch
    @State var catagories : [String] = ListingCategory.allCases.map{(i) -> String in return i.displayName}
    @State var selectedApproveList : [Listing] = []
    @State var selection : Listing?
    @State var alert : Alert? = nil
    @State var activeLink : Bool = false
    @State var hideParentNavigation : Visibility = .visible
    @State var gridFormmats : [[GridItem]] = [Array(repeating: GridItem(.flexible(), spacing: 20), count: 2) ,[GridItem(.fixed(30)), GridItem(.fixed(150)), GridItem(.fixed(30)), GridItem(.fixed(150))]]
    
    var body: some View {
            ScrollView(.vertical){
                HStack{
                    if(listingController.adminMode){
                        Button("Approve"){
                            print(#function, "approve clicked")
                            if(!selectedApproveList.isEmpty){
                                print(#function, "entered")
                                listingController.approveListings(listingsToUpdate: selectedApproveList, completion: {err in
                                    if let _ = err{
                                        alert = Alert(title: Text("Failed to approve"))
                                    }else{
                                        alert = Alert(title: Text("Approved"))
                                    }
                                })
                                selectedApproveList.removeAll()
                            }
                        }.background(Color(red: 0.8, green: 0.8, blue: 0.8)).padding()
                    }
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
                        LazyVGrid(columns: listingController.adminMode ? gridFormmats[1] : gridFormmats[0] , alignment: .center, spacing: 50){
                            ForEach(listingController.filteredList, id: \.self.id){item in
                                if(listingController.adminMode){
                                    if(!selectedApproveList.contains(where: {$0.id == item.id})){
                                        Image(systemName: "square")
                                            .onTapGesture(perform: {
                                                selectedApproveList.append(item)
                                            })
                                    }else{
                                        Image(systemName: "checkmark.square")
                                            .onTapGesture(perform:{
                                                selectedApproveList = selectedApproveList.filter{
                                                    return $0.id != item.id
                                                }
                                            })
                                    }
                                }
                                NavigationLink(destination: productDetailView(listing: item)
                                    .onAppear(){hideParentNavigation = .hidden}
                                    .onDisappear(){hideParentNavigation = .visible}
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
                                .padding(5)
                                .shadow(radius: 15, x:15, y:15)
                                
                            }
                        }
                        Spacer(minLength: 0)
                    }else{
                        Text("Nothing To Show")
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
        .toolbar(hideParentNavigation, for: .navigationBar)
        .toolbar(hideParentNavigation, for: .tabBar)
        .onAppear(){
            listingController.getAllListings(adminMode: listingController.adminMode,completion: {_, err in
                if let err = err{
                    print(err)
                }
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
