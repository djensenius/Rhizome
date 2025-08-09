//
//  GalleryTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest
import SwiftUI
@testable import Rhizome

final class GalleryTests: XCTestCase {

    func testGalleryInitializationWithEmptyImages() throws {
        // Given: Empty images array
        let images: [String] = []
        
        // When: Creating Gallery
        let gallery = Gallery(images: images)
        
        // Then: Should initialize correctly
        XCTAssertEqual(gallery.images.count, 0)
        XCTAssertEqual(gallery.currentIndex, 0)
    }
    
    func testGalleryInitializationWithImages() throws {
        // Given: Images array
        let images = ["image1.jpg", "image2.jpg", "image3.jpg"]
        
        // When: Creating Gallery
        let gallery = Gallery(images: images)
        
        // Then: Should initialize correctly
        XCTAssertEqual(gallery.images.count, 3)
        XCTAssertEqual(gallery.images[0], "image1.jpg")
        XCTAssertEqual(gallery.images[1], "image2.jpg")
        XCTAssertEqual(gallery.images[2], "image3.jpg")
        XCTAssertEqual(gallery.currentIndex, 0)
    }
    
    func testGalleryWithSingleImage() throws {
        // Given: Single image
        let images = ["single-image.jpg"]
        
        // When: Creating Gallery
        let gallery = Gallery(images: images)
        
        // Then: Should handle single image correctly
        XCTAssertEqual(gallery.images.count, 1)
        XCTAssertEqual(gallery.images[0], "single-image.jpg")
        XCTAssertEqual(gallery.currentIndex, 0)
    }
    
    func testGalleryWithLargeImageArray() throws {
        // Given: Large images array
        let images = Array(1...100).map { "image\($0).jpg" }
        
        // When: Creating Gallery
        let gallery = Gallery(images: images)
        
        // Then: Should handle large array correctly
        XCTAssertEqual(gallery.images.count, 100)
        XCTAssertEqual(gallery.images[0], "image1.jpg")
        XCTAssertEqual(gallery.images[99], "image100.jpg")
        XCTAssertEqual(gallery.currentIndex, 0)
    }
    
    // MARK: - View Extension Tests
    
    func testFramedAspectRatioExtension() throws {
        // Given: Image view
        let imageView = Image(systemName: "photo")
        
        // When: Applying framedAspectRatio
        let framedView = imageView.framedAspectRatio(contentMode: .fit)
        
        // Then: Should not crash and return modified view
        XCTAssertNotNil(framedView)
    }
    
    func testFixedAspectRatioExtension() throws {
        // Given: Any view
        let anyView = Text("Test")
        
        // When: Applying fixedAspectRatio
        let fixedView = anyView.fixedAspectRatio(1.0, contentMode: .fit)
        
        // Then: Should not crash and return modified view
        XCTAssertNotNil(fixedView)
    }
    
    func testFixedAspectRatioWithNilAspect() throws {
        // Given: Any view
        let anyView = Rectangle()
        
        // When: Applying fixedAspectRatio with nil aspect
        let fixedView = anyView.fixedAspectRatio(nil, contentMode: .fill)
        
        // Then: Should handle nil aspect correctly
        XCTAssertNotNil(fixedView)
    }
    
    // MARK: - Performance Tests
    
    func testGalleryInitializationPerformance() throws {
        let images = Array(1...50).map { "image\($0).jpg" }
        
        measure {
            let _ = Gallery(images: images)
        }
    }
    
    func testLargeImageArrayPerformance() throws {
        measure {
            let images = Array(1...1000).map { "image\($0).jpg" }
            let _ = Gallery(images: images)
        }
    }
    
    // MARK: - Edge Cases
    
    func testGalleryWithInvalidImageURLs() throws {
        // Given: Images with potentially invalid URLs
        let images = ["", "invalid-url", "http://", "not-a-url"]
        
        // When: Creating Gallery
        let gallery = Gallery(images: images)
        
        // Then: Should handle invalid URLs gracefully
        XCTAssertEqual(gallery.images.count, 4)
        XCTAssertEqual(gallery.currentIndex, 0)
    }
    
    func testGalleryWithVeryLongImageURLs() throws {
        // Given: Very long image URLs
        let longURL = String(repeating: "a", count: 1000) + ".jpg"
        let images = [longURL]
        
        // When: Creating Gallery
        let gallery = Gallery(images: images)
        
        // Then: Should handle long URLs
        XCTAssertEqual(gallery.images.count, 1)
        XCTAssertEqual(gallery.images[0], longURL)
    }
    
    func testGalleryWithSpecialCharacters() throws {
        // Given: Image URLs with special characters
        let images = [
            "image with spaces.jpg",
            "image+with+plus.jpg",
            "image%20encoded.jpg",
            "image-with-unicode-🐕.jpg"
        ]
        
        // When: Creating Gallery
        let gallery = Gallery(images: images)
        
        // Then: Should handle special characters
        XCTAssertEqual(gallery.images.count, 4)
        XCTAssertTrue(gallery.images.contains("image with spaces.jpg"))
        XCTAssertTrue(gallery.images.contains("image-with-unicode-🐕.jpg"))
    }
}