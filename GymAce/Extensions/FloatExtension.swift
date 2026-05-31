import Foundation

extension Float {
    /// Returns true if the two weights are the same to three decimal places.
    func sameWeight(_ rhs: Float) -> Bool {
        return Int(1000*self) == Int(1000*rhs)
    }
}
