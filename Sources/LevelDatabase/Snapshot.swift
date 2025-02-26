import leveldb

open class Snapshot {
    var pointer: OpaquePointer?
    let database: LevelDB

    init(_ database: LevelDB) {
        self.database = database
        pointer = leveldb_create_snapshot(database.database)
    }

    deinit {
        leveldb_release_snapshot(database.database, pointer)
    }
}
