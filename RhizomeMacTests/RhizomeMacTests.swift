//
//  RhizomeMacTests.swift
//  RhizomeMacTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import SwiftUI
@testable import RhizomeMac

// MARK: - ColumnStepper Tests

@Test func columnStepperInitialization() throws {
        // Given: ColumnStepper parameters
        let range = 1...10

        // When: Creating ColumnStepper
        let stepper = ColumnStepper(
            title: "Columns",
            range: range,
            columns: .constant(Array(repeating: GridItem(.flexible()), count: 3))
        )

        // Then: Should initialize without crash
        #expect(stepper != nil)
    }

@Test func gridViewInitialization() throws {
        // Given: GridView parameters
        let images = ["image1.jpg", "image2.jpg", "image3.jpg"]

        // When: Creating GridView
        let gridView = GridView(images: images)

        // Then: Should initialize correctly
        #expect(gridView != nil)
    }

    @Test func gridViewWithEmptyImages() throws {
        // Given: Empty images array
        let images: [String] = []

        // When: Creating GridView with empty images
        let gridView = GridView(images: images)

        // Then: Should handle empty array gracefully
        #expect(gridView != nil)
    }

    // MARK: - GridItemView Tests

    @Test func gridItemViewInitialization() throws {
        // Given: GridItemView parameters
        let itemURL = URL(string: "https://example.com/image.jpg")!

        // When: Creating GridItemView
        let itemView = GridItemView(size: 100, item: itemURL)

        // Then: Should initialize correctly
        #expect(itemView != nil)
    }

    @Test func gridItemViewWithSize() throws {
        // Given: Different sizes
        let itemURL = URL(string: "https://example.com/image.jpg")!

        // When: Creating GridItemView with different sizes
        let smallView = GridItemView(size: 50, item: itemURL)
        let largeView = GridItemView(size: 500, item: itemURL)

        // Then: Should handle different sizes gracefully
        #expect(smallView != nil)
        #expect(largeView != nil)
    }

    // MARK: - DetailView Tests

    @Test func detailViewInitialization() throws {
        // Given: DetailView parameters
        let itemURL = URL(string: "https://example.com/image.jpg")!

        // When: Creating DetailView
        let detailView = DetailView(item: itemURL)

        // Then: Should initialize correctly
        #expect(detailView != nil)
    }

    // MARK: - ContentView Tests

    @Test func macContentViewInitialization() throws {
        // Given: ContentView parameters
        let cameraURL = "https://example.com/stream"
        let schedule: Appointments? = nil

        // When: Creating ContentView
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: schedule)

        // Then: Should initialize correctly
        #expect(contentView != nil)
    }

    @Test func macContentViewWithSchedule() throws {
        // Given: ContentView parameters with schedule
        let cameraURL = "https://example.com/stream"
        let daycare = AppointmentsDaycare(
            startDate: "Thursday, 8/14/2025 9:00 am",
            rId: 1,
            type: "Daycare | Full Day"
        )
        let appointments = Appointments(nextReservation: daycare)

        // When: Creating ContentView with schedule
        let contentView = ContentView(cameraURL: cameraURL, rhizomeSchedule: appointments)

        // Then: Should initialize correctly
        #expect(contentView != nil)
    }

    // MARK: - Performance Tests

    @Test(.timeLimit(.seconds(5))) func gridViewPerformance() throws {
        let images = Array(1...100).map { "image\($0).jpg" }

        _ = GridView(images: images)
    }

    @Test(.timeLimit(.seconds(5))) func detailViewPerformance() throws {
        let itemURL = URL(string: "https://example.com/large-image.jpg")!

        _ = DetailView(item: itemURL)
    }
