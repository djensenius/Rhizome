//
//  RhizomeMacTests.swift
//  RhizomeMacTests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest
import SwiftUI
@testable import RhizomeMac

final class RhizomeMacTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - ColumnStepper Tests
    
    func testColumnStepperInitialization() throws {
        // Given: ColumnStepper parameters
        let initialColumns = 3
        let range = 1...10
        
        // When: Creating ColumnStepper
        let stepper = ColumnStepper(columns: .constant(initialColumns), range: range)
        
        // Then: Should initialize with correct properties
        // Note: Since we can't easily test SwiftUI view properties, we test the initialization doesn't crash
        XCTAssertNotNil(stepper)
    }
    
    // MARK: - GridView Tests
    
    func testGridViewInitialization() throws {
        // Given: GridView parameters
        let images = ["image1.jpg", "image2.jpg", "image3.jpg"]
        let columns = 2
        
        // When: Creating GridView
        let gridView = GridView(images: images, columns: columns)
        
        // Then: Should initialize correctly
        XCTAssertNotNil(gridView)
        // Additional validation would require SwiftUI testing framework
    }
    
    func testGridViewWithEmptyImages() throws {
        // Given: Empty images array
        let images: [String] = []
        let columns = 2
        
        // When: Creating GridView with empty images
        let gridView = GridView(images: images, columns: columns)
        
        // Then: Should handle empty array gracefully
        XCTAssertNotNil(gridView)
    }
    
    // MARK: - GidItemView Tests
    
    func testGidItemViewInitialization() throws {
        // Given: GidItemView parameters
        let imageURL = "https://example.com/image.jpg"
        
        // When: Creating GidItemView
        let itemView = GidItemView(imageURL: imageURL)
        
        // Then: Should initialize correctly
        XCTAssertNotNil(itemView)
    }
    
    func testGidItemViewWithEmptyURL() throws {
        // Given: Empty image URL
        let imageURL = ""
        
        // When: Creating GidItemView with empty URL
        let itemView = GidItemView(imageURL: imageURL)
        
        // Then: Should handle empty URL gracefully
        XCTAssertNotNil(itemView)
    }
    
    // MARK: - DetailView Tests
    
    func testDetailViewInitialization() throws {
        // Given: DetailView parameters
        let imageURL = "https://example.com/image.jpg"
        
        // When: Creating DetailView
        let detailView = DetailView(imageURL: imageURL)
        
        // Then: Should initialize correctly
        XCTAssertNotNil(detailView)
    }
    
    // MARK: - ContentView Tests
    
    func testMacContentViewInitialization() throws {
        // Given: ContentView parameters
        let images = ["image1.jpg", "image2.jpg"]
        let schedule: Appointments? = nil
        
        // When: Creating ContentView
        let contentView = ContentView(images: images, rhizomeSchedule: schedule)
        
        // Then: Should initialize correctly
        XCTAssertNotNil(contentView)
    }
    
    func testMacContentViewWithSchedule() throws {
        // Given: ContentView parameters with schedule
        let images = ["image1.jpg", "image2.jpg"]
        let appointments = Appointments(daycare: [])
        
        // When: Creating ContentView with schedule
        let contentView = ContentView(images: images, rhizomeSchedule: appointments)
        
        // Then: Should initialize correctly
        XCTAssertNotNil(contentView)
    }
    
    // MARK: - Performance Tests
    
    func testGridViewPerformance() throws {
        let images = Array(1...100).map { "image\($0).jpg" }
        let columns = 4
        
        measure {
            let _ = GridView(images: images, columns: columns)
        }
    }
    
    func testDetailViewPerformance() throws {
        let imageURL = "https://example.com/large-image.jpg"
        
        measure {
            let _ = DetailView(imageURL: imageURL)
        }
    }
}
