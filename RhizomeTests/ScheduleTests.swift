//
//  ScheduleTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest
import SwiftUI
@testable import Rhizome

final class ScheduleTests: XCTestCase {

    func testParseDateWithDateAndTime() throws {
        // Given: A Schedule instance and timestamp
        let schedule = Schedule(newsUrl: nil, schedule: nil)
        let timestamp: TimeInterval = 1719489600 // June 27, 2024 12:00:00 PM EST
        let timezone = "America/New_York"
        
        // When: Parsing date with both date and time
        let result = schedule.parseDate(timestamp: timestamp, timezone: timezone, showDate: true)
        
        // Then: Should include both date and time
        XCTAssertTrue(result.contains("2024"))
        XCTAssertTrue(result.contains("June") || result.contains("Jun"))
        XCTAssertTrue(result.contains("27"))
        XCTAssertTrue(result.contains("PM") || result.contains("AM"))
    }
    
    func testParseDateTimeOnly() throws {
        // Given: A Schedule instance and timestamp
        let schedule = Schedule(newsUrl: nil, schedule: nil)
        let timestamp: TimeInterval = 1719489600 // June 27, 2024 12:00:00 PM EST
        let timezone = "America/New_York"
        
        // When: Parsing date with time only (showDate: false)
        let result = schedule.parseDate(timestamp: timestamp, timezone: timezone, showDate: false)
        
        // Then: Should include only time, not date
        XCTAssertFalse(result.contains("2024"))
        XCTAssertFalse(result.contains("June"))
        XCTAssertFalse(result.contains("27"))
        XCTAssertTrue(result.contains("PM") || result.contains("AM"))
    }
    
    func testParseDateWithDifferentTimezone() throws {
        // Given: A Schedule instance and timestamp
        let schedule = Schedule(newsUrl: nil, schedule: nil)
        let timestamp: TimeInterval = 1719489600 // June 27, 2024 12:00:00 PM EST
        let timezone = "America/Los_Angeles"
        
        // When: Parsing date with different timezone
        let result = schedule.parseDate(timestamp: timestamp, timezone: timezone, showDate: true)
        
        // Then: Should format according to the specified timezone
        XCTAssertTrue(result.contains("2024"))
        XCTAssertTrue(result.contains("AM") || result.contains("PM"))
    }
    
    func testParseDatePerformance() throws {
        let schedule = Schedule(newsUrl: nil, schedule: nil)
        let timestamp: TimeInterval = 1719489600
        let timezone = "America/New_York"
        
        measure {
            _ = schedule.parseDate(timestamp: timestamp, timezone: timezone, showDate: true)
        }
    }
    
    func testScheduleInitialization() throws {
        // Given: Schedule parameters
        let newsUrl = "https://example.com/news"
        let appointments = Appointments(daycare: [])
        
        // When: Creating a Schedule
        let schedule = Schedule(newsUrl: newsUrl, schedule: appointments)
        
        // Then: Properties should be set correctly
        XCTAssertEqual(schedule.newsUrl, newsUrl)
        XCTAssertNotNil(schedule.schedule)
        XCTAssertEqual(schedule.schedule?.daycare.count, 0)
    }
    
    func testScheduleWithNilValues() throws {
        // Given: Nil parameters
        let schedule = Schedule(newsUrl: nil, schedule: nil)
        
        // Then: Should handle nil values gracefully
        XCTAssertNil(schedule.newsUrl)
        XCTAssertNil(schedule.schedule)
    }
}