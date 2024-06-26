//
//  AvailableListingsView.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-06-02.
//

import SwiftUI

struct AvailableListingsView: View {
    @EnvironmentObject var listingController : ListingController
    
    @State private var isSheetPresent = false
    @State private var showAlert = false
    @State private var listingToDelete = Listing()
    @State private var selectedListing = Listing()
    @State private var openEditSheet = false
    @Binding var rootScreen :RootView
    
    var body: some View {
        NavigationView {
            VStack {
                if(!listingController.userAvailableListings.isEmpty){
                    List{
                        ForEach(Array(listingController.userAvailableListings.enumerated()), id:\.element){idx, item in
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
                                            //                                        Text("now")
                                            //                                            .font(.system(size: 14))
                                            Image(systemName: "ellipsis")
                                                .onTapGesture(perform: {
                                                    self.isSheetPresent = true
                                                    self.selectedListing = item
                                                })
                                        }
                                        .padding(.bottom, 0.1)
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Location")
                                                    .font(.system(size: 14))
                                                    .padding(.bottom, 0.1)
                                                Text("Posted in " + item.category.rawValue)
                                                    .font(.system(size: 14))
                                            }
                                            //Spacer()
                                            //                                        Image(systemName: "ellipsis")
                                            //                                            .onTapGesture(perform: {
                                            //                                                self.isSheetPresent = true
                                            //                                                self.selectedListing = item
                                            //                                            })
                                        }
                                    }
                                    
                                }
                                
                                Button(action: {
                                    listingController.changeItemAvailabilityStatus(listingToUpdate: item) {_ in
                                        print("Marked as sold")
                                    }
                                    //                                    print(item.title)
                                }) {
                                    Text("Mark as sold")
                                        .frame(maxWidth: .infinity)
                                }
                                //.padding([.top], 30)
                                .buttonStyle(.borderedProminent)
                                
                                .tint(Color(UIColor(named: "HaulerOrange") ?? .blue))
                            }
                            .listRowInsets(.init())
                            .padding(10)
                            .sheet(isPresented: self.$isSheetPresent) {
                                VStack(alignment: .leading) {
                                    Button(action: {
                                        self.isSheetPresent = false
                                        self.openEditSheet = false
                                    }) {
                                        Image(systemName: "xmark")
                                    }
                                    .foregroundColor(Color.black)
                                    .padding(.bottom, 20)
                                    
                                    //                                    Button(action: {
                                    //
                                    //                                    }) {
                                    //                                        HStack {
                                    //                                            Image(systemName: "square.and.arrow.up")
                                    //                                            Text("Share listing")
                                    //                                        }
                                    //                                    }
                                    //                                    .foregroundColor(Color.black)
                                    //                                    .padding(.bottom, 20)
                                    
                                    Button(action: {
                                        // Open the sheet view
                                        self.isSheetPresent = false
                                        self.openEditSheet = true
                                    }) {
                                        HStack {
                                            Image(systemName: "pencil")
                                            Text("Edit listing")
                                        }
                                    }
                                    .foregroundColor(Color.black)
                                    .padding(.bottom, 20)
                                    
                                    Button(action: {
                                        listingController.changeItemAvailabilityStatus(listingToUpdate: self.selectedListing) {_ in
                                            self.isSheetPresent = false
                                        }
                                        //                                        print(self.selectedListing.title)
                                    }) {
                                        HStack {
                                            Image(systemName: "tag.fill")
                                            Text("Mark as sold")
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
                            .sheet(isPresented: self.$openEditSheet){
                                EditListingView(listing: item).environmentObject(listingController)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .onDisappear(){
                        listingController.removeUserListener()
                    }
                }else{
                    VStack {
                        Text("Your listings will live here!")
                            .font(.system(size: 22))
                        
                            Button(action: {
                            }){
                                NavigationLink(destination: PostView(rootScreen: $rootScreen)) {
                                    Text("List now")
                                        .font(.system(size: 18))
                                        .frame(maxWidth: 250)
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(UIColor(named: "HaulerOrange") ?? .blue))
                    
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                }
                
            }
            //        .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                listingController.getAllUserAvailableListings(completion: {_, err in
                    if let err = err{
                        print(#function, err)
                    }else{
                        print(#function, "good to go, counts = \(listingController.userAvailableListings)")
                    }
                    //isLoading = false
                })
            }
        }
        
    }
    
    func deleteListing() {
        self.listingController.deleteListing(listingToDelete: self.listingToDelete)
    }
    
}

//struct AvailableListingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AvailableListingsView()
//    }
//}
