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
        let appointments = Appointments(daycare: [])

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
    func watchContentViewParseScheduleWithActiveAppointment() {
        // Given
        let cameraURL = "https://example.com/stream"

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

        // When
        contentView.parseSchedule()

        // Then
        #expect(contentView.inPlayroom)
    }

    @Test
    func watchContentViewParseScheduleWithInactiveAppointment() {
        // Given
        let cameraURL = "https://example.com/stream"

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
        let appointments = Appointments(daycare: [])
        measure {
            _ = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)
        }
    }

    @Test(.timeLimit(.seconds(5)))
    func watchParseSchedulePerformance() {
        let cameraURL = "https://example.com/stream"

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

        measure {
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
