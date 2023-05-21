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
    let authController : AuthController
    
    init() {
        FirebaseApp.configure()
        authController = AuthController()
    }
    var body: some Scene {
        WindowGroup {
//            ContentView()
            ContentView().environmentObject(authController)
        }
    }
}
