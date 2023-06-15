//
//  SoldListingsView.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-06-02.
//

import SwiftUI

struct SoldListingsView: View {
    @EnvironmentObject var listingController : ListingController
    
    @State private var isSheetPresent = false
    @State private var showAlert = false
    @State private var listingToDelete = Listing()
    @State private var selectedListing = Listing()
    
    var body: some View {
        VStack {
            if(!listingController.userSoldListings.isEmpty){
                List{
                    ForEach(Array(listingController.userSoldListings.enumerated()), id:\.element){idx, item in
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(uiImage: (item.image ?? UIImage(systemName: "exclamationmark.triangle.fill"))!).resizable().frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                    
                                    VStack (alignment: .leading) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(item.title)
                                                    .font(.system(size: 21))
                                                    .fontWeight(.medium)
                                                
                                                Text("$" + String(item.price))
                                                    .font(.system(size: 18))
                                                    .foregroundColor(Color(UIColor(named: "HaulerOrange") ?? .blue))
                                                    .fontWeight(.medium)
                                            }
                                            Spacer()
                                            Text("now")
                                                .font(.system(size: 14))
                                        }
                                        .padding(.bottom, 0.1)
                                        HStack {
                                            Text("Posted in " + item.category.rawValue)
                                                .font(.system(size: 14))
                                            Spacer()
                                            Image(systemName: "ellipsis")
                                                .onTapGesture(perform: {
                                                    self.isSheetPresent = true
                                                })
                                        }
                                    }
                                    
                                }
                                
                                Button(action: {
                                    listingController.changeItemAvailabilityStatus(listingToUpdate: item) {_ in
                                        print("Marked as available")
                                    }
                                    print("clicked")
                                }) {
                                    Text("Mark as available")
                                        .frame(maxWidth: .infinity)
                                        
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.accentColor)
                                
                            }
                            .listRowInsets(.init())
                            .padding(10)
                            .sheet(isPresented: self.$isSheetPresent) {
                                VStack(alignment: .leading) {
                                    Button(action: {
                                        self.isSheetPresent = false
                                        self.selectedListing = item
                                    }) {
                                        Image(systemName: "xmark")
                                    }
                                    .foregroundColor(Color.black)
                                    .padding(.bottom, 20)

                                    Button(action: {
                                        listingController.changeItemAvailabilityStatus(listingToUpdate: self.selectedListing) {_ in
                                            self.isSheetPresent = false
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "tag.fill")
                                            Text("Mark as available")
                                        }
                                    }
                                    .foregroundColor(Color.black)
                                    .padding(.bottom, 20)

                                    Button(action: {
                                        self.listingToDelete = item
                                        self.showAlert = true
                                    }) {
                                        HStack {
                                            Image(systemName: "trash.fill")
                                            Text("Delete listing")
                                        }
                                    }
                                    .foregroundColor(Color.black)
                                    .padding(.bottom, 20)
                                    .alert(isPresented: self.$showAlert){
                                        Alert(title: Text("Delete Listing"),
                                              message: Text("Confirm?"),
                                              primaryButton: .default(
                                                  Text("No")
                                              ),
                                              secondaryButton: .destructive(
                                                  Text("Yes"),
                                                  action: deleteListing
                                              )
                                        )
                                        
                                    }
                                    .presentationDetents([.height(200)])
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .onDisappear(){
                    listingController.removeUserListener()
                }
            }
            else{
                VStack {
                    Text("Sold listings")
                        .font(.system(size: 22))
                        .padding(.bottom, 5)
                    Text("Keep track of all your sold listings in one place.")
                        .font(.system(size: 15))
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            
        }
        .onAppear {
            listingController.getAllUserSoldListings(completion: {_, err in
                if let err = err{
                    print(#function, err)
                }else{
                    print(#function, "good to go, counts = \(listingController.userSoldListings)")
                }
                //isLoading = false
            })
        }
        
    }
    
    func deleteListing() {
        self.listingController.deleteListing(listingToDelete: self.listingToDelete)
    }
        
}

struct SoldListingsView_Previews: PreviewProvider {
    static var previews: some View {
        SoldListingsView()
    }
}
