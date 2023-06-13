//
//  SplashScreenView.swift
//  hauler
//
//  Created by Homing Lau on 2023-06-02.
//

import SwiftUI
import QuartzCore

extension Animation {
    static func ripple() -> Animation {
        Animation.spring(response: 2, dampingFraction: 0).speed(2)
    }
}

struct SplashScreenView: View {
    @State private var animationCompleted = false
    @State private var animationOn = true

    var body: some View {
        ZStack {
            Color("HaulerOrange")
                .edgesIgnoringSafeArea(.all)

            if animationCompleted {
                Text("Hauler")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            } else {
                VStack {
                    Image(uiImage: UIImage(named: "HaulerLogo")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .border(.black, width: 5)
                        .animation(.ripple().repeatForever(), value: animationOn)
                        .offset(animationOn ? CGSize(width: 0, height: 0) :CGSize(width: 0, height: 10))
                        .onAppear {
                            withAnimation{
                                animationOn.toggle()
                            }
                        }
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}

