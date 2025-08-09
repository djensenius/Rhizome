//
//  GalleryTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import SwiftUI
@testable import Rhizome

@Test func galleryInitializationWithEmptyImages() throws {
    // Given: Empty images array
    let images: [String] = []
    
    // When: Creating Gallery
    let gallery = Gallery(images: images)
    
    // Then: Should initialize correctly
    #expect(gallery.images.count == 0)
    #expect(gallery.currentIndex == 0)
}

@Test func galleryInitializationWithImages() throws {
    // Given: Images array
    let images = ["image1.jpg", "image2.jpg", "image3.jpg"]
    
    // When: Creating Gallery
        let gallery = Gallery(images: images)
    // Then: Should initialize correctly
    #expect(gallery.images.count == 3)
    #expect(gallery.images[0] == "image1.jpg")
    #expect(gallery.images[1] == "image2.jpg")
    #expect(gallery.images[2] == "image3.jpg")
    #expect(gallery.currentIndex == 0)
}

@Test func galleryWithSingleImage() throws {
    // Given: Single image
    let images = ["single-image.jpg"]
    
    // When: Creating Gallery
    let gallery = Gallery(images: images)
    
    // Then: Should handle single image correctly
    #expect(gallery.images.count == 1)
    #expect(gallery.images[0] == "single-image.jpg")
    #expect(gallery.currentIndex == 0)
}

@Test func galleryWithLargeImageArray() throws {
    // Given: Large images array
    let images = Array(1...100).map { "image\($0).jpg" }
    
    // When: Creating Gallery
    let gallery = Gallery(images: images)
    
    // Then: Should handle large array correctly
    #expect(gallery.images.count == 100)
        #expect(gallery.images[0] == "image1.jpg")
        #expect(gallery.images[99] == "image100.jpg")
        #expect(gallery.currentIndex == 0)
    }
    
// MARK: - View Extension Tests

@Test func framedAspectRatioExtension() throws {
    // Given: Image view
    let imageView = Image(systemName: "photo")
    
    // When: Applying framedAspectRatio
    let framedView = imageView.framedAspectRatio(contentMode: .fit)
    
    // Then: Should not crash and return modified view
    #expect(framedView != nil)
}

@Test func fixedAspectRatioExtension() throws {
    // Given: Any view
    let anyView = Text("Test")
    
    // When: Applying fixedAspectRatio
    let fixedView = anyView.fixedAspectRatio(1.0, contentMode: .fit)
    
    // Then: Should not crash and return modified view
    #expect(fixedView != nil)
}

@Test func fixedAspectRatioWithNilAspect() throws {
    // Given: Any view
    let anyView = Rectangle()
    
    // When: Applying fixedAspectRatio with nil aspect
    let fixedView = anyView.fixedAspectRatio(nil, contentMode: .fill)
    
    // Then: Should handle nil aspect correctly
    #expect(fixedView != nil)
}
// MARK: - Performance Tests

@Test(.timeLimit(.seconds(5))) func galleryInitializationPerformance() throws {
    let images = Array(1...50).map { "image\($0).jpg" }
    let _ = Gallery(images: images)
}

@Test(.timeLimit(.seconds(5))) func largeImageArrayPerformance() throws {
    let images = Array(1...1000).map { "image\($0).jpg" }
    let _ = Gallery(images: images)
}

// MARK: - Edge Cases

@Test func galleryWithInvalidImageURLs() throws {
    // Given: Images with potentially invalid URLs
    let images = ["", "invalid-url", "http://", "not-a-url"]
    
    // When: Creating Gallery
    let gallery = Gallery(images: images)
    
    // Then: Should handle invalid URLs gracefully
    #expect(gallery.images.count == 4)
    #expect(gallery.currentIndex == 0)
}

@Test func galleryWithVeryLongImageURLs() throws {
    // Given: Very long image URLs
    let longURL = String(repeating: "a", count: 1000) + ".jpg"
    let images = [longURL]
    
    // When: Creating Gallery
    let gallery = Gallery(images: images)
    
    // Then: Should handle long URLs
    #expect(gallery.images.count == 1)
        #expect(gallery.images[0] == longURL)
    }

@Test func galleryWithSpecialCharacters() throws {
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
    #expect(gallery.images.count == 4)
    #expect(gallery.images.contains("image with spaces.jpg"))
    #expect(gallery.images.contains("image-with-unicode-🐕.jpg"))
}