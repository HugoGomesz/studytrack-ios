//
//  SplashView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            HomeView()
        } else {
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                    
                    Image("SplashScreen2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                        .clipped()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    isActive = true
                                }
                            }
                        }
                }
            }
            .ignoresSafeArea()
        }
    }
}


#Preview {
    SplashView()
}
