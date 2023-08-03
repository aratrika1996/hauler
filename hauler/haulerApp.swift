//
//  haulerApp.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

@main
struct haulerApp: App {
    
    @State var isActive: Bool = false
    init(){
        FirebaseApp.configure()
    }
        
    var body: some Scene {
        WindowGroup {
            VStack {
                if self.isActive {
                    MainView()
                } else {
                    SplashScreenView()
                }
            }//VStack ends
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
            
//            SplashScreenView()
        }
    }
}
