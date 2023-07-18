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
    @State private var phone : String = ""
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
                    TextField("Enter Number", text: self.$phone)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.numberPad)
                }
                
                Button(action: {
                    self.isUserInputValid = self.validateData()
                    self.showAlert = true
                }){
                    Text("Update Info")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .alert(isPresented: self.$showAlert){
                    if isUserInputValid {
                        
                            return Alert(title: Text("Update Information"),
                                         message: Text("Confirm?"),
                                         primaryButton: .default(
                                            Text("No")
                                         ),
                                         secondaryButton: .destructive(
                                            Text("Yes"),
                                            action: updateInfo
                                         )
                            )
                        
                    }
                    else {
                        return Alert(title: Text("Result"),
                              message: Text("\(errorMessage)"),
                              dismissButton: .default(Text("OK!")))
                    }
                }
            }
            .navigationTitle("Personal Details")
            
        }
        .onAppear {
            self.name = self.userProfileController.userProfile.uName
            self.address = self.userProfileController.userProfile.uAddress
            self.phone = self.userProfileController.userProfile.uPhone
        }
    }
    
    func validateData() -> Bool {
        
        if self.name.isEmpty && self.address.isEmpty && self.phone.isEmpty {
            errorMessage = "You can not update empty fields"
            return false
        }
        
        if Int(self.name) != nil {
            errorMessage = "Name should not contain only number"
            return false
        }
        
        if Int(self.address) != nil {
            errorMessage = "Address should not contain only number"
            return false
        }
        
        let phoneRegex = #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if !phoneTest.evaluate(with: self.phone) {
            errorMessage = "Invalid phone number"
            return false
        }
        return true
        
    }
    
    func updateInfo() {
        self.userProfileController.userProfile.uName = self.name
        self.userProfileController.userProfile.uPhone = self.phone
        self.userProfileController.userProfile.uAddress = self.address
        
        self.userProfileController.updateUserData(userProfileToUpdate: self.userProfileController.userProfile) { result in
            print(result ?? "Result")
        }
        dismiss()
    }
}

struct PersonalDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalDetailsView()
    }
}
