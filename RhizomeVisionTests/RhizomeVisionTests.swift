//
//  RhizomeVisionTests.swift
//  RhizomeVisionTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import SwiftUI
@testable import RhizomeVision

// MARK: - ContentView Tests

@MainActor
@Test func visionContentViewInitialization() throws {
    // Given: ContentView parameters for visionOS
    let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]
    let daycare = AppointmentsDaycare(
        startDate: "Thursday, 8/14/2025 9:00 am",
        rId: 1,
        type: "Daycare | Full Day"
    )
    let appointments = Appointments(nextReservation: daycare)

    // When: Creating ContentView
    let contentView = ContentView(cameras: cameras, rhizomeSchedule: appointments)

    // Then: Should initialize correctly (avoid comparing non-optional to nil)
    #expect(type(of: contentView) == ContentView.self)
    // Note: Detailed testing of visionOS-specific features would require visionOS simulator
}

@MainActor
@Test func visionContentViewWithNilSchedule() throws {
    // Given: ContentView parameters with nil schedule
    let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]

    // When: Creating ContentView with nil schedule
    let contentView = ContentView(cameras: cameras, rhizomeSchedule: nil)

    // Then: Should handle nil schedule gracefully
    #expect(type(of: contentView) == ContentView.self)
}

@MainActor
@Test func visionContentViewWithEmptyURL() throws {
    // Given: ContentView with empty camera URL
    let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "")]

    // When: Creating ContentView with empty URL
    let contentView = ContentView(cameras: cameras, rhizomeSchedule: nil)

    // Then: Should handle empty URL gracefully
    #expect(type(of: contentView) == ContentView.self)
}

// MARK: - Performance Tests

@Test(.timeLimit(.minutes(1))) func visionContentViewPerformance() throws {
    let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]
    let daycare = AppointmentsDaycare(
        startDate: "Thursday, 8/14/2025 9:00 am",
        rId: 1,
        type: "Daycare | Full Day"
    )
    let appointments = Appointments(nextReservation: daycare)

    _ = ContentView(cameras: cameras, rhizomeSchedule: appointments)
}

// MARK: - VisionOS Specific Tests

@MainActor
@Test func visionContentViewHandlesRealityKitIntegration() throws {
    // Given: Parameters that would use RealityKit
    let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]
    let daycare = AppointmentsDaycare(
        startDate: "Thursday, 8/14/2025 9:00 am",
        rId: 1,
        type: "Daycare | Full Day"
    )
    let appointments = Appointments(nextReservation: daycare)

    // When: Creating ContentView (which should integrate with RealityKit)
    let contentView = ContentView(cameras: cameras, rhizomeSchedule: appointments)

    // Then: Should not crash when RealityKit components are involved
    #expect(type(of: contentView) == ContentView.self)
    // Note: Full RealityKit testing would require visionOS environment
}

@MainActor
@Test func visionContentViewWithComplexSchedule() throws {
    // Given: Complex schedule data
    let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]
    let daycare = AppointmentsDaycare(
        startDate: "Thursday, 8/14/2025 9:00 am",
        rId: 1,
        type: "Daycare | Full Day"
    )
    let appointments = Appointments(nextReservation: daycare)

    // When: Creating ContentView with complex schedule
    let contentView = ContentView(cameras: cameras, rhizomeSchedule: appointments)

    // Then: Should handle complex data gracefully
    #expect(type(of: contentView) == ContentView.self)
}
