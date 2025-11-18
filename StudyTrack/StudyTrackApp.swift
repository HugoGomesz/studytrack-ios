//
//  StudyTrackApp.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import SwiftUI

@main
struct StudyTrackApp: App {
    
    @State private var showSplash = true
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear       
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
            WindowGroup {
                ZStack {
                    if !showSplash {
                        RootView()
                    } else {
                        SplashView()
                            .transition(.opacity)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                }
            }
        }
    }
