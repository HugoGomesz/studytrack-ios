//
//  ProfileManager.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 05/11/25.
//

import SwiftUI
import UIKit

class ProfileManager: ObservableObject {
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
    }
    
    @Published var profileImage: UIImage? {
        didSet {
            saveProfileImage()
        }
    }
    
    private let userNameKey = "userName"
    private let profileImageKey = "profileImage"
    
    init() {
        // Carrega nome
        self.userName = UserDefaults.standard.string(forKey: userNameKey) ?? "Estudante"
        
        // Carrega foto
        if let imageData = UserDefaults.standard.data(forKey: profileImageKey),
           let image = UIImage(data: imageData) {
            self.profileImage = image
        }
    }
    
    func updateName(_ newName: String) {
        userName = newName.isEmpty ? "Estudante" : newName
    }
    
    func updateProfileImage(_ image: UIImage?) {
        profileImage = image
    }
    
    private func saveProfileImage() {
        if let image = profileImage,
           let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: profileImageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: profileImageKey)
        }
    }
    
    func resetProfile() {
        userName = "Estudante"
        profileImage = nil
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.removeObject(forKey: profileImageKey)
    }
    
    var initials: String {
        let components = userName.components(separatedBy: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}
