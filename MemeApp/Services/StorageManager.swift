//
//  StorageManager.swift
//  MemeApp
//
//  Created by Paul Matar on 14.04.2022.
//

import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "settings"
    
    private init() {}
    
    func save(count: String, subreddit: String) {
        let settings = ["count": count, "subreddit": subreddit]
        userDefaults.set(settings, forKey: settingsKey)        
    }
    
    func fetchSettings() -> [String: String] {
        if let savedSettings = userDefaults.value(forKey: settingsKey) as? [String: String] {
            return savedSettings
        }
        return [:]
    }
    
}
