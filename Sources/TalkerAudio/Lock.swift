
import Foundation


public class Lock<T>: @unchecked Sendable {
    private var data: T
    private let lock = NSLock()

    init(_ data: T) {
        self.data = data
    }
    
    public var value: T {
        get {
            lock.withLock {
                return data
            }
        }
        set {
            lock.withLock {
                data = newValue
            }
        }
    }

    public func withLock<R>(_ block: (inout T) throws -> R) rethrows -> R {
        try lock.withLock {
            return try block(&data)
        }
    }
}
