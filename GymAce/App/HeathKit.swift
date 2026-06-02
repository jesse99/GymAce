import Foundation
import HealthKit

let healthKit: HealthKit = HealthKit()

// TODO should we show heart rate? maybe just for durations? maybe opt in?
// this code does seem to work: https://www.createwithswift.com/reading-data-from-healthkit-in-a-swiftui-app/
@Observable
final class HealthKit: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    private(set) var enabled = false
    private(set) var inProgress: Bool = false
    private(set) var heartRate: Double? = nil   // bpm
    private(set) var status: String? = nil
    private let store = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func requestPerms() {
        guard let hr = HKObjectType.quantityType(forIdentifier: .heartRate)
        else {
            return
        }

        let read: Set = [hr, HKObjectType.workoutType()]
        let write: Set = [HKObjectType.workoutType()]
        store.requestAuthorization(toShare: write, read: read) {success, error in
            if let error {
                print("HealthKit auth error:", error.localizedDescription)
                self.enabled = false
            } else {
                self.enabled = success
                print(success ? "HealthKit access granted" : "HealthKit access denied")
            }
        }
    }

    func start() async {
        guard !inProgress && enabled else {
            return
        }
        do {
            let config = HKWorkoutConfiguration()
            config.activityType = .traditionalStrengthTraining // TODO or cycling, elliptical, rowing, running, stairClimbing, walking, flexibility, fitnessGaming, functionalStrengthTraining, maybe workout editor could have an option for this (including None)
            config.locationType = .indoor    // TODO make this an option too
            
            let session = try HKWorkoutSession(healthStore: store, configuration: config)
            session.delegate = self
            
            let builder = session.associatedWorkoutBuilder()
            builder.delegate = self
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: store, workoutConfiguration: config)
            
            session.prepare()
            
            let now = Date()
            session.startActivity(with: now)
            try await builder.beginCollection(at: now)
            
            inProgress = true
            self.session = session  // the fields are optional so it's easier to use local variables above
            self.builder = builder
            print("Workout started successfully")
        } catch {
            status = "Failed connecting to HealthKit: \(error.localizedDescription)"
        }
    }

    func stop() {
        guard inProgress && enabled else {
            return
        }
        guard let session = session else {return}
        session.stopActivity(with: Date())
        inProgress = false
        print("Ending workout...")
    }

    // HKLiveWorkoutBuilderDelegate callback
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }
    
    // HKLiveWorkoutBuilderDelegate callback
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for sampleType in collectedTypes {
            guard let quantityType = sampleType as? HKQuantityType else {continue}
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            if let stats = statistics {
                updateMetrics(for: stats)
            }
        }
    }

    // This doesn't seem to work (the Apple code it's based on didn't work either). But the code link above
    // did seem to return heart rate...
    private func updateMetrics(for statistics: HKStatistics) {
        switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            if let value = statistics.mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) {
                heartRate = value
                print("heart rate: \(value) bpm")
            }
        default:
            break
        }
    }

    // HKWorkoutSessionDelegate callback
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        if toState == .stopped, let builder = self.builder {
            Task {
                do {
                    try await builder.endCollection(at: date)
                    _ = try await builder.finishWorkout()
                    workoutSession.end()
                    await MainActor.run {
                        status = "Saved workout to HealthKit"
                    }
                } catch {
                    status = "Failed saving workout to HealthKit: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // HKWorkoutSessionDelegate callback
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
    }
}
