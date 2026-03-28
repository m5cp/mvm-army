import Foundation
import CoreMotion
import Observation

@Observable
final class PedometerManager {
    private let pedometer = CMPedometer()

    var todaySteps: Int = 0
    var isAvailable: Bool = CMPedometer.isStepCountingAvailable()

    func refreshTodaySteps() {
        guard isAvailable else { return }

        let start = Calendar.current.startOfDay(for: .now)
        pedometer.queryPedometerData(from: start, to: .now) { [weak self] data, _ in
            let value = data?.numberOfSteps.intValue ?? 0
            DispatchQueue.main.async {
                self?.todaySteps = value
            }
        }
    }
}
