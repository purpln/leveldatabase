public protocol Slice: Equatable {
    func slice<T>(_ handler: (UnsafePointer<Int8>, Int) -> T) -> T
    static func create(with pointer: UnsafePointer<Int8>, length: Int) -> Self?
}

extension Array: Slice where Element == UInt8 {
    public func slice<T>(_ handler: (UnsafePointer<Int8>, Int) -> T) -> T {
        withUnsafeBytes({
            handler($0.baseAddress!.assumingMemoryBound(to: Int8.self), $0.count)
        })
    }
    
    public static func create(with pointer: UnsafePointer<Int8>, length: Int) -> [UInt8]? {
        let pointer = UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: pointer, count: length)
        return Array(buffer)
    }
}

extension String: Slice {
    public func slice<T>(_ handler: (UnsafePointer<Int8>, Int) -> T) -> T {
        withCString({
            handler($0, count)
        })
    }
    
    public static func create(with pointer: UnsafePointer<Int8>, length: Int) -> String? {
        let pointer = UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: pointer, count: length)
        return String(decoding: buffer, as: UTF8.self)
    }
}
