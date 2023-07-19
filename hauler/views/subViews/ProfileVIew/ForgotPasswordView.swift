//
//  ForgotPasswordView.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-06-30.
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authController : AuthController
    @State private var email : String = ""
    @State private var isSheetPresent = false
    @Binding var rootScreen :RootView
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Enter Email", text: self.$email)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
                
                Button(action: {
                    resetPassword()
                }){
                    Text("Send email")
                        .foregroundColor(Color.red)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .sheet(isPresented: self.$isSheetPresent, onDismiss: goToLogin) {
            VStack {
                Image(systemName: "envelope.badge")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70)
                    .padding(.bottom, 30)
                
                Text("Almost there!")
                    .padding(.bottom, 10)
                    .font(.system(size: 30))
                    .fontWeight(.medium)
                    .foregroundColor(Color("HaulerOrange"))
                
                Text("We have sent a temporary link to your email with further instructions. This link will expire soon.")
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationBarTitle("Reset Password")
    }
    
    func resetPassword() {
        self.authController.sendPasswordReset(withEmail: self.email) {_ in
            self.isSheetPresent = true
        }
    }
    
    func goToLogin(){
        self.dismiss()
    }
}

//struct ForgotPasswordView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForgotPasswordView()
//    }
//}
