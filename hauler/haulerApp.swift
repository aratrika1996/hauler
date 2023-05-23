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
    
    init(){
        FirebaseApp.configure()
    }
        
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        
    }
}
