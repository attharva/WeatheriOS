//
//  LocationManager.swift
//  iOSWeather
//
//  Created by Atharva Kulkarni on 12/10/24.
//

import UIKit

actor ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private var cache: NSCache<NSString, CacheItem> = NSCache()
    
    // Make the initializer private to enforce the singleton pattern
    private init() {
        // Optional: Configure cache limits if needed
        cache.countLimit = 100 // Max 100 images in cache
    }
    
    // CacheItem stores both the image and the timestamp
    private class CacheItem {
        let image: UIImage
        let timestamp: Date
        
        init(image: UIImage, timestamp: Date = Date()) {
            self.image = image
            self.timestamp = timestamp
        }
    }
    
    // Fetch image from cache or download it if not available
    func fetchImage(from url: URL) async throws -> UIImage? {
        let urlString = url.absoluteString as NSString
        
        // If image is already cached, return it immediately
        if let cachedItem = cache.object(forKey: urlString) {
            if !isCacheItemExpired(cachedItem) {
                //                print("Returning cached image for URL: \(urlString)")
                return cachedItem.image
            } else {
                //                print("Image expired for URL: \(urlString), removing from cache")
                cache.removeObject(forKey: urlString) // Remove expired item
            }
        }
        
        //        print("Fetching image from network for URL: \(urlString)")
        //        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds delay for testing
        
        // Download the image
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        
        // Cache the image with the current timestamp
        let cacheItem = CacheItem(image: image)
        cache.setObject(cacheItem, forKey: urlString)
        //        print("Image downloaded and cached for URL: \(urlString)")
        return image
    }
    
    // Determine if a cached item has expired (e.g., after 1 day)
    private func isCacheItemExpired(_ cacheItem: CacheItem) -> Bool {
        let expirationTime: TimeInterval = 86400 // 24 hours (in seconds)
        let expired = Date().timeIntervalSince(cacheItem.timestamp) > expirationTime
        if expired {
            //            print("Cache item expired. It was cached on: \(cacheItem.timestamp)")
        }
        return expired
    }
    
    // Clear the entire cache (can be called manually if needed)
    func clearCache() {
        //        print("Clearing entire cache")
        cache.removeAllObjects()
    }
}
