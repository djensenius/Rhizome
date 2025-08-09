//
//  RhizomeWatchTests.swift
//  RhizomeWatch Tests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import SwiftUI
import AVKit
@testable import RhizomeWatch_Watch_App

// MARK: - ContentView Tests

@Test func watchContentViewInitialization() throws {
        // Given: ContentView parameters for watchOS
        let cameraURL = "https://example.com/stream"
        let appointments = Appointments(daycare: [])
        
        // When: Creating ContentView
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
        
        // Then: Should initialize correctly
        #expect(contentView != nil)
        #expect(contentView.cameraURL == cameraURL)
        #expect(contentView.rhizomeSchedule != nil)
        #expect(!contentView.inPlayroom)
    }
    
    @Test func WatchContentViewWithNilSchedule() throws {
        // Given: ContentView parameters with nil schedule
        let cameraURL = "https://example.com/stream"
        
        // When: Creating ContentView with nil schedule
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)
        
        // Then: Should handle nil schedule gracefully
        #expect(contentView != nil)
        #expect(contentView.cameraURL == cameraURL)
        XCTAssertNil(contentView.rhizomeSchedule)
        #expect(!contentView.inPlayroom)
    }
    
    @Test func WatchContentViewParseScheduleWithActiveAppointment() throws {
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
        #expect(contentView.inPlayroom)
    }
    
    @Test func WatchContentViewParseScheduleWithInactiveAppointment() throws {
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
        #expect(!contentView.inPlayroom)
    }
    
    @Test func WatchContentViewWithEmptyURL() throws {
        // Given: ContentView with empty camera URL
        let cameraURL = ""
        
        // When: Creating ContentView with empty URL
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)
        
        // Then: Should handle empty URL gracefully
        #expect(contentView != nil)
        #expect(contentView.cameraURL == "")
    }
    
    // MARK: - Performance Tests
    
    @Test func WatchContentViewPerformance() throws {
        let cameraURL = "https://example.com/stream"
        let appointments = Appointments(daycare: [])
        
        @Test(.timeLimit(.seconds(5))) func performanceTest() throws {
            let _ = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
        }
    }
    
    @Test func WatchParseSchedulePerformance() throws {
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
        
        @Test(.timeLimit(.seconds(5))) func performanceTest() throws {
            contentView.parseSchedule()
        }
    }
    
    // MARK: - WatchOS Specific Tests
    
    @Test func WatchContentViewHandlesAVKit() throws {
        // Given: Parameters that would use AVKit
        let cameraURL = "https://example.com/test-stream"
        
        // When: Creating ContentView (which uses AVKit for video)
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)
        
        // Then: Should not crash when AVKit components are involved
        #expect(contentView != nil)
        #expect(contentView.cameraURL == cameraURL)
        // Note: Full AVKit testing would require actual video URL and player
    }
}