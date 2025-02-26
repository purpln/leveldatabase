public enum LevelDBError: Error {
    case undefinedError
    case openError(message: String)
    case destroyError(message: String)
    case repairError(message: String)
    case readError(message: String)
    case writeError(message: String)
}

extension LevelDBError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .undefinedError:
            return "undefined"
        case .openError(let message):
            return "open: \(message)"
        case .destroyError(let message):
            return "destroy: \(message)"
        case .repairError(let message):
            return "repair: \(message)"
        case .readError(let message):
            return "read: \(message)"
        case .writeError(let message):
            return "write: \(message)"
        }
    }
}

internal func result<T>(error convertion: (String) -> LevelDBError, _ handle: (inout UnsafeMutablePointer<Int8>?) -> T?) throws(LevelDBError) -> T {
    var error: UnsafeMutablePointer<Int8>? = nil
    guard let value = handle(&error) else {
        if let error = error {
            let description = String(cString: error)
            throw convertion(description)
        } else {
            throw .undefinedError
        }
    }
    return value
}

