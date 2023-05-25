//
//  ManageAccountView.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-05-24.
//

import SwiftUI

struct ManageAccountView: View {
    var body: some View {
        List {
            Section {
                Text("Change Password")
            }
            
            Section {
                Text("Delete Account")
            }
        }
    }
}

struct ManageAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ManageAccountView()
    }
}
