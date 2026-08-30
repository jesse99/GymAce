import Foundation
import SwiftUI
import Testing
@testable import GymAce

fileprivate var valid = false

struct NotesTests {
    @Test("Notes")
    func notes() {
        valid = true
        _ = Notes(self.validateNote)
        #expect(valid)
    }
    
    private func validateNote(_ name: String, _ lines: [String], _ links: [(String, String)]) {
        for (_, url) in links {
            Task {
                if let code = await validateURL(url) {
                    print("\(name) \(url) returned status code \(code)")
                    valid = false
                }
            }
        }

        let checker = UITextChecker()
        UITextChecker.learnWord("barbend.com")
        UITextChecker.learnWord("experiencelife.com")
        UITextChecker.learnWord("greatist.com")
        UITextChecker.learnWord("lipsticklifters.com")
        UITextChecker.learnWord("stronglifts.com")
        UITextChecker.learnWord("strengtheory.com")
        UITextChecker.learnWord("greatist.com")
        UITextChecker.learnWord("www.livestrong.com")
        UITextChecker.learnWord("www.nasm.org")
        UITextChecker.learnWord("www.verywellfit.com")
        UITextChecker.learnWord("dumbbell-romanian")
        UITextChecker.learnWord("unrack")
        for line in lines {
            if let word = validateSpelling(checker, text: line), !word.isEmpty {
                print("\(name) has mis-spelled '\(word)'")
                valid = false
            }
        }
    }
}

fileprivate func validateURL(_ urlString: String) async -> Int? {
    guard let url = URL(string: urlString) else { return 800 }
    
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD" // Fast: Requests only response metadata
    request.timeoutInterval = 5.0 // Prevent long-running hangs
    
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if (200...299).contains(httpResponse.statusCode) {
                return nil
            } else {
                return httpResponse.statusCode
            }
        }
        return 600  // custom code
    } catch {
        // Network error, timeout, or server offline
        return 700  // custom code
    }
}

fileprivate func validateSpelling(_ checker: UITextChecker, text: String) -> String? {
    let range = NSRange(location: 0, length: text.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: text, range: range, startingAt: 0, wrap: false, language: "en")

    if misspelledRange.location == NSNotFound {
        return nil
    } else {
        if let swiftRange = Range(misspelledRange, in: text) {
            return String(text[swiftRange])
        }
        return nil
    }
}
