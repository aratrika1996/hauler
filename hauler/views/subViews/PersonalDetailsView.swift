//
//  PersonalDetailsView.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-05-23.
//

import SwiftUI

struct PersonalDetailsView: View {
    @State private var name : String = ""
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var address : String = ""
    @State private var contact : String = ""
    @State private var showAlert : Bool = false
    @State private var isUserInputValid : Bool = false
    @State private var errorMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("User Name")) {
                    TextField("Enter Name", text: self.$name)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Address")) {
                    TextField("Enter Address", text: self.$address)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Phone Number")) {
                    TextField("Enter Number", text: self.$contact)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.numberPad)
                }
                
                Button(action: {
                    //self.isUserInputValid = self.validateData()
                    self.showAlert = true
                }){
                    Text("Update Info")
                }
                .frame(maxWidth: .infinity, alignment: .center)
//                .alert(isPresented: self.$showAlert){
//                    if isUserInputValid {
//                        
//                            return Alert(title: Text("Update Information"),
//                                         message: Text("Confirm?"),
//                                         primaryButton: .default(
//                                            Text("No")
//                                         ),
//                                         secondaryButton: .destructive(
//                                            Text("Yes"),
//                                            action: updateInfo
//                                         )
//                            )
//                        
//                    }
//                    else {
//                        return Alert(title: Text("Result"),
//                              message: Text("\(errorMessage)"),
//                              dismissButton: .default(Text("OK!")))
//                    }
//                }
            }
            .navigationTitle("Edit User")
            
        }
    }
}

struct PersonalDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalDetailsView()
    }
}
