//
//  PageController.swift
//  hauler
//
//  Created by Homing Lau on 2023-06-08.
//

import Foundation
import SwiftUI

enum AppView {
    case main, chat, post, list, profile
}

class ViewRouter: ObservableObject {
    // here you can decide which view to show at launch
    @Published var currentView: AppView = .main
    @Published var path = NavigationPath()
}
