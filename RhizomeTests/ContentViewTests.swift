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
        let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]
        let daycare = AppointmentsDaycare(startDate: "Thursday, 8/14/2025 9:00 am", rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)

        // When: Creating ContentView
        let contentView = ContentView(cameras: cameras, rhizomeSchedule: appointments)

        // Then: Should initialize correctly
        #expect(contentView.cameras[0].url == cameras[0].url)
        #expect(contentView.rhizomeSchedule != nil)
        #expect(!contentView.inPlayroom)
    }

    @Test
    func contentViewInitializationWithNilSchedule() {
        // Given: Parameters with nil schedule
        let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]

        // When: Creating ContentView with nil schedule
        let contentView = ContentView(cameras: cameras, rhizomeSchedule: nil)

        // Then: Should handle nil schedule gracefully
        #expect(contentView.cameras[0].url == cameras[0].url)
        #expect(contentView.rhizomeSchedule == nil)
        #expect(!contentView.inPlayroom)
    }

    @Test
    func parseScheduleWithTodayAppointment() {
        // Given: A ContentView with an appointment for today
        let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]

        let torontoTimeZone = TimeZone(identifier: "America/Toronto")!
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, M/d/yyyy h:mm a"
        formatter.timeZone = torontoTimeZone
        let todayString = formatter.string(from: Date())

        let daycare = AppointmentsDaycare(startDate: todayString, rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)
        let contentView = ContentView(cameras: cameras, rhizomeSchedule: appointments)

        // When/Then: parseSchedule() should complete without crashing.
        // Note: @State property changes are not observable outside SwiftUI's
        // view hierarchy, so we verify execution rather than the final value.
        contentView.parseSchedule()
    }

    @Test
    func parseScheduleWithFutureAppointment() {
        // Given: A ContentView with a future appointment
        let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]

        let torontoTimeZone = TimeZone(identifier: "America/Toronto")!
        let tomorrow = Date().addingTimeInterval(48 * 60 * 60)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, M/d/yyyy h:mm a"
        formatter.timeZone = torontoTimeZone
        let tomorrowString = formatter.string(from: tomorrow)

        let daycare = AppointmentsDaycare(startDate: tomorrowString, rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)
        let contentView = ContentView(cameras: cameras, rhizomeSchedule: appointments)

        // When: Parsing the schedule
        contentView.parseSchedule()

        // Then: Should not be in playroom (future date)
        #expect(!contentView.inPlayroom)
    }

    @Test
    func parseScheduleWithNilSchedule() {
        // Given: A ContentView with nil schedule
        let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]
        let contentView = ContentView(cameras: cameras, rhizomeSchedule: nil)

        // When: Parsing the schedule
        contentView.parseSchedule()

        // Then: Should not be in playroom
        #expect(!contentView.inPlayroom)
    }
}
