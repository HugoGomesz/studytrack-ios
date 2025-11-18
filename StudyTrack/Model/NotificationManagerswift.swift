//
//  NotificationManagerswift.swift
//  StudyTrack
//
//  Created by Hugo Gomes on 11/10/25.
//

import UserNotifications
import Foundation

enum NotificationTiming: String {
    case morningMotivation = "morning_motivation"
    case lunchReminder = "lunch_reminder"
    case eveningPush = "evening_push"
    case streakProtection = "streak_protection"
    case celebration = "celebration"
    case focusCompleted = "focus_completed"
    case breakCompleted = "break_completed"
}

class NotificationManager {
    static let instance = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("❌ Erro ao pedir permissão: \(error.localizedDescription)")
            } else {
                print("✅ Permissão concedida: \(success)")
            }
        }
    }
    
    func scheduleNotification(title: String, subtitle: String? = nil, seconds: Double) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = subtitle ?? ""
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    
    /// Agenda notificação quando foco terminar - chama isso quando timer iniciar
    func scheduleFocusCompletion(duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "⏱️ Foco Completo!"
        content.body = "Parabéns! Você completou sua sessão de foco. Hora de fazer uma pausa."
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TIMER_CATEGORY"
        content.userInfo = ["type": NotificationTiming.focusCompleted.rawValue]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "focus_timer",
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação de foco: \(error.localizedDescription)")
            } else {
                print("✅ Notificação de foco agendada para \(duration) segundos")
            }
        }
    }
    
    /// Agenda notificação quando pausa terminar
    func scheduleBreakCompletion(duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "☕ Pausa Finalizada!"
        content.body = "Sua pausa acabou. Pronto para mais uma sessão de foco?"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TIMER_CATEGORY"
        content.userInfo = ["type": NotificationTiming.breakCompleted.rawValue]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "break_timer",
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação de pausa: \(error.localizedDescription)")
            } else {
                print("✅ Notificação de pausa agendada para \(duration) segundos")
            }
        }
    }
    
    /// Cancela notificações do timer (quando usuário para/pausa manualmente)
    func cancelTimerNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["focus_timer", "break_timer"]
        )
        print("🗑️ Notificações de timer canceladas")
    }
    
    // MARK: - Notificações Diárias Recorrentes (NOVO)
    
    /// Notificação matinal - 8h todos os dias
    func scheduleMorningMotivation() {
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "☀️ Bom dia!"
        content.body = "Pronto para começar? Seu cérebro está no pico de energia agora!"
        content.sound = .default
        content.userInfo = ["type": NotificationTiming.morningMotivation.rawValue]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationTiming.morningMotivation.rawValue,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação matinal: \(error.localizedDescription)")
            } else {
                print("✅ Notificação matinal (8h) agendada")
            }
        }
    }
    
    /// Notificação do almoço - 12h todos os dias
    func scheduleLunchReminder() {
        var dateComponents = DateComponents()
        dateComponents.hour = 12
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "🍽️ Hora do Almoço"
        content.body = "Que tal estudar por 25 minutos após o almoço?"
        content.sound = .default
        content.userInfo = ["type": NotificationTiming.lunchReminder.rawValue]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationTiming.lunchReminder.rawValue,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação do almoço: \(error.localizedDescription)")
            } else {
                print("✅ Notificação do almoço (12h) agendada")
            }
        }
    }
    
    /// Notificação da tarde - 18h todos os dias
    func scheduleEveningPush() {
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 Não esqueça sua meta diária!"
        content.body = "Ainda dá tempo de manter seu streak vivo hoje!"
        content.sound = .default
        content.userInfo = ["type": NotificationTiming.eveningPush.rawValue]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationTiming.eveningPush.rawValue,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação da tarde: \(error.localizedDescription)")
            } else {
                print("✅ Notificação da tarde (18h) agendada")
            }
        }
    }
    
    /// Notificação de proteção de streak - 21h
    func scheduleStreakProtection(currentStreak: Int) {
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 Seu streak está em risco!"
        content.body = "Você tem um streak de \(currentStreak) dias. Estude agora para não perdê-lo!"
        content.sound = .defaultCritical // Som mais forte
        content.badge = 1
        content.userInfo = ["type": NotificationTiming.streakProtection.rawValue]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationTiming.streakProtection.rawValue,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar proteção de streak: \(error.localizedDescription)")
            } else {
                print("✅ Proteção de streak (21h) agendada para streak de \(currentStreak) dias")
            }
        }
    }
    
    /// Atualiza o número do streak na notificação de 21h
    func updateStreakProtectionNumber(newStreak: Int) {
        // Cancela a antiga e agenda nova com número atualizado
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationTiming.streakProtection.rawValue]
        )
        scheduleStreakProtection(currentStreak: newStreak)
    }
    
    // MARK: - Celebrações Imediatas (NOVO)
    
    /// Envia notificação de celebração imediata (1 segundo de delay)
    func sendCelebrationNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Parabéns!"
        content.body = message
        content.sound = .default
        content.badge = 1
        content.userInfo = ["type": NotificationTiming.celebration.rawValue]
        
        // Dispara em 1 segundo
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "celebration_\(UUID().uuidString)",
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao enviar celebração: \(error.localizedDescription)")
            } else {
                print("✅ Celebração enviada: \(message)")
            }
        }
    }
    
    // MARK: - Métodos Auxiliares (NOVO)
    
    /// Agenda todas as notificações diárias de uma vez
    func scheduleAllDailyNotifications(currentStreak: Int = 0) {
        scheduleMorningMotivation()
        scheduleLunchReminder()
        scheduleEveningPush()
        if currentStreak > 0 {
            scheduleStreakProtection(currentStreak: currentStreak)
        }
        print("✅ Todas as notificações diárias agendadas")
    }
    
    /// Cancela TODAS as notificações pendentes
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Todas as notificações foram canceladas")
    }
    
    /// Cancela apenas as notificações diárias (mantém timers)
    func cancelDailyNotifications() {
        let identifiers = [
            NotificationTiming.morningMotivation.rawValue,
            NotificationTiming.lunchReminder.rawValue,
            NotificationTiming.eveningPush.rawValue,
            NotificationTiming.streakProtection.rawValue
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ Notificações diárias canceladas")
    }
    
    /// Remove o badge vermelho do ícone do app
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
        print("🧹 Badge limpo")
    }
    
    /// Lista todas as notificações pendentes (útil para debug)
    func listPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📋 Notificações pendentes: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let nextDate = trigger.nextTriggerDate() {
                    print("  - [\(request.identifier)] próximo disparo: \(nextDate)")
                } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("  - [\(request.identifier)] dispara em \(trigger.timeInterval)s")
                } else {
                    print("  - [\(request.identifier)]")
                }
            }
        }
    }
}
