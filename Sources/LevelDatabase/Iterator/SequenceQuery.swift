internal struct SequenceQuery {
    public let database: LevelDB
    public let start: (any Slice)?
    public let end: (any Slice)?
    public let descending: Bool
    public let options: ReadOptions
    
    public init(
        database: LevelDB,
        start: (any Slice)? = nil,
        end: (any Slice)? = nil,
        descending: Bool = false,
        options: [ReadOption] = .standard
    ) {
        self.database = database
        self.start = start
        self.end = end
        self.descending = descending
        self.options = ReadOptions(options: options)
    }
}
