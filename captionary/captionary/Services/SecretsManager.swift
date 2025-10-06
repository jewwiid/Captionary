//
//  SecretsManager.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Manager for reading API keys and secrets from Secrets.plist
//

import Foundation

/// Manager for reading API keys and secrets from Secrets.plist
class SecretsManager {
    static let shared = SecretsManager()
    
    private let secrets: [String: Any]
    
    private init() {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) else {
            fatalError("Secrets.plist not found in app bundle. Please add it to your Xcode project.")
        }
        
        self.secrets = plist as? [String: Any] ?? [:]
    }
    
    // MARK: - Supabase Configuration
    
    var supabaseURL: URL? {
        guard let urlString = secrets["SupabaseURL"] as? String,
              urlString != "YOUR_SUPABASE_URL_HERE" else {
            return nil
        }
        return URL(string: urlString)
    }
    
    var supabaseAnonKey: String? {
        guard let key = secrets["SupabaseAnonKey"] as? String,
              key != "YOUR_SUPABASE_ANON_KEY_HERE" else {
            return nil
        }
        return key
    }
    
    // MARK: - AI Provider Keys
    
    var openAIAPIKey: String? {
        guard let key = secrets["OpenAIAPIKey"] as? String,
              key != "YOUR_OPENAI_API_KEY_HERE" else {
            return nil
        }
        return key
    }
    
    var googleGeminiAPIKey: String? {
        guard let key = secrets["GoogleGeminiAPIKey"] as? String,
              key != "YOUR_GEMINI_API_KEY_HERE" else {
            return nil
        }
        return key
    }
    
    // MARK: - App Configuration
    
    var environment: String {
        return secrets["Environment"] as? String ?? "development"
    }
    
    var enableDebugLogging: Bool {
        return secrets["EnableDebugLogging"] as? Bool ?? false
    }
    
    var enableMockData: Bool {
        return secrets["EnableMockData"] as? Bool ?? true
    }
    
    var enableAnalytics: Bool {
        return secrets["EnableAnalytics"] as? Bool ?? false
    }
    
    // MARK: - Validation
    
    var hasValidConfiguration: Bool {
        return supabaseURL != nil && 
               supabaseAnonKey != nil &&
               (openAIAPIKey != nil || googleGeminiAPIKey != nil)
    }
    
    func validateConfiguration() throws {
        var missingKeys: [String] = []
        
        if supabaseURL == nil {
            missingKeys.append("SupabaseURL")
        }
        
        if supabaseAnonKey == nil {
            missingKeys.append("SupabaseAnonKey")
        }
        
        if openAIAPIKey == nil && googleGeminiAPIKey == nil {
            missingKeys.append("OpenAIAPIKey or GoogleGeminiAPIKey")
        }
        
        if !missingKeys.isEmpty {
            throw SecretsError.missingConfiguration(missingKeys)
        }
    }
}

// MARK: - Errors

enum SecretsError: LocalizedError {
    case missingConfiguration([String])
    
    var errorDescription: String? {
        switch self {
        case .missingConfiguration(let keys):
            return "Missing required configuration in Secrets.plist: \(keys.joined(separator: ", "))"
        }
    }
}
