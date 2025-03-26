//
//  HapticService.swift
//  SUIBasicLib
//
//  Created by admin on 21.03.2025.
//

#if os(iOS)
import UIKit

@MainActor
public class HapticService {
    
    public static let shared = HapticService()
    
    private init() {}
    
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    public func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
#endif
