//
//  HomeView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var listingController : ListingController
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    @State var listOfNames : [String] = ["Apple", "Banana", "Carrot", "application", "Car", "applied mathmatics", "apppppp"]
    @State var catagories : [String] = ListingCategory.allCases.map{(i) -> String in return i.displayName}
    @State var searchInput : String = ""
    @State var searchEditing : Bool = false
    @State var dummyListing : [Listing] = [Listing(id:"1",title: "1", desc: "desc", price: 100.99, email: "", imageURI: "", category: .other),Listing(id:"2",title: "2", desc: "desc", price: 999.99, email: "", imageURI: "", category: .other)]
    @State var filterListing : [Listing] = []
    private var filteredSuggestionText: Binding<[String]> {Binding(
        get: {
            return dummyListing.map{(item) -> String in
                return item.title
            }.filter{
                $0.lowercased().contains(searchInput.lowercased())
                //                && ($0.lowercased().prefix(1) == searchInput.lowercased().prefix(1))
            }
        }, set: {_ in}
    )}
    @State var select1 : Bool = true
    
    var body: some View {
        VStack{
            VStack{
                if(!filterListing.isEmpty){
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20){
                        ForEach(filterListing, id: \.self.id){item in
                            VStack{
                                Image(uiImage: (item.image ?? UIImage(systemName: "exclamationmark.triangle.fill"))!).resizable().frame(width: 100, height: 100)
                                Text(item.title).padding()
                                Text(String(item.price)).foregroundColor(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756))
                            }.padding().background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Rectangle()).cornerRadius(15)
                        }
                    }
                }else{
                    Text("Nothing To Show")
                    Button("Go back"){
                        filterListing = dummyListing
                    }
                }
                
                
                Spacer()
                ScrollView(.horizontal){
                    LazyHStack(alignment: .firstTextBaseline){
                        ForEach(catagories, id: \.self){item in
                            Text(item).padding().background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Rectangle()).cornerRadius(15)
                        }
                        
                    }
                }
            }
        }
        .searchable(text: $listingController.searchText,
                    tokens: $listingController.selectedTokens,
                    suggestedTokens: $listingController.suggestedTokens,
                    token: { token in
            Label(token.rawValue, systemImage: token.icon())
            
        })
        .onSubmit (of: .search){
            filterListing = dummyListing.filter{
                $0.title.contains(searchInput) || listingController.selectedTokens.contains($0.category)
            }
            print("Onsubmit")
        }
        .toolbar(content: {
            ToolbarItem(content: {
                HStack{
                    Text("Discover")
                    Spacer()
                    Image(uiImage: UIImage(systemName: "heart.fill")!)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(15)
                        .background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Circle())
                    Image(uiImage: UIImage(systemName: "bell")!)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(15)
                        .background(Color(red: 0.702, green: 0.87, blue: 0.756, opacity: 0.756), in: Circle())
                }
                .padding(.horizontal, 10)
            })
            
        })
        .onChange(of: isSearching, perform: {isSearching in
            if(!isSearching){
                filterListing = dummyListing
            }
        })
        .onAppear(){
            listingController.getAllListings(completion: {list, err in
                if let err = err{
                    print(err)
                }
                if let list = list{
                    self.dummyListing = list
                    self.filterListing = dummyListing
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
