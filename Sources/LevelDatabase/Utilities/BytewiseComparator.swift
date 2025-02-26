import LibC
import Sorting

internal struct BytewiseComparator: SortComparator {
    public var order: SortOrder = .forward
    
    public func compare(_ lhs: any Slice, _ rhs: any Slice) -> ComparisonResult {
        lhs.slice({ lhsPointer, lhsCount in
            rhs.slice({ rhsPointer, rhsCount in
                var cmp = memcmp(lhsPointer, rhsPointer, min(lhsCount, rhsCount))
                
                if cmp == 0 {
                    cmp = Int32(lhsCount - rhsCount)
                }
                
                return ComparisonResult(rawValue: (cmp < 0) ? -1 : (cmp > 0) ? 1 : 0)!
            })
        })
    }
}
