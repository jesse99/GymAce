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

    func findDupes(using: (Element) -> String) -> [String] {
        var dupes: Set<String> = Set()
        var names: Set<String> = Set()
        for entry in self {
            let name = using(entry)
            if names.contains(name) {
                dupes.insert(name)
            } else {
                names.insert(name)
            }
        }
        return Array(dupes)
    }
}

