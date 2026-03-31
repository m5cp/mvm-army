import Foundation

nonisolated struct HeroWODInfo: Codable, Hashable, Sendable {
    let honoreeFullName: String
    let rankOrRole: String
    let serviceBranch: String
    let dateOfDeath: String
    let location: String
    let shortTribute: String

    var displayName: String {
        "\(rankOrRole) \(honoreeFullName)"
    }

    var formattedTribute: String {
        "\(rankOrRole) \(honoreeFullName)\n\(serviceBranch)\n\(dateOfDeath) — \(location)"
    }

    var isValid: Bool {
        !honoreeFullName.isEmpty &&
        !rankOrRole.isEmpty &&
        !serviceBranch.isEmpty &&
        !dateOfDeath.isEmpty &&
        !location.isEmpty
    }
}

enum HeroWODLibrary {

    static let heroWODs: [WODTemplate] = [
        WODTemplate(
            title: "Murph",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 45,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "1 mile"),
                WODMovement(name: "Pull-Ups", reps: "100"),
                WODMovement(name: "Push-Ups", reps: "200"),
                WODMovement(name: "Air Squats", reps: "300"),
                WODMovement(name: "Run", duration: "1 mile")
            ],
            workoutDescription: "For time. Partition the pull-ups, push-ups, and squats as needed. Start and finish with a 1-mile run. Rx: 20-lb vest/body armor.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "JT",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Handstand Push-Ups", reps: "21"),
                WODMovement(name: "Ring Dips", reps: "21"),
                WODMovement(name: "Push-Ups", reps: "21"),
                WODMovement(name: "Handstand Push-Ups", reps: "15"),
                WODMovement(name: "Ring Dips", reps: "15"),
                WODMovement(name: "Push-Ups", reps: "15"),
                WODMovement(name: "Handstand Push-Ups", reps: "9"),
                WODMovement(name: "Ring Dips", reps: "9"),
                WODMovement(name: "Push-Ups", reps: "9")
            ],
            workoutDescription: "21-15-9 reps for time of handstand push-ups, ring dips, and push-ups.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Michael",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Back Extensions", reps: "50"),
                WODMovement(name: "Sit-Ups", reps: "50")
            ],
            workoutDescription: "3 rounds for time of 800m run, 50 back extensions, and 50 sit-ups.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Daniel",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .gym,
            movements: [
                WODMovement(name: "Pull-Ups", reps: "50"),
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Thrusters", reps: "21", notes: "95/65 lbs"),
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Thrusters", reps: "21", notes: "95/65 lbs"),
                WODMovement(name: "Run", duration: "400m"),
                WODMovement(name: "Pull-Ups", reps: "50")
            ],
            workoutDescription: "For time: 50 pull-ups, 400m run, 21 thrusters, 800m run, 21 thrusters, 400m run, 50 pull-ups.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Josh",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Overhead Squats", reps: "21", notes: "95/65 lbs"),
                WODMovement(name: "Pull-Ups", reps: "42"),
                WODMovement(name: "Overhead Squats", reps: "15", notes: "95/65 lbs"),
                WODMovement(name: "Pull-Ups", reps: "30"),
                WODMovement(name: "Overhead Squats", reps: "9", notes: "95/65 lbs"),
                WODMovement(name: "Pull-Ups", reps: "18")
            ],
            workoutDescription: "For time: 21 OHS, 42 pull-ups, 15 OHS, 30 pull-ups, 9 OHS, 18 pull-ups.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "DT",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 15,
            equipment: .gym,
            movements: [
                WODMovement(name: "Deadlift", reps: "12", notes: "155/105 lbs"),
                WODMovement(name: "Hang Power Clean", reps: "9", notes: "155/105 lbs"),
                WODMovement(name: "Push Jerk", reps: "6", notes: "155/105 lbs")
            ],
            workoutDescription: "5 rounds for time: 12 deadlifts, 9 hang power cleans, 6 push jerks.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Nate",
            category: .crossfit,
            format: .amrap,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Muscle-Ups", reps: "2"),
                WODMovement(name: "Handstand Push-Ups", reps: "4"),
                WODMovement(name: "Pistols (alternating)", reps: "8")
            ],
            workoutDescription: "AMRAP 20 minutes: 2 muscle-ups, 4 handstand push-ups, 8 pistols.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Randy",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 10,
            equipment: .gym,
            movements: [
                WODMovement(name: "Power Snatch", reps: "75", notes: "75/55 lbs")
            ],
            workoutDescription: "For time: 75 power snatches at 75/55 lbs.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Tommy V",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Thrusters", reps: "21", notes: "115/75 lbs"),
                WODMovement(name: "Rope Climb (15 ft)", reps: "12"),
                WODMovement(name: "Thrusters", reps: "15", notes: "115/75 lbs"),
                WODMovement(name: "Rope Climb (15 ft)", reps: "9"),
                WODMovement(name: "Thrusters", reps: "9", notes: "115/75 lbs"),
                WODMovement(name: "Rope Climb (15 ft)", reps: "6")
            ],
            workoutDescription: "For time: 21 thrusters + 12 rope climbs, 15 thrusters + 9 rope climbs, 9 thrusters + 6 rope climbs.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Griff",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Run Backwards", duration: "400m"),
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Run Backwards", duration: "400m")
            ],
            workoutDescription: "For time: 800m run, 400m run backwards, 800m run, 400m run backwards.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Luce",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Run", duration: "1 mile"),
                WODMovement(name: "Clean & Jerk", reps: "10", notes: "135/95 lbs"),
                WODMovement(name: "Run", duration: "1 mile"),
                WODMovement(name: "Clean & Jerk", reps: "10", notes: "135/95 lbs"),
                WODMovement(name: "Run", duration: "1 mile"),
                WODMovement(name: "Clean & Jerk", reps: "10", notes: "135/95 lbs")
            ],
            workoutDescription: "3 rounds for time: 1-mile run + 10 clean & jerks at 135/95 lbs. Rx with 20-lb vest.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "RJ",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Pull-Ups", reps: "5"),
                WODMovement(name: "Push-Ups", reps: "10"),
                WODMovement(name: "Air Squats", reps: "15")
            ],
            workoutDescription: "5 rounds for time: 800m run, 5 pull-ups, 10 push-ups, 15 air squats.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Loredo",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "200m"),
                WODMovement(name: "Air Squats", reps: "24"),
                WODMovement(name: "Push-Ups", reps: "24"),
                WODMovement(name: "Lunges", reps: "24"),
                WODMovement(name: "Pull-Ups", reps: "24")
            ],
            workoutDescription: "6 rounds for time: 200m run, 24 air squats, 24 push-ups, 24 lunges, 24 pull-ups.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Whitten",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 35,
            equipment: .gym,
            movements: [
                WODMovement(name: "Burpees", reps: "22"),
                WODMovement(name: "Kettlebell Swings", reps: "22", notes: "2 pood / 70 lbs"),
                WODMovement(name: "Box Jump", reps: "22", notes: "24 in"),
                WODMovement(name: "Wall Ball", reps: "22", notes: "20/14 lbs"),
                WODMovement(name: "Double-Unders", reps: "22")
            ],
            workoutDescription: "5 rounds for time: 22 burpees, 22 KB swings, 22 box jumps, 22 wall balls, 22 double-unders.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Wittman",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .gym,
            movements: [
                WODMovement(name: "Kettlebell Swings", reps: "15", notes: "1.5 pood / 53 lbs"),
                WODMovement(name: "Power Clean", reps: "15", notes: "95/65 lbs"),
                WODMovement(name: "Box Jump", reps: "15", notes: "24 in")
            ],
            workoutDescription: "7 rounds for time: 15 KB swings, 15 power cleans, 15 box jumps.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "The Seven",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Handstand Push-Ups", reps: "7"),
                WODMovement(name: "Thrusters", reps: "7", notes: "135/95 lbs"),
                WODMovement(name: "Knees-to-Elbows", reps: "7"),
                WODMovement(name: "Deadlift", reps: "7", notes: "245/165 lbs"),
                WODMovement(name: "Burpees", reps: "7"),
                WODMovement(name: "Kettlebell Swings", reps: "7", notes: "2 pood / 70 lbs"),
                WODMovement(name: "Pull-Ups", reps: "7")
            ],
            workoutDescription: "7 rounds for time: 7 HSPU, 7 thrusters, 7 K2E, 7 deadlifts, 7 burpees, 7 KB swings, 7 pull-ups.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Clovis",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 60,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "10 miles"),
                WODMovement(name: "Burpees", reps: "150")
            ],
            workoutDescription: "For time: 10-mile run, then 150 burpees. Partition as needed during the run.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Jag 28",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Push-Ups", reps: "28"),
                WODMovement(name: "Pull-Ups", reps: "28"),
                WODMovement(name: "Air Squats", reps: "28"),
                WODMovement(name: "Sit-Ups", reps: "28")
            ],
            workoutDescription: "8 rounds for time: 800m run, 28 push-ups, 28 pull-ups, 28 air squats, 28 sit-ups.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Helton",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Run", duration: "800m"),
                WODMovement(name: "Dumbbell Squat Clean", reps: "30", notes: "50/35 lbs"),
                WODMovement(name: "Burpees", reps: "30")
            ],
            workoutDescription: "3 rounds for time: 800m run, 30 DB squat cleans, 30 burpees.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "McGhee",
            category: .crossfit,
            format: .amrap,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Deadlift", reps: "5", notes: "275/185 lbs"),
                WODMovement(name: "Push-Ups", reps: "13"),
                WODMovement(name: "Box Jump", reps: "9", notes: "24 in")
            ],
            workoutDescription: "AMRAP 30 minutes: 5 deadlifts, 13 push-ups, 9 box jumps.",
            notes: "Hero Workout"
        ),
        WODTemplate(
            title: "Arnie",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Turkish Get-Up (R)", reps: "1", notes: "2 pood / 70 lbs"),
                WODMovement(name: "Turkish Get-Up (L)", reps: "1", notes: "2 pood / 70 lbs"),
                WODMovement(name: "Kettlebell Swings", reps: "6", notes: "2 pood / 70 lbs"),
                WODMovement(name: "Kettlebell Clean & Jerk (R)", reps: "7"),
                WODMovement(name: "Kettlebell Clean & Jerk (L)", reps: "7")
            ],
            workoutDescription: "With a single 2-pood KB, AMRAP-like flow: 1 TGU each side, 6 KB swings, 7 C&J each side. Repeat.",
            notes: "Hero Workout"
        )
    ]

    static let heroTributes: [String: HeroWODInfo] = [
        "Murph": HeroWODInfo(
            honoreeFullName: "Michael P. Murphy",
            rankOrRole: "LT",
            serviceBranch: "U.S. Navy",
            dateOfDeath: "June 28, 2005",
            location: "Afghanistan",
            shortTribute: "Led a four-man SEAL team in Operation Red Wings. Medal of Honor recipient."
        ),
        "JT": HeroWODInfo(
            honoreeFullName: "Jeff Taylor",
            rankOrRole: "PO1",
            serviceBranch: "U.S. Navy",
            dateOfDeath: "June 28, 2005",
            location: "Afghanistan",
            shortTribute: "Assigned to a West Coast-based Naval Special Warfare unit."
        ),
        "Michael": HeroWODInfo(
            honoreeFullName: "Michael McGreevy Jr.",
            rankOrRole: "LT",
            serviceBranch: "U.S. Navy",
            dateOfDeath: "June 28, 2005",
            location: "Afghanistan",
            shortTribute: "SEAL Team member lost during Operation Red Wings."
        ),
        "Daniel": HeroWODInfo(
            honoreeFullName: "Daniel Crabtree",
            rankOrRole: "SFC",
            serviceBranch: "U.S. Army",
            dateOfDeath: "June 8, 2006",
            location: "Al Anbar Province, Iraq",
            shortTribute: "Assigned to the 2nd Marine Expeditionary Force."
        ),
        "Josh": HeroWODInfo(
            honoreeFullName: "Joshua Hager",
            rankOrRole: "SSG",
            serviceBranch: "U.S. Army",
            dateOfDeath: "February 23, 2007",
            location: "Mosul, Iraq",
            shortTribute: "Served with the 2nd Battalion, 7th Cavalry Regiment."
        ),
        "DT": HeroWODInfo(
            honoreeFullName: "Timothy P. Davis",
            rankOrRole: "SSG",
            serviceBranch: "U.S. Air Force",
            dateOfDeath: "February 20, 2009",
            location: "Afghanistan",
            shortTribute: "Served with the 23rd Special Tactics Squadron."
        ),
        "Nate": HeroWODInfo(
            honoreeFullName: "Nate Hardy",
            rankOrRole: "CPO",
            serviceBranch: "U.S. Navy",
            dateOfDeath: "February 4, 2008",
            location: "Iraq",
            shortTribute: "Member of an East Coast-based SEAL team."
        ),
        "Randy": HeroWODInfo(
            honoreeFullName: "Randy Simmons",
            rankOrRole: "Officer",
            serviceBranch: "LAPD SWAT",
            dateOfDeath: "February 6, 2008",
            location: "Los Angeles, CA",
            shortTribute: "27-year LAPD veteran. First LAPD SWAT officer killed in the line of duty."
        ),
        "Tommy V": HeroWODInfo(
            honoreeFullName: "Thomas Vitagliano",
            rankOrRole: "SSG",
            serviceBranch: "U.S. Air Force",
            dateOfDeath: "April 16, 2010",
            location: "Afghanistan",
            shortTribute: "Served with the 24th Special Tactics Squadron."
        ),
        "Griff": HeroWODInfo(
            honoreeFullName: "Michael Griffin",
            rankOrRole: "SSG",
            serviceBranch: "U.S. Army",
            dateOfDeath: "October 2007",
            location: "Tikrit, Iraq",
            shortTribute: "Served with the 4th Infantry Division."
        ),
        "Luce": HeroWODInfo(
            honoreeFullName: "Ryan Luce",
            rankOrRole: "SPC",
            serviceBranch: "U.S. Army",
            dateOfDeath: "September 3, 2006",
            location: "Iraq",
            shortTribute: "Served with the 1st Cavalry Division."
        ),
        "RJ": HeroWODInfo(
            honoreeFullName: "Ryan Job",
            rankOrRole: "PO2",
            serviceBranch: "U.S. Navy",
            dateOfDeath: "September 24, 2009",
            location: "United States",
            shortTribute: "Navy SEAL wounded in Ramadi, Iraq in 2006. Passed from surgical complications."
        ),
        "Loredo": HeroWODInfo(
            honoreeFullName: "Edwardo Loredo",
            rankOrRole: "SSG",
            serviceBranch: "U.S. Army",
            dateOfDeath: "June 24, 2010",
            location: "Jelewar, Afghanistan",
            shortTribute: "Killed when insurgents attacked his unit with an IED."
        ),
        "Whitten": HeroWODInfo(
            honoreeFullName: "Jerry Whitten",
            rankOrRole: "CPT",
            serviceBranch: "U.S. Army",
            dateOfDeath: "May 16, 2005",
            location: "Diyala, Iraq",
            shortTribute: "Served with the 82nd Airborne Division."
        ),
        "Wittman": HeroWODInfo(
            honoreeFullName: "Jeremiah Wittman",
            rankOrRole: "SGT",
            serviceBranch: "U.S. Army",
            dateOfDeath: "February 13, 2010",
            location: "Zhari District, Kandahar, Afghanistan",
            shortTribute: "Killed by an IED while on patrol."
        ),
        "The Seven": HeroWODInfo(
            honoreeFullName: "Seven CIA Officers",
            rankOrRole: "Intelligence Officers",
            serviceBranch: "Central Intelligence Agency",
            dateOfDeath: "December 30, 2009",
            location: "FOB Chapman, Khost, Afghanistan",
            shortTribute: "Killed by a suicide bomber while gathering intelligence to protect Coalition forces."
        ),
        "Clovis": HeroWODInfo(
            honoreeFullName: "Clovis T. Ray",
            rankOrRole: "PFC",
            serviceBranch: "U.S. Army",
            dateOfDeath: "March 15, 2012",
            location: "Kunar Province, Afghanistan",
            shortTribute: "Killed by an IED."
        ),
        "Jag 28": HeroWODInfo(
            honoreeFullName: "Andrew Pedersen-Keel",
            rankOrRole: "CPT",
            serviceBranch: "U.S. Army",
            dateOfDeath: "March 11, 2013",
            location: "Wardak Province, Afghanistan",
            shortTribute: "Served with the 1st Special Forces Group."
        ),
        "Helton": HeroWODInfo(
            honoreeFullName: "Joseph Helton",
            rankOrRole: "1LT",
            serviceBranch: "U.S. Army",
            dateOfDeath: "September 8, 2009",
            location: "Baghdad, Iraq",
            shortTribute: "Killed when an IED struck his vehicle."
        ),
        "McGhee": HeroWODInfo(
            honoreeFullName: "Robert McGhee",
            rankOrRole: "SGT",
            serviceBranch: "U.S. Army",
            dateOfDeath: "June 30, 2009",
            location: "Helmand Province, Afghanistan",
            shortTribute: "Killed when an IED struck his vehicle."
        ),
        "Arnie": HeroWODInfo(
            honoreeFullName: "Brian Bill",
            rankOrRole: "SOC (SEAL)",
            serviceBranch: "U.S. Navy",
            dateOfDeath: "August 6, 2011",
            location: "Wardak Province, Afghanistan",
            shortTribute: "One of 30 Americans killed when a CH-47 Chinook was shot down."
        )
    ]

    static func tributeFor(_ templateTitle: String) -> HeroWODInfo? {
        guard let info = heroTributes[templateTitle], info.isValid else { return nil }
        return info
    }

    static func isHeroWorkout(_ template: WODTemplate) -> Bool {
        template.notes == "Hero Workout"
    }

    @available(*, deprecated, renamed: "isHeroWorkout")
    static func isHeroWOD(_ template: WODTemplate) -> Bool {
        isHeroWorkout(template)
    }

    static let memorialDisclaimer = "This app is not affiliated with or endorsed by CrossFit, Inc. Workout names and formats are used for general fitness and educational purposes only."

    static let tributeDisclaimer = "Memorial workouts are included to honor individuals. Information is based on publicly available sources and may be limited. If you identify an error, please contact us for correction."
}
