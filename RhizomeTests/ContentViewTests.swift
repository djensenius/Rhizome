//
//  ContentViewTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import SwiftUI
@testable import Rhizome

@Test func contentViewInitialization() throws {
    // Given: Parameters for ContentView
    let cameraURL = "https://example.com/stream"
    let appointments = Appointments(daycare: [])
    
    // When: Creating ContentView
    let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
    
    // Then: Should initialize correctly
    #expect(contentView.cameraURL == cameraURL)
    #expect(contentView.rhizomeSchedule != nil)
    #expect(!contentView.showVideo)
    #expect(!contentView.inPlayroom)
}

@Test func contentViewInitializationWithNilSchedule() throws {
    // Given: Parameters with nil schedule
    let cameraURL = "https://example.com/stream"
    
    // When: Creating ContentView with nil schedule
    let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)
    
    // Then: Should handle nil schedule gracefully
    #expect(contentView.cameraURL == cameraURL)
    #expect(contentView.rhizomeSchedule == nil)
    #expect(!contentView.showVideo)
    #expect(!contentView.inPlayroom)
    }
}

@Test func parseScheduleWithActiveAppointment() throws {
    // Given: A ContentView with an active appointment (within the time window)
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
    
    // Then: Should show video and be in playroom
    #expect(contentView.showVideo)
    #expect(contentView.inPlayroom)
}
@Test func parseScheduleWithInactiveAppointment() throws {
    // Given: A ContentView with an inactive appointment (outside the time window)
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
    
    // Then: Should not show video and not be in playroom
    #expect(!contentView.showVideo)
    #expect(!contentView.inPlayroom)
}

@Test func parseScheduleWithNilSchedule() throws {
    // Given: A ContentView with nil schedule
    let cameraURL = "https://example.com/stream"
    var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)
    
    // When: Parsing the schedule
    contentView.parseSchedule()
    
    // Then: Should not show video and not be in playroom
    #expect(!contentView.showVideo)
    #expect(!contentView.inPlayroom)
}
@Test func parseScheduleWithEmptyDaycare() throws {
    // Given: A ContentView with empty daycare appointments
    let cameraURL = "https://example.com/stream"
    let appointments = Appointments(daycare: [])
    var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
    
    // When: Parsing the schedule
    contentView.parseSchedule()
    
    // Then: Should not show video and not be in playroom
    #expect(!contentView.showVideo)
    #expect(!contentView.inPlayroom)
}