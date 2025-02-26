public struct KeyValueSequence<Key: Slice, Value: Slice>: Sequence {
    public typealias Iterator = AnyIterator<(Key, Value?)>
    private let query: SequenceQuery
    
    internal init(query: SequenceQuery) {
        self.query = query
    }
    
    public func makeIterator() -> Iterator {
        let iterator = LevelDBIterator(query: query)
        
        return AnyIterator({
            guard iterator.isValid,
                  let (pointer, length) = iterator.key,
                  let key = Key.create(with: pointer, length: length) else { return nil }
            
            if let end = query.end {
                let result = query.database.comparator.compare(key, end)
                if !query.descending && result == .orderedDescending
                    || query.descending && result == .orderedAscending {
                    return nil
                }
            }
            
            defer {
                iterator.move(descending: query.descending)
            }
            
            let value: Value?
            
            if let (pointer, length) = iterator.value {
                value = .create(with: pointer, length: length)
            } else {
                value = nil
            }
            
            return (key, value)
        })
    }
}
