import leveldb

internal protocol Option {
    func set(options: OpaquePointer)
}

internal protocol Options: AnyObject {
    associatedtype OptionType: Option
    
    init(options: [OptionType])
    
    var pointer: OpaquePointer { get }
}

public enum FileOption: Option {
    case createIfMissing(Bool)
    case errorIfExists(Bool)
    case paranoidChecks(Bool)
    case writeBufferSize(Int)
    case maxOpenFiles(Int)
    case blockSize(Int)
    case blockRestartInterval(Int)
    case compression(CompressionType)
    
    internal func set(options: OpaquePointer) {
        switch self {
        case .createIfMissing(let enabled):
            leveldb_options_set_create_if_missing(options, enabled ? 1 : 0)
            
        case .errorIfExists(let enabled):
            leveldb_options_set_error_if_exists(options, enabled ? 1 : 0)
            
        case .paranoidChecks(let enabled):
            leveldb_options_set_paranoid_checks(options, enabled ? 1 : 0)
            
        case .writeBufferSize(let size):
            leveldb_options_set_write_buffer_size(options, Int(size))
            
        case .maxOpenFiles(let files):
            leveldb_options_set_max_open_files(options, Int32(files))
            
        case .blockSize(let size):
            leveldb_options_set_block_size(options, Int(size))
            
        case .blockRestartInterval(let interval):
            leveldb_options_set_block_restart_interval(options, Int32(interval))
            
        case .compression(let type):
            leveldb_options_set_compression(options, Int32(type.rawValue))
        }
    }
}

public extension FileOption {
    enum CompressionType: Int {
        case none = 0
        case snappy
    }
}

internal final class FileOptions: Options {
    public let pointer: OpaquePointer
    
    public init(options: [FileOption]) {
        self.pointer = leveldb_options_create()
        options.forEach { $0.set(options: pointer) }
    }
    
    deinit {
        leveldb_options_destroy(pointer)
    }
}

public enum ReadOption: Option {
    case verifyChecksums(Bool)
    case fillCache(Bool)
    case snapshot(Snapshot)
    
    internal func set(options: OpaquePointer) {
        switch self {
        case .verifyChecksums(let enabled):
            leveldb_readoptions_set_verify_checksums(options, enabled ? 1 : 0)
            
        case .fillCache(let enabled):
            leveldb_readoptions_set_fill_cache(options, enabled ? 1 : 0)
            
        case .snapshot(let snapshot):
            leveldb_readoptions_set_snapshot(options, snapshot.pointer)
        }
    }
}

internal final class ReadOptions: Options {
    public let pointer: OpaquePointer
    
    public init(options: [ReadOption]) {
        self.pointer = leveldb_readoptions_create()
        options.forEach { $0.set(options: pointer) }
    }
    
    deinit {
        leveldb_readoptions_destroy(pointer)
    }
}

public enum WriteOption: Option {
    case sync(Bool)
    
    internal func set(options: OpaquePointer) {
        switch self {
        case .sync(let enabled):
            leveldb_writeoptions_set_sync(options, enabled ? 1 : 0)
        }
    }
}

internal final class WriteOptions: Options {
    public let pointer: OpaquePointer
    
    public init(options: [WriteOption]) {
        self.pointer = leveldb_writeoptions_create()
        options.forEach { $0.set(options: pointer) }
    }
    
    deinit {
        leveldb_writeoptions_destroy(pointer)
    }
}
