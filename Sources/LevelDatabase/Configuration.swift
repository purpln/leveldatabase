internal extension Array where Element == FileOption {
    @inlinable
    static var standard: [FileOption] {
        [
            .writeBufferSize(1024 * 1024 * 4),
            .maxOpenFiles(1000),
            .blockSize(1024 * 4),
            .blockRestartInterval(16),
            .compression(.snappy)
        ]
    }
}

internal extension Array where Element == ReadOption {
    @inlinable
    static var standard: [ReadOption] {
        [
            .fillCache(true),
        ]
    }
}

internal extension Array where Element == WriteOption {
    @inlinable
    static var standard: [WriteOption] {
        []
    }
}
