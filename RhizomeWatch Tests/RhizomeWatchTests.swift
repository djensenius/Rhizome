//
//  RhizomeWatchTests.swift
//  RhizomeWatch Tests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import Foundation
import SwiftUI
import AVKit
@testable import RhizomeWatch_Watch_App

@MainActor
@Suite("Rhizome watchOS ContentView Tests")
struct RhizomeWatchTests {

    // MARK: - ContentView Tests

    @Test
    func watchContentViewInitialization() {
        // Given
        let cameraURL = "https://example.com/stream"
        let daycare = AppointmentsDaycare(startDate: "Thursday, 8/14/2025 9:00 am", rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)

        // When
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)

        // Then
        #expect(contentView.cameraURL == cameraURL)
        #expect(contentView.rhizomeSchedule != nil)
        #expect(!contentView.inPlayroom)
    }

    @Test
    func watchContentViewWithNilSchedule() {
        // Given
        let cameraURL = "https://example.com/stream"

        // When
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)

        // Then
        #expect(contentView.cameraURL == cameraURL)
        #expect(contentView.rhizomeSchedule == nil)
        #expect(!contentView.inPlayroom)
    }

    @Test
    func watchContentViewParseScheduleWithTodayAppointment() {
        // Given
        let cameraURL = "https://example.com/stream"

        let torontoTimeZone = TimeZone(identifier: "America/Toronto")!
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, M/d/yyyy h:mm a"
        formatter.timeZone = torontoTimeZone
        let todayString = formatter.string(from: Date())

        let daycare = AppointmentsDaycare(startDate: todayString, rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)
        var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)

        // When
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
    func watchContentViewParseScheduleWithFutureAppointment() {
        // Given
        let cameraURL = "https://example.com/stream"

        let torontoTimeZone = TimeZone(identifier: "America/Toronto")!
        let futureDate = Date().addingTimeInterval(48 * 60 * 60)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, M/d/yyyy h:mm a"
        formatter.timeZone = torontoTimeZone
        let futureString = formatter.string(from: futureDate)

        let daycare = AppointmentsDaycare(startDate: futureString, rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)
        var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)

        // When
        contentView.parseSchedule()

        // Then
        #expect(!contentView.inPlayroom)
    }

    @Test
    func watchContentViewWithEmptyURL() {
        // Given
        let cameraURL = ""

        // When
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)

        // Then
        #expect(contentView.cameraURL == "")
    }

    // MARK: - Performance Tests

    @Test(.timeLimit(.seconds(5)))
    func watchContentViewPerformance() {
        let cameraURL = "https://example.com/stream"
        let daycare = AppointmentsDaycare(startDate: "Thursday, 8/14/2025 9:00 am", rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)
        for _ in 0..<100 {
            _ = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
        }
    }

    @Test(.timeLimit(.seconds(5)))
    func watchParseSchedulePerformance() {
        let cameraURL = "https://example.com/stream"
        let daycare = AppointmentsDaycare(startDate: "Thursday, 8/14/2025 9:00 am", rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)

        for _ in 0..<100 {
            var contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
            contentView.parseSchedule()
        }
    }

    // MARK: - watchOS Specific

    @Test
    func watchContentViewHandlesAVKit() {
        // Given
        let cameraURL = "https://example.com/test-stream"

        // When
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: nil)

        // Then (sanity check; full AVKit playback requires integration tests)
        #expect(contentView.cameraURL == cameraURL)
    }
}
