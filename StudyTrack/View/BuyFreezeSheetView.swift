//
//  BuzyStreetView.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 19/10/25.
//

import SwiftUI

struct BuyFreezeSheet: View {
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var levelSystem: LevelSystem
    @Environment(\.dismiss) var dismiss
    
    @State private var showPurchaseSuccess = false
    @State private var showInsufficientXP = false
    @State private var selectedOption: FreezeOption?
    
    let freezeOptions = [
        FreezeOption(quantity: 1, xpCost: 100, isPopular: false),
        FreezeOption(quantity: 3, xpCost: 250, isPopular: true),
        FreezeOption(quantity: 5, xpCost: 400, isPopular: false)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("❄️")
                            .font(.system(size: 70))
                        
                        Text("Congelamentos de Streak")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("Proteja seu streak quando não puder estudar. Use seu XP para comprar congelamentos!")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("Você tem \(levelSystem.currentXP) XP")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.1))
                    )
                    
                    VStack(spacing: 16) {
                        ForEach(freezeOptions) { option in
                            FreezeOptionCard(
                                option: option,
                                currentXP: levelSystem.currentXP
                            ) {
                                buyFreeze(option)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
        .overlay {
            if showPurchaseSuccess {
                PurchaseSuccessOverlay(quantity: selectedOption?.quantity ?? 1)
            }
        }
        .alert("XP Insuficiente", isPresented: $showInsufficientXP) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Você não tem XP suficiente para esta compra. Continue estudando para ganhar mais XP!")
        }
    }
    
    func buyFreeze(_ option: FreezeOption) {
        guard levelSystem.currentXP >= option.xpCost else {
            showInsufficientXP = true
            return
        }
        
        levelSystem.currentXP -= option.xpCost
        streakManager.buyFreeze(quantity: option.quantity)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        selectedOption = option
        
        withAnimation {
            showPurchaseSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}

struct FreezeOption: Identifiable {
    let id = UUID()
    let quantity: Int
    let xpCost: Int
    let isPopular: Bool
}

struct FreezeOptionCard: View {
    let option: FreezeOption
    let currentXP: Int
    let action: () -> Void
    
    var canAfford: Bool {
        currentXP >= option.xpCost
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                if option.isPopular {
                    Text("MAIS POPULAR")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                }
                
                HStack {
                    Text("❄️")
                        .font(.system(size: 40))
                    
                    Text("×\(option.quantity)")
                        .font(.system(size: 32, weight: .bold))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.yellow)
                            Text("\(option.xpCost)")
                                .font(.system(size: 20, weight: .bold))
                        }
                        
                        Text("XP")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(option.isPopular ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            )
            .opacity(canAfford ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!canAfford)
    }
}

struct PurchaseSuccessOverlay: View {
    let quantity: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                }
                
                VStack(spacing: 8) {
                    Text("Compra Realizada!")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Você ganhou \(quantity) congelamento\(quantity > 1 ? "s" : "")")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal, 40)
        }
        .transition(.opacity)
    }
}

#Preview {
    BuyFreezeSheet()
        .environmentObject(StreakManager())
        .environmentObject(LevelSystem())
}
