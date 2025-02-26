import leveldb
import Sorting

public final class LevelDB {
    public typealias BatchUpdate = (WriteBatch) throws -> Void
    
    internal typealias Comparator = any SortComparator<any Slice>
    internal let database: OpaquePointer
    internal let comparator: Comparator
    
    internal init(database: OpaquePointer, comparator: Comparator = BytewiseComparator()) {
        self.database = database
        self.comparator = comparator
    }
    
    deinit {
        leveldb_close(database)
    }
}

public extension LevelDB {
    static func open(
        path: String,
        options: [FileOption] = .standard
    ) throws -> LevelDB {
        let options = FileOptions(options: options)
        
        let database = try result(error: { .openError(message: $0) }) { error in
            leveldb_open(options.pointer, path, &error)
        }
        return LevelDB(database: database)
    }
    
    static func destroy(
        path: String,
        options: [FileOption] = .standard
    ) throws {
        let options = FileOptions(options: options)
        
        try result(error: { .destroyError(message: $0) }, { error in
            leveldb_destroy_db(options.pointer, path, &error)
        })
    }
    
    static func repair(
        path: String,
        options: [FileOption] = .standard
    ) throws {
        let options = FileOptions(options: options)
        
        try result(error: { .repairError(message: $0) }, { error in
            leveldb_repair_db(options.pointer, path, &error)
        })
    }
}

public extension LevelDB {
    func get<Value: Slice>(_ key: any Slice, options: [ReadOption] = .standard) throws -> Value? {
        let options = ReadOptions(options: options)
        
        var length: Int = 0
        
        let pointer = try result(error: { .readError(message: $0) }, { error in
            key.slice({ pointer, count in
                leveldb_get(database, options.pointer, pointer, count, &length, &error)
            })
        })
        
        return Value.create(with: pointer, length: length)
    }
    
    func put(_ key: any Slice, value: (any Slice)?, options: [WriteOption] = .standard) throws {
        let options = WriteOptions(options: options)
        
        try result(error: { .writeError(message: $0) }, { error in
            key.slice({ pointer, count in
                if let value = value {
                    value.slice({ buffer, length in
                        leveldb_put(database, options.pointer, pointer, count, buffer, length, &error)
                    })
                } else {
                    leveldb_put(database, options.pointer, pointer, count, nil, 0, &error)
                }
            })
        })
    }
    
    func delete(_ key: any Slice, options: [WriteOption] = .standard) throws {
        let options = WriteOptions(options: options)
        
        try result(error: { .writeError(message: $0) }, { error in
            key.slice({ pointer, count in
                leveldb_delete(database, options.pointer, pointer, count, &error)
            })
        })
    }
    
    func write(options: [WriteOption] = .standard, _ update: BatchUpdate) throws {
        let writebatch = WriteBatch()
        try update(writebatch)
        
        let options = WriteOptions(options: options)
        
        try result(error: { .writeError(message: $0) }, { error in
            leveldb_write(database, options.pointer, writebatch.writebatch, &error)
        })
    }
}

public extension LevelDB {
    func keys<Key: Slice>(
        from: (any Slice)? = nil,
        to: (any Slice)? = nil,
        descending: Bool = false
    ) -> KeySequence<Key> {
        let query = SequenceQuery(database: self, start: from, end: to, descending: descending)
        return KeySequence(query: query)
    }
    
    func values<Key: Slice, Value: Slice>(
        from: (any Slice)? = nil,
        to: (any Slice)? = nil,
        descending: Bool = false
    ) -> KeyValueSequence<Key, Value> {
        let query = SequenceQuery(database: self, start: from, end: to, descending: descending)
        return KeyValueSequence(query: query)
    }
}

public extension LevelDB {
    static var majorVersion: Int {
        Int(leveldb_major_version())
    }
    
    static var minorVersion: Int {
        Int(leveldb_minor_version())
    }
    
    static var version: String {
        "\(majorVersion).\(minorVersion)"
    }
}

public extension LevelDB {
    subscript<Value: Slice>(key: any Slice) -> Value? {
        get { try? get(key) }
        set { try? put(key, value: newValue) }
    }
}
