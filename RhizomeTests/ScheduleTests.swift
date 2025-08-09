//
//  ScheduleTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import Foundation
@testable import Rhizome

@Suite("Schedule Tests")
struct ScheduleTests {

    @Test
    func parseDateWithDateAndTime() {
        // Given: A Schedule instance and timestamp
        let schedule = Schedule(newsUrl: nil, schedule: nil)
        let timestamp: TimeInterval = 1719489600 // June 27, 2024 12:00 PM ET
        let timezone = "America/New_York"

        // When: Parsing date with both date and time
        let result = schedule.parseDate(timestamp: timestamp, timezone: timezone, showDate: true)

        // Then: Should include both date and time
        #expect(result.contains("2024"))
        #expect(result.contains("June") || result.contains("Jun"))
        #expect(result.contains("27"))
        #expect(result.contains("PM") || result.contains("AM"))
    }

    @Test
    func parseDateTimeOnly() {
        // Given: A Schedule instance and timestamp
        let schedule = Schedule(newsUrl: nil, schedule: nil)
        let timestamp: TimeInterval = 1719489600 // June 27, 2024 12:00 PM ET
        let timezone = "America/New_York"

        // When: Parsing date with time only (showDate: false)
        let result = schedule.parseDate(timestamp: timestamp, timezone: timezone, showDate: false)

        // Then: Should include only time, not date
        #expect(!result.contains("2024"))
        #expect(!result.contains("June") && !result.contains("Jun"))
        #expect(!result.contains("27"))
        #expect(result.contains("PM") || result.contains("AM"))
    }

    @Test
    func parseDateWithDifferentTimeZone() {
        // Given: A Schedule instance and timestamp
        let schedule = Schedule(newsUrl: nil, schedule: nil)
        let timestamp: TimeInterval = 1719489600 // June 27, 2024 09:00 AM PT
        let timezone = "America/Los_Angeles"

        // When: Parsing date with different timezone
        let result = schedule.parseDate(timestamp: timestamp, timezone: timezone, showDate: true)

        // Then: Should format according to the specified timezone
        #expect(result.contains("2024"))
        #expect(result.contains("AM") || result.contains("PM"))
    }

    @Test
    func parseDatePerformance() {
        let schedule = Schedule(newsUrl: nil, schedule: nil)
        let timestamp: TimeInterval = 1719489600
        let timezone = "America/New_York"

        measure {
            _ = schedule.parseDate(timestamp: timestamp, timezone: timezone, showDate: true)
        }
    }

    @Test
    func scheduleInitialization() {
        // Given: Schedule parameters
        let newsUrl = "https://example.com/news"
        let appointments = Appointments(daycare: [])

        // When: Creating a Schedule
        let schedule = Schedule(newsUrl: newsUrl, schedule: appointments)

        // Then: Properties should be set correctly
        #expect(schedule.newsUrl == newsUrl)
        #expect(schedule.schedule != nil)
        #expect(schedule.schedule?.daycare.count == 0)
    }

    @Test
    func scheduleWithNilValues() {
        // Given: Nil parameters
        let schedule = Schedule(newsUrl: nil, schedule: nil)

        // Then: Should handle nil values gracefully
        #expect(schedule.newsUrl == nil)
        #expect(schedule.schedule == nil)
    }
}
