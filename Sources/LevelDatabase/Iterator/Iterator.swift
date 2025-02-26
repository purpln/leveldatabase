import leveldb

internal final class LevelDBIterator {
    private let iterator: OpaquePointer?
    
    public init(query: SequenceQuery) {
        self.iterator = leveldb_create_iterator(query.database.database, query.options.pointer)
        
        if query.descending {
            seekToLast()
        } else {
            seekToFirst()
        }
    }
    
    deinit {
        leveldb_iter_destroy(iterator)
    }
}

internal extension LevelDBIterator {
    var isValid: Bool {
        leveldb_iter_valid(iterator) != 0
    }
    
    func seek(_ key: any Slice) {
        key.slice { pointer, count in
            leveldb_iter_seek(iterator, pointer, count)
        }
    }
    
    func seekToFirst() {
        leveldb_iter_seek_to_first(iterator)
    }
    
    func seekToLast() {
        leveldb_iter_seek_to_last(iterator)
    }
    
    func move(descending: Bool) {
        if descending {
            leveldb_iter_prev(iterator)
        } else {
            leveldb_iter_next(iterator)
        }
    }
    
    var key: (pointer: UnsafePointer<Int8>, length: Int)? {
        var length: Int = 0
        let pointer = leveldb_iter_key(iterator, &length)
        
        guard length > 0, let pointer = pointer else { return nil }
        
        return (pointer, length)
    }
    
    var value: (pointer: UnsafePointer<Int8>, length: Int)? {
        var length: Int = 0
        let pointer = leveldb_iter_value(iterator, &length)
        
        guard length > 0, let pointer = pointer else { return nil }
        
        return (pointer, length)
    }
    
    var error: String? {
        var error: UnsafeMutablePointer<Int8>? = nil
        leveldb_iter_get_error(iterator, &error)
        if let error = error {
            return String(cString: error)
        } else {
            return nil
        }
    }
}
