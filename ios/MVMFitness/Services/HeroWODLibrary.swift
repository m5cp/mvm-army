import Foundation

nonisolated struct HeroWODInfo: Codable, Hashable, Sendable {
    let name: String
    let tribute: String
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
        ),
        WODTemplate(
            title: "Hansen",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Kettlebell Swings", reps: "30", notes: "2 pood / 70 lbs"),
                WODMovement(name: "Burpees", reps: "30"),
                WODMovement(name: "GHD Sit-Ups", reps: "30")
            ],
            workoutDescription: "5 rounds for time: 30 KB swings, 30 burpees, 30 GHD sit-ups.",
            notes: "Hero WOD"
        ),
        WODTemplate(
            title: "Badger",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 25,
            equipment: .gym,
            movements: [
                WODMovement(name: "Squat Clean", reps: "30", notes: "95/65 lbs"),
                WODMovement(name: "Pull-Ups", reps: "30"),
                WODMovement(name: "Run", duration: "800m")
            ],
            workoutDescription: "3 rounds for time: 30 squat cleans, 30 pull-ups, 800m run.",
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
        ),
        WODTemplate(
            title: "Klepto",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Handstand Push-Ups", reps: "27"),
                WODMovement(name: "Deadlift", reps: "27", notes: "225/155 lbs"),
                WODMovement(name: "Box Jump", reps: "27", notes: "24/20 in"),
                WODMovement(name: "Burpees", reps: "27")
            ],
            workoutDescription: "4 rounds for time: 27 HSPU, 27 deadlifts, 27 box jumps, 27 burpees.",
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
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
            notes: "Hero WOD"
        ),
        WODTemplate(
            title: "Holbrook",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 30,
            equipment: .gym,
            movements: [
                WODMovement(name: "Thrusters", reps: "5", notes: "115/75 lbs"),
                WODMovement(name: "Hang Power Clean", reps: "10", notes: "115/75 lbs"),
                WODMovement(name: "Run", duration: "100m sprint"),
                WODMovement(name: "Rest", duration: "1 min")
            ],
            workoutDescription: "10 rounds for time: 5 thrusters, 10 hang power cleans, 100m sprint, 1 min rest.",
            notes: "Hero WOD"
        ),
        WODTemplate(
            title: "Nutts",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Handstand Push-Ups", reps: "10"),
                WODMovement(name: "Deadlift", reps: "15", notes: "250/175 lbs"),
                WODMovement(name: "Pull-Ups", reps: "25"),
                WODMovement(name: "Run", duration: "100m sprint")
            ],
            workoutDescription: "4 rounds for time: 10 HSPU, 15 deadlifts, 25 pull-ups, 100m sprint.",
            notes: "Hero WOD"
        ),
        WODTemplate(
            title: "Brenton",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .none,
            movements: [
                WODMovement(name: "Run", duration: "100m bear crawl"),
                WODMovement(name: "Run", duration: "200m sprint")
            ],
            workoutDescription: "5 rounds for time: 100m bear crawl, 200m sprint.",
            notes: "Hero WOD"
        ),
        WODTemplate(
            title: "Garrett",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Clean & Jerk", reps: "75", notes: "135/95 lbs")
            ],
            workoutDescription: "For time: 75 clean & jerks at 135/95 lbs.",
            notes: "Hero WOD"
        ),
        WODTemplate(
            title: "War Frank",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Muscle-Ups", reps: "25"),
                WODMovement(name: "Burpees", reps: "100"),
                WODMovement(name: "Thrusters", reps: "25", notes: "135/95 lbs")
            ],
            workoutDescription: "3 rounds for time: 25 muscle-ups, 100 burpees, 25 thrusters at 135/95 lbs.",
            notes: "Hero WOD"
        ),
        WODTemplate(
            title: "Blake",
            category: .crossfit,
            format: .forTime,
            durationMinutes: 20,
            equipment: .gym,
            movements: [
                WODMovement(name: "Kettlebell Deadlift", reps: "100", notes: "70/53 lbs each hand"),
                WODMovement(name: "Run", duration: "100m"),
                WODMovement(name: "Kettlebell Swings", reps: "100", notes: "70/53 lbs"),
                WODMovement(name: "Run", duration: "100m"),
                WODMovement(name: "Kettlebell Clean & Press", reps: "50 each arm", notes: "70/53 lbs"),
                WODMovement(name: "Run", duration: "100m"),
                WODMovement(name: "Kettlebell Front Squat", reps: "50 each arm", notes: "70/53 lbs"),
                WODMovement(name: "Run", duration: "100m")
            ],
            workoutDescription: "For time: 100 KB deadlifts, 100m run, 100 KB swings, 100m run, 50 KB clean & press each arm, 100m run, 50 KB front squat each arm, 100m run.",
            notes: "Hero WOD"
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
            notes: "Hero WOD"
        )
    ]

    static let heroTributes: [String: HeroWODInfo] = [
        "Murph": HeroWODInfo(
            name: "LT Michael P. Murphy, USN",
            tribute: "Navy Lieutenant Michael Murphy, 29, of Patchogue, NY, was killed in Afghanistan on June 28, 2005. He was the first member of the U.S. Navy to receive the Medal of Honor since the Vietnam War. He led a four-man SEAL reconnaissance team in Operation Red Wings."
        ),
        "JT": HeroWODInfo(
            name: "PO1 Jeff Taylor, USN",
            tribute: "Petty Officer 1st Class Jeff Taylor, 30, of Little Creek, VA, was killed during combat operations in Afghanistan on June 28, 2005. He was assigned to a West Coast-based Naval Special Warfare unit."
        ),
        "Michael": HeroWODInfo(
            name: "LT Michael McGreevy Jr., USN",
            tribute: "Navy Lieutenant Michael McGreevy Jr., 30, of Portville, NY, was killed in Afghanistan on June 28, 2005, during Operation Red Wings. He was a SEAL Team member who gave his life alongside his teammates."
        ),
        "Daniel": HeroWODInfo(
            name: "SFC Daniel Crabtree, USA",
            tribute: "Army Sergeant First Class Daniel Crabtree, 31, of Cleveland, OH, was killed in Al Anbar province, Iraq, on June 8, 2006. He was assigned to the 2nd Marine Expeditionary Force."
        ),
        "Josh": HeroWODInfo(
            name: "SSG Joshua Hager, USA",
            tribute: "Army Staff Sergeant Joshua Hager, 29, of Broomfield, CO, was killed by an IED in Mosul, Iraq, on February 23, 2007. He served with the 2nd Battalion, 7th Cavalry Regiment."
        ),
        "DT": HeroWODInfo(
            name: "SSG Timothy P. Davis, USAF",
            tribute: "Air Force Staff Sergeant Timothy P. Davis, 28, of Aberdeen, WA, was killed on February 20, 2009, supporting operations in OEF when his vehicle was struck by an IED. He served with the 23rd Special Tactics Squadron."
        ),
        "Nate": HeroWODInfo(
            name: "Chief Petty Officer Nate Hardy, USN",
            tribute: "Chief Petty Officer Nate Hardy, 29, of Durham, NH, was killed in Iraq on February 4, 2008. He was a member of an East Coast-based SEAL team."
        ),
        "Randy": HeroWODInfo(
            name: "Randy Simmons, LAPD SWAT",
            tribute: "Officer Randy Simmons, 51, a 27-year veteran of the LAPD and a SWAT team member, was killed in the line of duty on February 6, 2008. He was the first LAPD SWAT officer killed in the line of duty."
        ),
        "Tommy V": HeroWODInfo(
            name: "SSG Thomas Vitagliano, USAF",
            tribute: "Air Force Staff Sergeant Thomas Vitagliano, 33, of Whitman, MA, died on April 16, 2010, from wounds suffered during a firefight in Afghanistan. He served with the 24th Special Tactics Squadron."
        ),
        "Griff": HeroWODInfo(
            name: "SSG Michael Griffin, USA",
            tribute: "Army Staff Sergeant Michael Griffin, of Ware, MA, was killed in October 2007 in a helicopter crash near Tikrit, Iraq. He served with the 4th Infantry Division."
        ),
        "Hansen": HeroWODInfo(
            name: "Cpl. Nathan Hansen, USMC",
            tribute: "Marine Corporal Nathan Hansen was killed in Iraq in August 2009. This workout honors his sacrifice and service to our nation."
        ),
        "Badger": HeroWODInfo(
            name: "Chief Petty Officer Mark Carter, USN",
            tribute: "Navy Chief Petty Officer Mark Carter, 27, of Virginia Beach, VA, was killed in Iraq on December 11, 2007. He was a member of a West Coast-based SEAL team."
        ),
        "Luce": HeroWODInfo(
            name: "CPL Ryan Luce, USA",
            tribute: "Army Specialist Ryan Luce, 22, of Freeport, TX, was killed in Iraq on September 3, 2006. He served with the 1st Cavalry Division."
        ),
        "RJ": HeroWODInfo(
            name: "SSG Ryan Job, USN",
            tribute: "Navy SEAL Petty Officer 2nd Class Ryan Job, 28, was blinded by a sniper's bullet in Ramadi, Iraq, in 2006. Despite his injuries, he completed rehab and pursued a new life. He died on September 24, 2009, from complications of reconstructive surgery."
        ),
        "Klepto": HeroWODInfo(
            name: "SPC Kley (Klepto) Summers, USA",
            tribute: "Army Specialist Kley 'Klepto' Summers was killed in action serving his country. This workout honors his memory and sacrifice."
        ),
        "Loredo": HeroWODInfo(
            name: "SSG Edwardo Loredo, USA",
            tribute: "Army Staff Sergeant Edwardo Loredo, 34, of Houston, TX, was killed on June 24, 2010, in Jelewar, Afghanistan, when insurgents attacked his unit with an IED."
        ),
        "Whitten": HeroWODInfo(
            name: "CPT Jerry Whitten, USA",
            tribute: "Army Captain Jerry Whitten, 29, was killed on May 16, 2005, in Diyala, Iraq, when his vehicle was struck by an IED. He served with the 82nd Airborne Division."
        ),
        "Wittman": HeroWODInfo(
            name: "SGT Jeremiah Wittman, USA",
            tribute: "Army Sergeant Jeremiah Wittman, 26, of Darby, MT, was killed on February 13, 2010, by an IED while on patrol in Zhari district, Kandahar, Afghanistan."
        ),
        "The Seven": HeroWODInfo(
            name: "Seven CIA Officers",
            tribute: "This workout honors seven CIA officers killed on December 30, 2009, by a suicide bomber at Forward Operating Base Chapman in Khost, Afghanistan. They were gathering intelligence to protect Coalition forces."
        ),
        "Clovis": HeroWODInfo(
            name: "PFC Clovis T. Ray, USA",
            tribute: "Army Private First Class Clovis T. Ray, 22, of San Antonio, TX, was killed on March 15, 2012, in Kunar province, Afghanistan, from an IED."
        ),
        "Jag 28": HeroWODInfo(
            name: "CPT Andrew Pedersen-Keel, USA",
            tribute: "Army Captain Andrew Pedersen-Keel, 28, of South Miami, FL, was killed on March 11, 2013, in Wardak province, Afghanistan. He served with the 1st Special Forces Group."
        ),
        "Helton": HeroWODInfo(
            name: "1LT Joseph Helton, USA",
            tribute: "Army 1st Lieutenant Joseph Helton, 24, of Monroe, GA, was killed September 8, 2009, in Baghdad, Iraq, when an IED struck his vehicle."
        ),
        "McGhee": HeroWODInfo(
            name: "SGT Robert McGhee, USA",
            tribute: "Army Sergeant Robert McGhee, 30, was killed June 30, 2009, in Helmand province, Afghanistan, when an IED struck his vehicle."
        ),
        "Holbrook": HeroWODInfo(
            name: "LT Andrew Holbrook, USN",
            tribute: "Navy Lieutenant Andrew Holbrook was a SEAL killed in action. This workout honors his sacrifice and service."
        ),
        "Nutts": HeroWODInfo(
            name: "SFC Jeffrey Nutts, USA",
            tribute: "Army Sergeant First Class Jeffrey Nutts was killed in Afghanistan during combat operations. This workout honors his courage and sacrifice."
        ),
        "Brenton": HeroWODInfo(
            name: "SPC Michael Brenton, USA",
            tribute: "Army Specialist Michael Brenton was killed in action while serving overseas. This workout honors his dedication and sacrifice."
        ),
        "Garrett": HeroWODInfo(
            name: "SSG Garrett Mongrella, USA",
            tribute: "Army Staff Sergeant Garrett Mongrella was killed in Iraq during combat operations. This workout honors his memory."
        ),
        "War Frank": HeroWODInfo(
            name: "SSG Frank Gasper, USMC",
            tribute: "Marine Staff Sergeant Frank Gasper was killed in action during combat operations. This workout is dedicated to his sacrifice."
        ),
        "Blake": HeroWODInfo(
            name: "SO1 Blake Marler, USN",
            tribute: "Navy Special Operator 1st Class Blake Marler was killed in action during combat operations overseas. This workout honors his service."
        ),
        "Arnie": HeroWODInfo(
            name: "SOC (SEAL) Brian Bill, USN",
            tribute: "Navy SEAL Senior Chief Brian Bill was one of the 30 Americans killed on August 6, 2011, when a CH-47 Chinook helicopter was shot down in Wardak province, Afghanistan."
        )
    ]

    static func tributeFor(_ templateTitle: String) -> HeroWODInfo? {
        heroTributes[templateTitle]
    }

    static func isHeroWOD(_ template: WODTemplate) -> Bool {
        template.notes == "Hero WOD"
    }
}
