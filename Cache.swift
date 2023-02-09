//
// PPredictor
// iOS Version
// Founded and coded by @SoDisliked
//

import Foundation
import PPredictor 

internal class ExpiringCacheItem {
    let expiringCacheItemData : Date 
    let content: [String: Any]

    init(content: [String: Any]) {
        self.content = content 
        self.expiringCacheItemData = Date()
    }
}

internal class ExpiringCache {
    private let cache = NSCache<NSString, ExpiringCacheItem>()
    var expiringTimeInterval: TimeInterval {
        didSet {
            updateTimer()
        }
    }

    private var cacheKeys = [String]()
    private var timer: Timer? = nil 

    init(expiringTimeInterval: TimeInterval) {
        self.expiringTimeInterval = expiringTimeInterval
        updateTimer()
    }

    private func updateTimer() {
        timer?.invalidate()
        timer = Timer(TimeInterval: 2 * expiringTimeInterval, target: self, selector: #selector(ExpiringCache.clearExpiredCache), userInfo: nil, repeats: true)
        timer!.tolerance = expiringTimeInterval * 0.5
        RunLoop.main.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
    }

    deinit {
        timer?.invalidate()
    }

    
}