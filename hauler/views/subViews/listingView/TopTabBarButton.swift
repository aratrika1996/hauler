//
//  TopTabBarButton.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-06-02.
//

import SwiftUI

struct TopTabBarButton: View {
    let text: String
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(text)
                .fontWeight(isSelected ? .heavy : .regular)
                .font(.custom("Avenir", size: 16))
                .padding(.bottom,10)
                .frame(minWidth: 200, alignment: .center)
                .border(width: isSelected ? 3 : 1, edges: [.bottom], color: Color(UIColor(named: "HaulerOrange") ?? .black))
            Spacer()
        }
        
    }
}

struct EdgeBorder: Shape {

    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: SwiftUI.Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

//struct TopTabBarButton_Previews: PreviewProvider {
//    static var previews: some View {
//        TopTabBarButton()
//    }
//}
