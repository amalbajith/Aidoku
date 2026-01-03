//
//  DebugDataGenerator.swift
//  Aidoku
//
//  Created for testing Insights feature
//

import Foundation
import CoreData

#if DEBUG
class DebugDataGenerator {
    
    /// Generates fake reading sessions for testing the Insights/Statistics tab
    static func generateFakeReadingSessions() async {
        print("🎲 Generating fake reading sessions...")
        
        await CoreDataManager.shared.container.performBackgroundTask { context in
            let calendar = Calendar.current
            let now = Date()
            
            // Create some fake manga identifiers
            let fakeManga = [
                ("mangasee", "one-piece"),
                ("mangasee", "naruto"),
                ("mangasee", "bleach"),
                ("mangasee", "attack-on-titan")
            ]
            
            var sessionCount = 0
            
            // Generate sessions for the past 90 days
            for dayOffset in 0..<90 {
                guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
                
                // Randomly skip some days (to create gaps in streak)
                let shouldSkip = Int.random(in: 0...100) < 30 // 30% chance to skip
                if shouldSkip { continue }
                
                // Generate 1-5 reading sessions per day
                let sessionsPerDay = Int.random(in: 1...5)
                
                for sessionIndex in 0..<sessionsPerDay {
                    let manga = fakeManga.randomElement()!
                    let chapterId = "chapter-\(Int.random(in: 1...100))"
                    
                    // Random session duration (5-60 minutes)
                    let durationMinutes = Int.random(in: 5...60)
                    let startDate = calendar.date(
                        byAdding: .minute,
                        value: -(durationMinutes + sessionIndex * 70),
                        to: date
                    )!
                    let endDate = calendar.date(byAdding: .minute, value: durationMinutes, to: startDate)!
                    
                    // Random pages read (10-50 pages)
                    let pagesRead = Int.random(in: 10...50)
                    
                    // Create history object
                    let historyObject = CoreDataManager.shared.getOrCreateHistory(
                        sourceId: manga.0,
                        mangaId: manga.1,
                        chapterId: chapterId,
                        context: context
                    )
                    
                    if historyObject.dateRead == .distantPast {
                        historyObject.dateRead = endDate
                    }
                    
                    // Create reading session
                    let session = ReadingSessionObject(context: context)
                    session.startDate = startDate
                    session.endDate = endDate
                    session.pagesRead = Int16(pagesRead)
                    session.history = historyObject
                    
                    sessionCount += 1
                }
            }
            
            // Save all sessions
            do {
                try context.save()
                print("✅ Generated \(sessionCount) fake reading sessions!")
                print("📊 Data covers the past 90 days")
                print("🔥 Should create some reading streaks")
            } catch {
                print("❌ Failed to save fake sessions: \(error)")
            }
        }
    }
    
    /// Clears all reading sessions (useful for testing)
    static func clearAllReadingSessions() async {
        print("🗑️ Clearing all reading sessions...")
        
        await CoreDataManager.shared.container.performBackgroundTask { context in
            CoreDataManager.shared.clearSessions(context: context)
            do {
                try context.save()
                print("✅ Cleared all reading sessions!")
            } catch {
                print("❌ Failed to clear sessions: \(error)")
            }
        }
    }
}
#endif
