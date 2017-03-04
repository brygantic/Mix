// Adapted from: https://github.com/raywenderlich/swift-algorithm-club/tree/master/Queue

public class Queue<T> : ReadOnlyQueue<T> {
    public func enqueue(_ element: T) {
        array.append(element)
    }
    
    public func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
}

public class ReadOnlyQueue<T> {
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public var front: T? {
        return array.first
    }
    
    public func getElements() -> [T] {
        // Arrays are value types in Swift!
        return array
    }
}
