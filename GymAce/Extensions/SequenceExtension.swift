import Foundation

extension Sequence {
    /// Return a new array that satisfies the predicate and a new array that doesn't.
    func split(by predicate: (Element) -> Bool) -> (matching: [Element], nonMatching: [Element]) {
        return reduce(into: ([], [])) { result, element in
            if predicate(element) {
                result.0.append(element)
            } else {
                result.1.append(element)
            }
        }
    }
}

