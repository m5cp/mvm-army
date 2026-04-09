import SwiftUI
import Observation

@Observable
final class WatchViewModel {
    var data: WatchData = WatchData()

    func refresh() {
        data = WatchSharedData.readWidgetData()
    }
}
