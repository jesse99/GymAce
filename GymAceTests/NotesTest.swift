import Foundation
import SwiftUI
import Testing
@testable import GymAce

fileprivate var valid = false
fileprivate var urls: [String: [URL]] = [:]

struct NotesTests {
    @Test("Notes")
    func notes() {
        valid = true
        urls = [:]
        _ = Notes(self.validateNote)
        #expect(valid)

        var codes: [(URL, Int)] = []
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            codes = await validateURLs()
            for (url, code) in codes {
                print("\(url) returned code \(code)")
            }
            semaphore.signal()
        }
        semaphore.wait()
        #expect(codes.isEmpty)
    }
    
    private func validateNote(_ name: String, _ lines: [String], _ links: [(String, String)]) {
        for (_, urlStr) in links {
            if let url = URL(string: urlStr) {
                if let host = url.host() {
                    urls[host, default: []].append(url)
                } else {
                    print("'\(urlStr)' has no host")
                    valid = false
                }
            } else {
                print("'\(urlStr)' isn't a valid URL")
                valid = false
            }
        }

        let checker = UITextChecker()
        UITextChecker.learnWord("barbend.com")
        UITextChecker.learnWord("bodyweightfitness")
        UITextChecker.learnWord("dumbbell-romanian")
        UITextChecker.learnWord("experiencelife.com")
        UITextChecker.learnWord("greatist.com")
        UITextChecker.learnWord("lipsticklifters.com")
        UITextChecker.learnWord("pullup")
        UITextChecker.learnWord("qNLiCX8gYWo")
        UITextChecker.learnWord("squatuniversity.com")
        UITextChecker.learnWord("stronglifts.com")
        UITextChecker.learnWord("strengtheory.com")
        UITextChecker.learnWord("unrack")
        UITextChecker.learnWord("www.crossfit.com")
        UITextChecker.learnWord("www.livestrong.com")
        UITextChecker.learnWord("www.menshealth.com")
        UITextChecker.learnWord("www.nasm.org")
        UITextChecker.learnWord("www.verywellfit.com")

        for line in lines {
            if let word = validateSpelling(checker, text: line), !word.isEmpty {
                print("'\(name)' has mis-spelled '\(word)'")
                valid = false
            }
        }
    }
}

// To speed things up we'll process these in parallel using the cooperative thread pool.
// Unfortunately I think some sites rate limit requests so we'll wait a bit before
// contacting the same host again.
fileprivate func validateURLs() async -> [(URL, Int)] {
    await withTaskGroup(of: [(URL, Int)].self) {group in
        var results: [(URL, Int)] = []
        for (_, urlList) in urls {
            group.addTask(priority: .userInitiated) {
                return await validateHostURLs(urlList)
            }
        }
        
        for await result in group {
            results.append(contentsOf: result)
        }
        return results
    }
}

fileprivate func validateHostURLs(_ urls: [URL]) async -> [(URL, Int)] {
    var result: [(URL, Int)] = []
    do {
        for (i, url) in urls.enumerated() {
            if let code = await validateURL(url) {
//                print("checking \(url.host()!):\(i) for \(url) which returned \(code)")
                result.append((url, code))
//           } else {
//               print("checking \(url.host()!):\(i) for \(url) which was OK")
            }
            if i > 0 && i < urls.count {
                try await Task.sleep(for: .seconds(5))
            }
        }
    } catch {
        print("sleep failed?")
    }
    return result
}

fileprivate func validateURL(_ url: URL) async -> Int? {
    guard url.host() != "www.bodybuilding.com" else {
        // Most of the www.bodybuilding.com aren't dead but they also now point to lame advertising.
        return 404
    }

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
