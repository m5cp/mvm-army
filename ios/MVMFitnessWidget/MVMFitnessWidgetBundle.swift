import WidgetKit
import SwiftUI

@main
struct MVMFitnessWidgetBundle: WidgetBundle {
    var body: some Widget {
        MVMFitnessWidget()
        WorkoutLiveActivity()
    }
}
