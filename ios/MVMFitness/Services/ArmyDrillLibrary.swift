import Foundation

enum ArmyDrillLibrary {
    static let prepDrill: [ArmyExercise] = [
        ArmyExercise(name: "Bend and Reach", reps: "5 reps"),
        ArmyExercise(name: "Rear Lunge", reps: "5 reps"),
        ArmyExercise(name: "High Jumper", reps: "5 reps"),
        ArmyExercise(name: "Rower", reps: "5 reps"),
        ArmyExercise(name: "Squat Bender", reps: "5 reps"),
        ArmyExercise(name: "Windmill", reps: "5 reps"),
        ArmyExercise(name: "Forward Lunge", reps: "5 reps"),
        ArmyExercise(name: "Prone Row", reps: "5 reps"),
        ArmyExercise(name: "Bent-Leg Body Twist", reps: "5 reps"),
        ArmyExercise(name: "Push-Up", reps: "5 reps")
    ]

    static let fourForCore: [ArmyExercise] = [
        ArmyExercise(name: "Bent-Leg Raise", sets: 2, reps: "10"),
        ArmyExercise(name: "Side Bridge", sets: 2, duration: "30 sec"),
        ArmyExercise(name: "Back Bridge", sets: 2, duration: "30 sec"),
        ArmyExercise(name: "Quadraplex", sets: 2, reps: "10")
    ]

    static let recoveryDrill: [ArmyExercise] = [
        ArmyExercise(name: "Overhead Arm Pull", duration: "20 sec"),
        ArmyExercise(name: "Rear Lunge", duration: "20 sec"),
        ArmyExercise(name: "Extend and Flex", duration: "20 sec"),
        ArmyExercise(name: "Thigh Stretch", duration: "20 sec"),
        ArmyExercise(name: "Single-Leg Over", duration: "20 sec")
    ]

    static let pmcs: [ArmyExercise] = [
        ArmyExercise(name: "Spine Mobility", duration: "60 sec"),
        ArmyExercise(name: "Ankle Mobility", duration: "60 sec"),
        ArmyExercise(name: "Knee Mobility", duration: "60 sec"),
        ArmyExercise(name: "Hip Mobility", duration: "60 sec"),
        ArmyExercise(name: "Shoulder Mobility", duration: "60 sec"),
        ArmyExercise(name: "Elbow and Wrist Mobility", duration: "60 sec")
    ]
}
