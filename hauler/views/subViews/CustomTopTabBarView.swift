//
//  CustomTopTabBarView.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-06-02.
//

import SwiftUI

struct CustomTopTabBarView: View {
    @Binding var tabIndex: Int
    var body: some View {
        HStack() {
            TopTabBarButton(text: "Available", isSelected: .constant(tabIndex == 0))
                .onTapGesture { onButtonTapped(index: 0) }
            Spacer()
            TopTabBarButton(text: "Sold", isSelected: .constant(tabIndex == 1))
                .onTapGesture { onButtonTapped(index: 1) }
            
        }
        .border(width: 1, edges: [.bottom], color: .gray)
        .padding(.top, 20)
    }
    
    private func onButtonTapped(index: Int) {
        withAnimation { tabIndex = index }
    }
}

//struct CustomTopTabBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomTopTabBarView()
//    }
//}
