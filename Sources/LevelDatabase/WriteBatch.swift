import leveldb

open class WriteBatch {
    internal let writebatch: OpaquePointer

    public init() {
        self.writebatch = leveldb_writebatch_create()
    }

    deinit {
        leveldb_writebatch_destroy(writebatch)
    }

    open func put(_ key: any Slice, value: (any Slice)?) {
        key.slice({ pointer, count in
            if let value = value {
                value.slice({ buffer, length in
                    leveldb_writebatch_put(writebatch, pointer, count, buffer, length)
                })
            } else {
                leveldb_writebatch_put(writebatch, pointer, count, nil, 0)
            }
        })
    }

    open func delete(_ key: any Slice) {
        key.slice({ pointer, count in
            leveldb_writebatch_delete(writebatch, pointer, count)
        })
    }

    open func clear() {
        leveldb_writebatch_clear(writebatch)
    }
}
