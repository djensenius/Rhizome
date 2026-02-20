//
//  ContentViewTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import SwiftUI
@testable import Rhizome

@MainActor
@Suite("ContentView Tests")
struct ContentViewTests {

    @Test
    func contentViewInitialization() {
        // Given: Parameters for ContentView
        let cameraURL = "https://example.com/stream"
        let daycare = AppointmentsDaycare(startDate: "Thursday, 8/14/2025 9:00 am", rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)

        // When: Creating ContentView
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)

        // Then: Should initialize correctly
        #expect(contentView.cameraURL == cameraURL)
        #expect(contentView.rhizomeSchedule != nil)
        #expect(!contentView.inPlayroom)
    }

    @Test
    func contentViewInitializationWithNilSchedule() {
        // Given: Parameters with nil schedule
        let cameraURL = "https://example.com/stream"

        // When: Creating ContentView with nil schedule
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)

        // Then: Should handle nil schedule gracefully
        #expect(contentView.cameraURL == cameraURL)
        #expect(contentView.rhizomeSchedule == nil)
        #expect(!contentView.inPlayroom)
    }

    @Test
    func parseScheduleWithTodayAppointment() {
        // Given: A ContentView with an appointment for today
        let cameraURL = "https://example.com/stream"

        let torontoTimeZone = TimeZone(identifier: "America/Toronto")!
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, M/d/yyyy h:mm a"
        formatter.timeZone = torontoTimeZone
        let todayString = formatter.string(from: Date())

        let daycare = AppointmentsDaycare(startDate: todayString, rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)
        var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)

        // When: Parsing the schedule
        contentView.parseSchedule()

        // Then: inPlayroom depends on whether current Toronto time is 7am-7pm
        let now = Date()
        let nowToronto = now.addingTimeInterval(
            TimeInterval(torontoTimeZone.secondsFromGMT(for: now) - TimeZone.current.secondsFromGMT(for: now))
        )
        var calendar = Calendar.current
        calendar.timeZone = torontoTimeZone
        let hour = calendar.component(.hour, from: nowToronto)
        let expectedInPlayroom = hour >= 7 && hour < 19

        #expect(contentView.inPlayroom == expectedInPlayroom)
    }

    @Test
    func parseScheduleWithFutureAppointment() {
        // Given: A ContentView with a future appointment
        let cameraURL = "https://example.com/stream"

        let torontoTimeZone = TimeZone(identifier: "America/Toronto")!
        let tomorrow = Date().addingTimeInterval(48 * 60 * 60)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, M/d/yyyy h:mm a"
        formatter.timeZone = torontoTimeZone
        let tomorrowString = formatter.string(from: tomorrow)

        let daycare = AppointmentsDaycare(startDate: tomorrowString, rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)
        var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)

        // When: Parsing the schedule
        contentView.parseSchedule()

        // Then: Should not be in playroom (future date)
        #expect(!contentView.inPlayroom)
    }

    @Test
    func parseScheduleWithNilSchedule() {
        // Given: A ContentView with nil schedule
        let cameraURL = "https://example.com/stream"
        var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)

        // When: Parsing the schedule
        contentView.parseSchedule()

        // Then: Should not be in playroom
        #expect(!contentView.inPlayroom)
    }
}
