//
//  AchievementsView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 12/10/25.
//

import SwiftUI

struct AchievementsView: View {
    var allAchievements: [String]

    let columns = [
        GridItem(.adaptive(minimum: 140), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Todas as Conquistas")
                    .font(.largeTitle.bold())
                    .padding(.top)

                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(allAchievements, id: \.self) { badge in
                        AchievementCard(title: badge)
                            .frame(height: 140)
                            .onTapGesture {
                                shareAchievementAsStory(badge)
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func shareAchievementAsStory(_ achievement: String) {
        let storyView = AchievementStoryView(title: achievement)
            .frame(width: 1080, height: 1920)
        
        let image = storyView.asImage()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            rootVC.present(activityVC, animated: true)
        }
    }
}


struct AchievementStoryView: View {
    var title: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.cyan.opacity(0.8), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 60) {
                Spacer()

                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .foregroundColor(.yellow)
                    .shadow(color: .white.opacity(0.6), radius: 20, x: 0, y: 0)

                Text(title)
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)
                    .shadow(radius: 10)

                Spacer()

                HStack(spacing: 12) {
                    Image(systemName: "graduationcap.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                    Text("StudyTrack")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

extension View {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

#Preview {
    NavigationView {
        AchievementsView(allAchievements: [
            "🔥 3 dias seguidos",
            "🏆 Meta semanal alcançada",
            "📚 Revisou 10 capítulos",
            "⏱️ Estudo de 5h seguidas",
            "🎯 Meta do mês atingida"
        ])
    }
}
