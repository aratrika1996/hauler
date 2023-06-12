//
//  ChatImageLogo.swift
//  hauler
//
//  Created by Homing Lau on 2023-06-11.
//

import SwiftUI

struct ChatImageLogo: View {
    var body: some View {
        VStack{
            ZStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .opacity(1)
                        .frame(width: 100, height: 100)
                        .overlay{
                            Image(systemName: "text.bubble.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100)
                                .padding(8)
                        }
                        .rotation3DEffect(.degrees(180), axis: (x:0, y:1, z:0))
                    
                }
                .padding([.leading, .bottom],40)
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .opacity(1)
                        .frame(width: 100, height: 100)
                        .overlay{
                            Image(systemName: "text.bubble.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100)
                                .padding(8)
                        }
                }
                .padding([.trailing, .top
                         ],40)
            }
        }
    }
}

struct ChatImageLogo_Previews: PreviewProvider {
    static var previews: some View {
        ChatImageLogo()
    }
}
