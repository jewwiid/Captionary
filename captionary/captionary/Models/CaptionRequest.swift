//
//  CaptionRequest.swift
//  Captionary
//
//  Created by Claude on 2025-10-06.
//  Core data model for caption generation requests
//

import Foundation
import UIKit

/// Represents a user's request for caption generation
struct CaptionRequest: Codable, Identifiable {
    let id = UUID()
    let mood: String
    let mediaDescription: String
    let goal: String
    let tone: String
    let platform: String
    let mediaType: MediaType
    let imageData: Data?
    let createdAt: Date
    
    enum MediaType: String, Codable, CaseIterable {
        case photo = "photo"
        case video = "video"
    }
    
    enum CodingKeys: String, CodingKey {
        case mood, mediaDescription, goal, tone, platform, mediaType, imageData, createdAt
    }
    
    init(mood: String, mediaDescription: String, goal: String, tone: String, platform: String, mediaType: MediaType, imageData: Data? = nil) {
        self.mood = mood
        self.mediaDescription = mediaDescription
        self.goal = goal
        self.tone = tone
        self.platform = platform
        self.mediaType = mediaType
        self.imageData = imageData
        self.createdAt = Date()
    }
}

// MARK: - Convenience Initializers
extension CaptionRequest {
    /// Create request for API submission (excludes image data for efficiency)
    var apiRequest: APICaptionRequest {
        APICaptionRequest(
            mood: mood,
            mediaDescription: mediaDescription,
            goal: goal,
            tone: tone,
            platform: platform
        )
    }
}

/// Lightweight version for API calls (matches documented LLM prompt structure)
struct APICaptionRequest: Codable {
    let mood: String
    let mediaDescription: String
    let goal: String
    let tone: String
    let platform: String
}
