//
//  RhizomeMacTests.swift
//  RhizomeMacTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import SwiftUI

// MARK: - ColumnStepper Tests

@MainActor @Test func columnStepperInitialization() throws {
    let range = 1...10
    let stepper = ColumnStepper(
        title: "Columns",
        range: range,
        columns: .constant(Array(repeating: GridItem(.flexible()), count: 3))
    )
    #expect(type(of: stepper) == ColumnStepper.self)
}

@MainActor @Test func gridViewInitialization() throws {
    let images = ["image1.jpg", "image2.jpg", "image3.jpg"]
    let gridView = GridView(images: images)
    #expect(type(of: gridView) == GridView.self)
}

@MainActor @Test func gridViewWithEmptyImages() throws {
    let images: [String] = []
    let gridView = GridView(images: images)
    #expect(type(of: gridView) == GridView.self)
}

// MARK: - GridItemView Tests

@MainActor @Test func gridItemViewInitialization() throws {
    let itemURL = URL(string: "https://example.com/image.jpg")!
    let itemView = GridItemView(size: 100, item: itemURL)
    #expect(type(of: itemView) == GridItemView.self)
}

@MainActor @Test func gridItemViewWithSize() throws {
    let itemURL = URL(string: "https://example.com/image.jpg")!
    let smallView = GridItemView(size: 50, item: itemURL)
    let largeView = GridItemView(size: 500, item: itemURL)
    #expect(type(of: smallView) == GridItemView.self)
    #expect(type(of: largeView) == GridItemView.self)
}

// MARK: - DetailView Tests

@MainActor @Test func detailViewInitialization() throws {
    let itemURL = URL(string: "https://example.com/image.jpg")!
    let detailView = DetailView(item: itemURL)
    #expect(type(of: detailView) == DetailView.self)
}

// MARK: - ContentView Tests

@MainActor @Test func macContentViewInitialization() throws {
    let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]
    let schedule: Appointments? = nil
    let contentView = ContentView(cameras: cameras, rhizomeSchedule: schedule)
    #expect(type(of: contentView) == ContentView.self)
}

@MainActor @Test func macContentViewWithSchedule() throws {
    let cameras = [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")]
    let daycare = AppointmentsDaycare(
        startDate: "Thursday, 8/14/2025 9:00 am",
        rId: 1,
        type: "Daycare | Full Day"
    )
    let appointments = Appointments(nextReservation: daycare)
    let contentView = ContentView(cameras: cameras, rhizomeSchedule: appointments)
    #expect(type(of: contentView) == ContentView.self)
}

// MARK: - Performance Tests

@MainActor @Test(.timeLimit(.minutes(1))) func gridViewPerformance() throws {
    let images = Array(1...100).map { "image\($0).jpg" }
    _ = GridView(images: images)
}

@MainActor @Test(.timeLimit(.minutes(1))) func detailViewPerformance() throws {
    let itemURL = URL(string: "https://example.com/large-image.jpg")!
    _ = DetailView(item: itemURL)
}
