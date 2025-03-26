//
//  NotificationService.swift
//  SUIBasicLib
//
//  Created by admin on 24.03.2025.
//

import Foundation
#if os(iOS)
import UserNotifications

public enum NotificationType {
    case timeInterval(seconds: TimeInterval)
    case daily(hour: Int, minute: Int)
    case weekly(hour: Int, minute: Int, daysOfWeek: [NotificationWeek])
    case monthly(day: Int, hour: Int, minute: Int)
    case yearly(day: Int, month: Int, hour: Int, minute: Int)
}

public enum NotificationWeek: Int {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

public class NotificationService {
    @MainActor
    public static let shared = NotificationService()
    
    private init() {}
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    
    public func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
         notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
             if let error = error {
                 debugPrint("Ошибка запроса разрешений: \(error.localizedDescription)")
             }
             completion(granted)
         }
     }
    
    public func scheduleNotification(
        title: String,
        body: String,
        type: NotificationType,
        identifier: String
    ) {
        let content = createNotificationContent(title: title, body: body)
        var trigger: UNNotificationTrigger?
        switch type {
        case .timeInterval(let seconds):
            guard seconds > 0 else { return }
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        case .daily(let hour, let minute):
            trigger = createCalendarTrigger(hour: hour, minute: minute)
        case .weekly(let hour, let minute, let daysOfWeek):
            for day in daysOfWeek {
                trigger = createCalendarTrigger(hour: hour, minute: minute, weekday: day.rawValue)
                if let trigger = trigger {
                    let requst = UNNotificationRequest(identifier: identifier + "_weekday:_\(day.rawValue)", content: content, trigger: trigger)
                    addRequest(requst)
                }
            }
            return
        case .monthly(let day, let hour, let minute):
            trigger = createCalendarTrigger(hour: hour, minute: minute, day: day)
        case .yearly(let day, let month, let hour, let minute):
            trigger = createCalendarTrigger(hour: hour, minute: minute, day: day, month: month)
        }
        
        if let trigger = trigger {
            let requst = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            addRequest(requst)
        }
    }
}

extension NotificationService {
    public func listScheduledNotifications(_ completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            debugPrint("Запланированные уведомления:")
            for request in requests {
                debugPrint("ID: \(request.identifier), Content: \(request.content.title) - \(request.content.body)")
            }
            completion(requests)
        }
    }
}

extension NotificationService {
    
    public func updateNotificationIfExists(
        newTitle: String,
        newBody: String,
        type: NotificationType,
        identifier: String
    ) {
        notificationCenter.getPendingNotificationRequests { requests in
            let existingIdentifiers = requests.map { $0.identifier }
            if existingIdentifiers.contains(identifier) {
                self.updateNotification(newTitle: newTitle, newBody: newBody, type: type, identifier: identifier)
            } else {
                debugPrint("Уведомление с идентификатором \(identifier) не найдено.")
            }
        }
    }
    
    public func updateNotification(
        newTitle: String,
        newBody: String,
        type: NotificationType,
        identifier: String
    ) {
        removeNotification(withIdentifier: identifier)
        scheduleNotification(title: newTitle, body: newBody, type: type, identifier: identifier)
    }
    
    public func removeNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        debugPrint("Уведомление с ID: \(identifier) успешно удалено")
    }

    public func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
}

extension NotificationService {
    private func createCalendarTrigger(hour: Int, minute: Int, day: Int? = nil, month: Int? = nil, weekday: Int? = nil) -> UNCalendarNotificationTrigger? {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            if let day = day {
                dateComponents.day = day
            }
            if let month = month {
                dateComponents.month = month
            }
            if let weekday = weekday {
                dateComponents.weekday = weekday
            }
            
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
}

extension NotificationService {
    private func validateDaysOfWeek(_ days: [Int]) -> [Int] {
        return days.filter { (1...7).contains($0) }
    }
    
    private func createNotificationContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return content
    }

    private func addRequest(_ request: UNNotificationRequest) {
        notificationCenter.add(request) { error in
            if let error = error {
                debugPrint("Ошибка добавления уведомления: \(error.localizedDescription)")
            } else {
                debugPrint("Уведомление успешно добавлено с ID: \(request.identifier)")
            }
        }
    }
}
#endif
