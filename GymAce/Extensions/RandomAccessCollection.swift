enum Location<Index> {
    /// The element was found at this index.
    case found(Index)

    /// The element was not found but can be inserted while keeping the collection sorted..
    case missing(Index)
}

extension RandomAccessCollection where Element: Comparable {
    func binarySearch(_ element: Element) -> Location<Index> {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            if self[mid] < element {
                low = index(after: mid)
            } else {
                high = mid
            }
        }

        if self.indices.contains(low) && self[low] == element {  // need contains check in case self is empty
            return .found(low)
        } else {
            return .missing(low)
        }
    }
}
