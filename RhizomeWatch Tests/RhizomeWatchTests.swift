//
//  RhizomeWatchTests.swift
//  RhizomeWatch Tests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest
import SwiftUI
import AVKit
@testable import RhizomeWatch_Watch_App

final class RhizomeWatchTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - ContentView Tests
    
    func testWatchContentViewInitialization() throws {
        // Given: ContentView parameters for watchOS
        let cameraURL = "https://example.com/stream"
        let appointments = Appointments(daycare: [])
        
        // When: Creating ContentView
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
        
        // Then: Should initialize correctly
        XCTAssertNotNil(contentView)
        XCTAssertEqual(contentView.cameraURL, cameraURL)
        XCTAssertNotNil(contentView.rhizomeSchedule)
        XCTAssertFalse(contentView.inPlayroom)
    }
    
    func testWatchContentViewWithNilSchedule() throws {
        // Given: ContentView parameters with nil schedule
        let cameraURL = "https://example.com/stream"
        
        // When: Creating ContentView with nil schedule
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)
        
        // Then: Should handle nil schedule gracefully
        XCTAssertNotNil(contentView)
        XCTAssertEqual(contentView.cameraURL, cameraURL)
        XCTAssertNil(contentView.rhizomeSchedule)
        XCTAssertFalse(contentView.inPlayroom)
    }
    
    func testWatchContentViewParseScheduleWithActiveAppointment() throws {
        // Given: ContentView with active appointment
        let cameraURL = "https://example.com/stream"
        
        // Create an appointment that should be active (current time within range)
        let now = Date()
        let twoHoursAgo = now.addingTimeInterval(-2 * 60 * 60)
        let twoHoursFromNow = now.addingTimeInterval(2 * 60 * 60)
        
        let daycare = AppointmentsDaycare(
            status: "confirmed",
            service: "daycare",
            date: Int(twoHoursAgo.timeIntervalSince1970 * 1000),
            pickupDate: Int(twoHoursFromNow.timeIntervalSince1970 * 1000),
            timezone: "America/New_York",
            accountId: "123",
            locationId: "456",
            petexec: Petexec(execid: 1, daycareid: 2, serviceid: 3, userid: 4, petid: 5),
            dogName: "Rhizome",
            updatedAt: UpdatedAt(),
            id: "test123"
        )
        
        let appointments = Appointments(daycare: [daycare])
        var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
        
        // When: Parsing the schedule
        contentView.parseSchedule()
        
        // Then: Should be in playroom
        XCTAssertTrue(contentView.inPlayroom)
    }
    
    func testWatchContentViewParseScheduleWithInactiveAppointment() throws {
        // Given: ContentView with inactive appointment
        let cameraURL = "https://example.com/stream"
        
        // Create an appointment that is in the future
        let tomorrow = Date().addingTimeInterval(24 * 60 * 60)
        let dayAfterTomorrow = tomorrow.addingTimeInterval(24 * 60 * 60)
        
        let daycare = AppointmentsDaycare(
            status: "confirmed",
            service: "daycare",
            date: Int(tomorrow.timeIntervalSince1970 * 1000),
            pickupDate: Int(dayAfterTomorrow.timeIntervalSince1970 * 1000),
            timezone: "America/New_York",
            accountId: "123",
            locationId: "456",
            petexec: Petexec(execid: 1, daycareid: 2, serviceid: 3, userid: 4, petid: 5),
            dogName: "Rhizome",
            updatedAt: UpdatedAt(),
            id: "test123"
        )
        
        let appointments = Appointments(daycare: [daycare])
        var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
        
        // When: Parsing the schedule
        contentView.parseSchedule()
        
        // Then: Should not be in playroom
        XCTAssertFalse(contentView.inPlayroom)
    }
    
    func testWatchContentViewWithEmptyURL() throws {
        // Given: ContentView with empty camera URL
        let cameraURL = ""
        
        // When: Creating ContentView with empty URL
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)
        
        // Then: Should handle empty URL gracefully
        XCTAssertNotNil(contentView)
        XCTAssertEqual(contentView.cameraURL, "")
    }
    
    // MARK: - Performance Tests
    
    func testWatchContentViewPerformance() throws {
        let cameraURL = "https://example.com/stream"
        let appointments = Appointments(daycare: [])
        
        measure {
            let _ = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
        }
    }
    
    func testWatchParseSchedulePerformance() throws {
        let cameraURL = "https://example.com/stream"
        
        // Create multiple appointments
        let appointments = Appointments(daycare: Array(1...10).map { index in
            AppointmentsDaycare(
                status: "confirmed",
                service: "daycare",
                date: Int(Date().timeIntervalSince1970 * 1000),
                pickupDate: Int(Date().addingTimeInterval(3600).timeIntervalSince1970 * 1000),
                timezone: "America/New_York",
                accountId: "\(index)",
                locationId: "\(index)",
                petexec: Petexec(execid: index, daycareid: index, serviceid: index, userid: index, petid: index),
                dogName: "Rhizome\(index)",
                updatedAt: UpdatedAt(),
                id: "test\(index)"
            )
        })
        
        var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
        
        measure {
            contentView.parseSchedule()
        }
    }
    
    // MARK: - WatchOS Specific Tests
    
    func testWatchContentViewHandlesAVKit() throws {
        // Given: Parameters that would use AVKit
        let cameraURL = "https://example.com/test-stream"
        
        // When: Creating ContentView (which uses AVKit for video)
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)
        
        // Then: Should not crash when AVKit components are involved
        XCTAssertNotNil(contentView)
        XCTAssertEqual(contentView.cameraURL, cameraURL)
        // Note: Full AVKit testing would require actual video URL and player
    }
}