import Foundation

/// Markdown help for exercises. The key for the dicts is the formalName from an exercise.
/// See https://commonmark.org/help/ for the supported formatting. But only the
/// inline markdown is supported:
///    Bold (**text**)
///    Italic (*text*)
///    Strikethrough (~~text~~) 
///    Monospaced (`text`)
///    Links ([link](url))
@Observable
final class Notes: Codable {
    /// The default help.
    var defaults: [String: String] = [:]

    /// Either brand new help test added by the user or an edited version of defaults.
    /// This will override defaults if both have the same key.
    var custom: [String: String] = [:]
        
    enum CodingKeys: String, CodingKey {
        case custom
    }
    
    init() {
        self.addDefaults()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        custom = try container.decode([String: String].self, forKey: .custom)

        // We don't bother saving defaults because we always want the most up to date version
        // (and because defaults is rather large).
        self.addDefaults()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(custom, forKey: .custom)
    }

    func has(_ name: String) -> Bool {
        return defaults[name] != nil || custom[name] != nil
    }

    func find(_ name: String) -> String {
        if let n = custom[name] {
            return n
        }
        if let n = defaults[name] {
            return n
        }
        return "There are no notes for \(name)."
    }
}

extension Notes {
    private func addDefaults() {
        add("A8",
            ["[Row](http://stronglifts.com/barbell-row)",
                "[Power Clean](https://experiencelife.com/article/learn-to-power-clean)",
                "[Front Squat](https://www.verywellfit.com/how-to-do-a-barbell-front-squat-4842368)",
                "[Military Press](https://www.muscleandstrength.com/exercises/military-press.html)",
                "[Back Squat](http://strengtheory.com/how-to-squat)",
                "[Good Morning](https://www.verywellfit.com/how-to-do-the-good-morning-exercise-with-barbell-3498255)"],
            [("Link", "https://www.t-nation.com/training/rebuild-yourself-with-complexes")])
        
        add("Ab Wheel Rollout",
            ["Hold the ab wheel with both hands and kneel on the floor.",
                "Roll the wheel straight forward as far as you can without touching the floor with your body.",
                "Pause and slowly roll back."],
            [("Link", "https://www.muscleandfitness.com/workouts/full-body-exercises/the-ab-wheel-rollout-how-to-benefits-variations/"),
             ("Video", "https://www.youtube.com/watch?v=uYBOBBv9GzY")])
        
        add("Adductor Foam Roll",
            ["Lay face down on the floor using upper hands to support your upper body.",
                "Place the inside of your thigh on the foam roller.",
                "Slowly roll up and down and side to side.",
                "Pause on areas that are especially tender until they feel better."],
            [("Link", "https://www.nasm.org/exercise-library/foam-roll-adductors")],
        )
        
        add("Advanced Shrimp Squat",
            ["Stand straight up with your hands stretched out in front of you.",
                "Raise one leg so that your shin is above parallel to the floor.",
                "Squat down until your elevated leg touches down at the knee, but not at the toes.",
                "Hold onto your elevated knee as you descend."],
            [("Video", "https://www.youtube.com/watch?v=TKt0-c83GSc&feature=youtu.be&t=3m9s"),
             ("Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat/#wiki_squat")],
        )
        
        add("Advanced Tuck Front Lever Row",
            ["Get into a loosely tucked front level position.",
                "Pull your body up as high as possible while remaining horizontal."],
            [("Link", "https://www.youtube.com/watch?v=cVdb8oUGKAw"),
             ("Body Weight Rows", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/row")],
        )
        
        add("Ant. Scalenes Stretch",
            ["This can be done either seated or standing.",
                "Keep back straight and neck inline with spine.",
                "Depress chest with one hand.",
                "Tilt head so ear fingers point to leans to shoulder.",
                "Then point chin upwards..",
                "Hold for 30-60s and then switch sides.",
                "Ideally do these 2-3x a day."],
            [("Link", "https://www.youtube.com/watch?v=wQylqaCl8Zo")],
        )
        
        add("Arch Hangs",
            ["Hang off a pull-up bar.",
                "Bring your head and shoulders back and arch your entire body.",
                "Try to pinch your shoulder blades together and keep your elbows straight."],
            [("Link", "https://www.youtube.com/watch?v=C995b3KLXS4&feature=youtu.be&t=7s")],
        )
        
        add("Arch Hold",
            ["Lay face down.",
                "Place hands behind you off the floor, lift chest up, raise legs off the floor.",
                "Remember to breathe.",
                "Difficulty can be increased by moving hands out in front of you."],
            [("Video", "https://www.youtube.com/watch?v=44ScXWFaVBs&feature=youtu.be&t=7m51s"),
             ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pullup")],
        )
        
        add("Arm & Leg Lift Front Plank",
            ["Adopt the normal front plank position.",
                "Raise one leg and the opposite arm so that they are parallel to the floor.",
                "Halfway through switch up your limbs."],
            [("Progression", "http://www.startbodyweight.com/p/plank-progression.html")],
        )
        
        add("Arm & Leg Lift Side Plank",
            ["Adopt the normal side plank position.",
                "Extend one arm all the way up and raise separate your legs.",
                "Halfway through flip to the other side."],
            [("Progression", "http://www.startbodyweight.com/p/plank-progression.html")],
        )
        
        add("Arnold Press",
            ["Sit on a bench with back support.",
                "Hold two dumbbells in front of you at about shoulder height with palms facing inward.",
                "Raise the dumbbells while rotating them so that your palms face outward.",
                "Lower the dumbbells rotating them back to the original position.",
            ],
            [("Link", "https://exrx.net/WeightExercises/DeltoidAnterior/DBArnoldPress")],
        )
        
        add("Assisted Squat",
            ["Use a chair or something else to support you as you squat.",
                "Reduce the use of the support over time.",
            ],
            [("Link", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat"),
                ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase2/squat"),
                ("Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat")],
        )
        
        add("B8",
            ["[Deadlift](http://stronglifts.com/deadlift)",
                "[Clean-grip High Pull](https://www.t-nation.com/training/clean-high-pull)",
                "[Clean-grip Snatch](https://www.catalystathletics.com/exercise/383/Clean-Grip-Snatch/)",
                "[Back Squats](http://strengtheory.com/how-to-squat)",
                "[Good Morning](https://www.verywellfit.com/how-to-do-the-good-morning-exercise-with-barbell-3498255)",
                "[Rows](http://stronglifts.com/barbell-row)"],
            [("Link", "https://www.t-nation.com/training/rebuild-yourself-with-complexes")],
        )
        
        add("Back Extension",
            [
                "Lie face down on a hyperextension bench.",
                "Keep knees slightly ben angle feet out.",
                "Bend forward as far as possible while keeping back straight.",
                "Raise upwards again keeping back straight.",
                "Stop once your body forms a straight line.",
                "Difficulty can be increased by clasping your hands behind your head (prisoner position), by bracing yourself with one leg, or by holding a weight to your chest."],
            [("Link", "https://www.strengthlog.com/back-extension/"), ("Video", "https://bretcontreras.com/back-extensions/")],
        )
        
        add(
            "Band Anti-Rotary Hold",
            [
                "Attach a resistance band to a support.",
                "Stretch the band out and stand so that you are perpendicular to the band.",
                "Extend your arms straight out.",
                "Hold that position.",
            ],
            [("Video", "https://www.youtube.com/watch?v=xwoPR2_F6qc")],
        )
        
        add(
            "Band Pull Apart",
            [
                "Grip a band with your hands and extend your arms straight out in front of you.",
                "Move your hands to your sides keeping your arms straight.",
                "Keep your shoulders back.",
                "Bring your hands back to the starting position.",
            ],
            [(
                "Link",
                "https://www.gymreapers.com/blogs/news/how-to-do-resistance-band-pull-aparts",
            )],
        )
        
        add(
            "Band Seated Abduction",
            [
                "Sit on a box or low chair.",
                "Place a resistance band just below your knees.",
                "Clasp your hands on your chest.",
                "Keep your feet on the floor and extend your knees out and back in.",
            ],
            [("Video", "https://www.youtube.com/watch?v=uo4_wM5r7zY")],
        )
        
        add(
            "Band Standing Abduction",
            [
                "Place a resistance band just above your ankles.",
                "Use one hand to brace yourself.",
                "Bring one foot up off the floor and to the side.",
            ],
            [("Video", "https://www.youtube.com/watch?v=HzUgVEAjixY")],
        )
        
        add(
            "Banded Nordic Curl",
            [
                "Kneel on the ground.",
                "Secure a band to a support and wrap it around your chest.",
                "Lean forward.",
                "Keep your back straight at all times.",
            ],
            [("Video", "https://www.youtube.com/watch?v=HUXS3S2xSX4")],
        )
        
        add(
            "Bent-legged Calf Stretch",
            [
                "Place one foot on a flight of stairs so that just your toes are supported.",
                "Bend the knee on that leg forward and hold.",
            ],
            [(
                "Link",
                "https://www.saintlukeskc.org/health-library/bent-knee-calf-stretch#:~:text=Stand%20an%20arm's%20length%20away,both%20knees%20and%20lean%20forward.",
            )],
        )
        
        add(
            "Bar Pullover",
            [
                "Do a pull-up and as you come up bring your legs up and spin around the bar.",
                "From the top roll forward, lower your legs, and no a negative pull-up.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=saLtuweg8As"),
                (
                    "Pullups",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pullup",
                ),
            ],
        )
        
        add(
            "Barbell Curl",
            [
                "Use an EZ bar or a regular barbell.",
                "Grip bar at shoulder width with palms facing out.",
                "Pull upwards until forearms are vertical.",
                "Lower until arms are straightened out.",
            ],
            [(
                "Link",
                "https://www.coachweb.com/exercises/arm-exercises/151/barbell-curl",
            )],
        )
        
        add("Barbell Lunge",
            ["Load up a bar within a squat rack.",
                "Step under the bar and place it just below your neck.",
                "Step away from the rack and squat down with one leg.",
                "Squat with the other leg and repeat.",
                "When pushing up drive through your heels.",
                "Keep your torso upright.",
                "Don't allow your knees to go forward beyond your toes.",
                "Difficulty can be increased by walking as you lunge.",
            ],
            [("Link", "https://www.muscleandstrength.com/exercises/barbell-lunge.html")],
        )
        
        add("Barbell Shrug",
            [
                "Stand straight upright with your feet at shoulder width.",
                "Grip the bar with your palms facing you and hands slightly more that shoulder width apart.",
                "Raise your shoulders as high as they will go.",
                "Slowly lower the bar back down.",
                "Avoid using your biceps."],
            [("Link", "https://www.muscleandstrength.com/exercises/barbell-shrug.html")],
        )
        
        add(
            "Bear Crawl",
            [
                "Raise your butt high in the air and walk forward.",
                "If space is limited 2-4 steps forward and backwards works.",
                "Reach with your shoulders when moving forwards.",
                "Push out with your shoulders when going backwards.",
            ],
            [
                ("Video", "https://www.youtube.com/watch?v=780CAAkwjMo"),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1",
                ),
            ],
        )
        
        add(
            "Beginner Shrimp Squat",
            [
                "Stand straight up with your hands stretched out in front of you.",
                "Raise one leg so that your shin is parallel to the floor.",
                "Squat down until your elevated leg touches down at the knee and at the toes.",
                "If you're having trouble balancing you can hold onto a support.",
            ],
            [
                (
                    "Video",
                    "https://www.youtube.com/watch?v=TKt0-c83GSc&feature=youtu.be&t=3m9s",
                ),
                (
                    "Progression",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat",
                ),
            ],
        )
        
        add(
            "Bench Jump",
            [
                "Begin with a bench or box 1-2 feet in front of you.",
                "Stand with feet about shoulder width apart.",
                "Do a short squa swing arms back, and jump as high as possible over the bench.",
            ],
            [("Link", "https://focusedonfit.com/exercise/bench-jump/")],
        )
        
        add("Bench Press",
            [
                "Eyes under the bar.",
                "Grip should be such that forearms are vertical at the bottom. Usually about 1.5-2x shoulder width.",
                "Feet should usually be between knees and hips and out as much as possible.",
                "Bar should rest on palm, near wrists.",
                "Lower shoulders, squeeze shoulders together, stay tight throughout.",
                "Raise chest instead of arching lower back.",
                "Squeeze the bar hard.",
                "Bring bar down to about lower nipples. Raise back to over eyes.",
                "Don't watch the bar, instead look at a fixed point on the ceiling.",
                "Press feet hard into the floor to help maintain tension."],
            [("Stronglifts", "http://stronglifts.com/bench-press/"),
             ("Thrall Video", "https://www.youtube.com/watch?v=BYKScL2sgCs"),
             ("4 mistakes", "https://www.youtube.com/watch?v=TDSXgCB6KfI")],
        )
        
        add(
            "Bend (intro)",
            [
                "Stand upright with your hands stretched out above your head.",
                "Bend forward, trying to reach your toes.",
                "Straighten back up and bend backwards moderately.",
            ],
            [("Link", "https://www.fourmilab.ch/hackdiet/e4/")],
        )
        
        add(
            "Bend and Bounce",
            [
                "Stand upright with your hands stretched out above your head.",
                "Bend forward and touch the floor between your legs.",
                "Bounce up a few inches and touch the floor again.",
                "Straighten back up and bend backwards moderately.",
            ],
            [("Link", "https://www.fourmilab.ch/hackdiet/e4/")],
        )
        
        add("Bent-knee Iron Cross",
            ["Lie on your back with your legs tucked into your chest and your arms spread outwards.",
                "Tuck your knees so that your upper legs are at a ninety angle to the floor.",
                "Keeping legs tucked and shoulders on the floor slowly rotate your legs from side to side.",
                "Turn your head in the opposite direction as your legs.",
                "Hold the down position for a two count."],
            [("Video", "https://www.youtube.com/watch?v=2HYWl009bq0"), ("Gallery", "https://imgur.com/gallery/iEsaS")])
        
        add("Bent Over Dumbbell Row",
            ["Grasp dumbbells so that palms are facing inward.",
                "Bend knees slightly and bend forward until torso is almost parallel with the floor.",
                "Keep back straight and head up.",
                "Bring dumbbells to your sides while keeping torso stationary.",
            ],
            [("Link", "https://www.puregym.com/exercises/back/rows/dumbbell-bent-over-row/#how-to")])
        
        add("Bike Sprints",
            ["Use as much resistance as possible.",
                "Sprint for 15-30 seconds.",
                "Rest for 30-45 seconds.",
                "Do 5-8 sets.",
            ],
            [("Link", "https://www.t-nation.com/training/4-dumbest-forms-of-cardio")])
        
        add("Bird-dog",
            [
                "Kneel with your hands and feet shoulder width apart.",
                "Slowly lean forward and place your hands on the mat below your shoulders.",
                "Brace your core and simultaneously raise one arm and the opposite leg until they extend straight outwards."],
            [("Link", "https://www.acefitness.org/education-and-resources/lifestyle/exercise-library/14/bird-dog")],
        )
        
        add("Body Saw",
            [
                "Crouch down in front plank position with your feet resting on something that will allow them to move easily.",
                "Shift your body backward and then forward.",
                "Keep your body in a straight line throughout."],
            [("Video", "https://www.youtube.com/watch?v=8hoiwnkFAHE")],
        )
        
        add("Body-weight Box Squat",
            [
                "Find a bench or chair that is at a height where when your butt touches it your thighs are slightly below parallel with the floor.",
                "Stand with your feet slightly wider than your hips.",
                "Point toes outward 5-20 degrees.",
                "Look straight forward the entire time: pick a point and focus on that.",
                "In one motion begin extending your hips backward and bending your knees.",
                "Push your knees out so that they stay over your feet.",
                "Go down until your butt touches the box and then go back up.",
                "Keep your back straight."],
            [("Link", "https://www.nerdfitness.com/blog/2014/03/03/strength-training-101-how-to-squat-properly/")],
        )
        
        add(
            "Body-weight Hip Thrust",
            [
                "Use a low bench to elevate your shoulders.",
                "Move feet about shoulder width apart.",
                "Push your heels into the floor and lift your hips off the floor.",
                "Keep your back straight.",
                "Difficulty can be increased by pausing for 3s at the top.",
            ],
            [
                (
                    "Link",
                    "https://www.muscleandstrength.com/exercises/bodyweight-hip-thrust",
                ),
                (
                    "Barbell Version",
                    "https://bretcontreras.com/how-to-hip-thrust/",
                ),
            ],
        )
        
        add(
            "Body-weight Single Leg Hip Thrust",
            [
                "Use a low bench to elevate your shoulders.",
                "Move feet about shoulder width apart.",
                "Use one leg to lift your hips off the floor.",
                "Tuck the other leg into your chest.",
                "Difficulty can be increased by pausing for 3s at the top.",
            ],
            [("Video", "https://www.youtube.com/watch?v=hUboSbJdvvU")],
        )
        
        add(
            "Body-weight Single Leg Deadlift",
            [
                "Stand straight up.",
                "Extend one leg straight out behind you.",
                "At the same time lower your torso.",
                "Continue until your outstretched leg and torso are parallel to the floor.",
                "Keep your back straight the entire time.",
                "Your hands can be stretched out in front of you or one can be lowered to the floor.",
            ],
            [
                (
                    "Link",
                    "https://classpass.com/movements/single-leg-deadlift",
                ),
                ("Contreras", "https://bretcontreras.com/the-single-leg-rdl/"),
            ],
        )
        
        add(
            "Body-weight Bulgarian Split Squat",
            [
                "Stand in front of a low bench.",
                "Bring one leg backward so that your foot rests on the bench.",
                "Keeping your torso upright drop into a squat.",
                "Don't let your knee drift in front of your foot.",
            ],
            [
                ("Video", "https://www.youtube.com/watch?v=HeZiiPtlcew"),
                (
                    "Progression",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat",
                ),
            ],
        )
        
        add(
            "Body-weight Romanian Deadlift",
            [
                "Stand up straight with one hand on your chest and another on your belly.",
                "Keeping your back straight and your chest ou bend at the waist.",
            ],
            [("Video", "https://www.youtube.com/watch?v=diyzGOtiPCM")],
        )
        
        add(
            "Body-weight Squat",
            [
                "Hold your hands up under your chin.",
                "With one leg squat down so that your knee touches the ground.",
                "Keep your back straight and your chest pushed out.",
            ],
            [
                (
                    "Link",
                    "https://www.getstrong.fit/images/GobletSplitSquat.jpg",
                ),
                (
                    "Progression",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat",
                ),
            ],
        )
        
        add(
            "Body-weight Split Squat",
            [
                "Stand in front of a low bench.",
                "Bring one leg backward so that your foot rests on the bench.",
                "Keeping your torso upright drop into a squat.",
            ],
            [
                ("Video", "https://www.youtube.com/watch?v=HeZiiPtlcew"),
                (
                    "Progression",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat",
                ),
            ],
        )
        
        add("Body-weight Step Up + Reverse Lunge",
            ["Use one leg to step onto a low bench.",
                "Step back down and lower the knee of that leg onto the ground.",
                "Repeat.",
                "Difficulty can be increased by holding a dumbbell.",
            ],
            [("Video", "https://www.youtube.com/watch?v=F72adrSjfiU")],
        )
        
        add("Body-weight Walking Lunge",
            ["Stand with feet shoulder width apart and your hands on your hips.",
                "Step forward with one leg and descend until one knee nearly touches the ground.",
                "Press using your heel to raise yourself back up.",
                "Repeat with the other leg.",
                "Keep your torso upright.",
            ],
            [("Link", "https://www.muscleandstrength.com/exercises/bodyweight-walking-lunge.html"),
             ("Video", "https://www.youtube.com/watch?v=L8fvypPrzzs")],
        )
        
        add(
            "Bottoms Up",
            [
                "Lay on your back with your legs straight and your arms at your side.",
                "Tuck your knees into your chest.",
                "Extend your legs straight out above you.",
                "Raise your butt off the floor keeping your legs perpendicular to the ground.",
            ],
            [(
                "Link",
                "https://superhumanfitness.com/exercises/abs/lower-abs/bottoms-up/",
            )],
        )
        
        add("Bottoms Up Good Morning",
            [
                "Adjust the pins within a power rack so that the barbell is at stomach height.",
                "Bend underneath the bar and setup as if for a low bar squat. When the bar is at the correct height you should be parallel to the floor.",
                "Straighten up until you are standing.",
                "Keep back straight and knees slightly bent."],
            [("Link", "https://www.youtube.com/watch?v=1ATixR61uWw")],
        )
        
        add(
            "Box Jump",
            [
                "Squat down, swing your arms behind you, and jump as high as you can onto the box.",
                "Land with your feet flat.",
                "Keep back straight and abs braced.",
                "Eyes and chest should be up when landing.",
                "Pause for a bit after landing.",
                "Step off the box if it’s higher than 20 inches.",
            ],
            [
                (
                    "Guide",
                    "https://www.verywellfit.com/how-to-do-box-jumps-4588131",
                ),
                (
                    "More",
                    "https://www.t-nation.com/training/stop-doing-box-jumps-like-a-jackass",
                ),
            ],
        )
        
        add("Box Squat",
            [
                "Find a bench or chair that is at a height where when your butt touches it your thighs are slightly below parallel with the floor.",
                "Stand with your feet slightly wider than your hips.",
                "Point toes outward 5-20 degrees.",
                "Look straight forward the entire time: pick a point and focus on that.",
                "In one motion begin extending your hips backward and bending your knees.",
                "Push your knees out so that they stay over your feet.",
                "Go down until your butt touches the box and then go back up.",
                "Keep your back straight."],
            [("Link", "https://www.westside-barbell.com/blogs/the-blog/how-to-execute-a-proper-box-squat")],
        )
        
        add(
            "Butcher's Block",
            [
                "Kneel down and support your elbows on a chair or low box.",
                "Grab a light bar and hold it behind your head.",
                "Keep your back straight and your head down.",
            ],
            [("Video", "https://www.youtube.com/watch?v=OhhaK3nDbbA")],
        )
        
        add(
            "Burpees",
            [
                "Begin in a squat position with your hands on the floor in front of you.",
                "Kick your feet out and enter a pushup position.",
                "Immediately return your feet back to the squat position.",
                "From the squat leap into the air as high as you can.",
                "Maintain a fast pace.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=qNLiCX8gYWo"),
                (
                    "Variations",
                    "https://www.bodybuilding.com/content/burpee-conditioning-no-more-nonsense.html",
                ),
            ],
        )
        
        add(
            "C8",
            [
                "[Hang Snatch](https://www.bodybuilding.com/exercises/hang-snatch)",
                "[Overhead Squat](https://barbend.com/overhead-squat/)",
                "[Back Squat](http://strengtheory.com/how-to-squat)",
                "[Good Morning](https://www.verywellfit.com/how-to-do-the-good-morning-exercise-with-barbell-3498255)",
                "[Rows](http://stronglifts.com/barbell-row)",
                "[Deadlift](http://stronglifts.com/deadlift)"],
            [(
                "Link",
                "https://www.t-nation.com/training/rebuild-yourself-with-complexes",
            )],
        )
        
        add(
            "Cable Crunch",
            [
                "Kneel below a high pulley with a rope attachment.",
                "Lower the rope until your hands are next to your face.",
                "Keep your back straight throughout.",
                "Tuck chin.",
                "Flex abs and lower your torso keeping arms and hips still.",
                "Elbows should be lowered to mind-thighs.",
            ],
            [(
                "Link",
                "https://steelsupplements.com/blogs/steel-blog/how-to-do-casble-crunches-form-benefits",
            )],
        )
        
        add("Cable Crossover",
            [
                "Start with pulleys above your head.",
                "Place one foot forward and bend slightly at the waist.",
                "With a slight bend to your elbows, extend your arms straight in front of you in a wide arc until you feel a stretch in your chest.",
                "Keep your torso straight: don't lean forward as you move your arms.",
                "Keep your arms slightly bent: don't use them to push into the handles."],
            [("Link", "https://www.bodybuilding.com/exercises/cable-crossover")],
        )
        
        add("Cable Hip Abduction",
            [
                "Use an ankle cuff to attach a leg to a low pulley.",
                "Step away from the pulley and turn so that the leg with the cuff is closest to the pulley.",
                "Take a wide stance and move the leg with the cuff closer to the puller and then back to your starting position."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/cable-hip-adduction")],
        )
        
        add("Cable Hip Rotation",
            [
                "Use a tower or a high pulley and an attachment that works with your hands clasped together.",
                "Stand sideways to the cable and grab the attachment keeping your arm fully extended.",
                "Rotate your arms and torso closer and further from the pulley.",
                "Keep your arms stretched out the entire time."],
            [("Video", "https://www.youtube.com/watch?v=EhXxfGMggB8")],
        )
        
        add("Cable Wood Chop",
            [
                "Use a tower or a high pulley and an attachment that works with your hands clasped together.",
                "Stand sideways to the cable and grab the attachment keeping your arm fully extended.",
                "Grasp the attachment with your other hand and swing your hands down and to your side.",
                "Rotate your torso keeping back and arms straight."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/standing-cable-wood-chop")],
        )
        
        add("Calf Wall Stretch",
            [
                "Stand facing a wall and place both palms on the wall at about eye level.",
                "Extend your injured leg back behind you with the toe pointed slightly inward.",
                "Slowly lean into the wall until you feel a stretch in your calf.",
                "Keep both heels on the ground the entire time."],
            [("Link", "https://myhealth.alberta.ca/Health/aftercareinformation/pages/conditions.aspx?hwid=bo1613")],
        )
        
        add(
            "Calf Press",
            [
                "Adjust the seat so that your legs are only slightly bent at the start position.",
                "Grasp the handles and straighten your legs by extending knees.",
                "Your ankle should be fully flexed with toes pointed up.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/calf-press",
            )],
        )
        
        add(
            "Cat Camels",
            [
                "Crouch on your hands and knees with arms straight.",
                "For the cat lift head and chest up letting your stomach sink.",
                "For the camel round back and bring head and hips together.",
            ],
            [("Link", "https://www.youtube.com/watch?v=K9bK0BwKFjs")],
        )
        
        add(
            "Chest Flies (band)",
            [
                "Start with your arms extending out to your sides stretching a band behind your back.",
                "Rotate your arms so that they point straight in front of you.",
                "Keep your arms straight the entire time.",
                "Bring your arms back behind your back.",
            ],
            [(
                "Link",
                "https://www.youtube.com/watch?v=8lDC4Ri9zAQ&feature=youtu.be&t=4m22s",
            )],
        )
        
        add(
            "Chest Wall Stretch",
            [
                "Place a palm on a wall so that your arm is raised up at a 45 degree angle.",
                "Turn your torso away from the wall to perform the stretch.",
                "Can use your other hand to help pull your torso away.",
            ],
            [
                (
                    "Video",
                    "https://www.youtube.com/watch?v=PQ7tgOHj9vM&feature=youtu.be&t=30s",
                ),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1",
                ),
            ],
        )
        
        add(
            "Child's Pose",
            [
                "Kneel down.",
                "Extend your arms out and place your palms on the floor.",
                "Keep your head inline with your torso.",
                "Relax.",
            ],
            [("Image", "http://i.imgur.com/UmHztrr.jpg")],
        )
        
        add("Child's Pose with Lat Stretch",
            [
                "Sit down, spread your knees at least three feet apart with your heels touching.",
                "Walk your hands forward and then to the right.",
                "Tilt your hands as if you were pushing a wall away.",
                "Place your head on the mat.",
                "Make the stretch more intense by looking up through the armpit that is towards the middle.",
                "Repeat for the other side."],
            [("Video", "https://www.youtube.com/watch?v=pJcobQf324o"), ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1")],
        )
        
        add(
            "Chin Tucks",
            [
                "Place two fingers at the bottom of your chin.",
                "Tuck your chin down and retract you head backwards.",
                "Hold for 3-5 seconds.",
            ],
            [("Link", "https://backintelligence.com/how-to-fix-forward-head-posture/")],
        )
        
        add("Chin-up",
            [
                "Hands closer than shoulder width. Palms facing in.",
                "Keep elbows close to body and pull until head is even or above the bar.",
                "Slowly lower back down.",
                "Difficulty can be lessened by doing negatives: jump to raised position and very slowly lower yourself.",
                "Difficulty can be increased by attaching plates to a belt."],
            [("Link", "https://columbiaassociation.org/blog/gyms-fitness/how-to-do-a-proper-chin-up/"),
             ("Weighted", "http://relativestrengthadvantage.com/7-ways-to-add-resistance-to-pull-ups-chin-ups-and-dips/"), ("Elbow Pain", "https://breakingmuscle.com/fitness/5-ways-to-end-elbow-pain-during-chin-ups")],
        )
        
        add("Circuit1",
            [],
            [("Link", "https://experiencelife.com/article/the-dumbbell-complex-workout")],
        )
        
        add("Circuit2",
            [],
            [("Link", "https://experiencelife.com/article/the-dumbbell-complex-workout",
            )],
        )
        
        add("Circuit3",
            [],
            [("Link", "https://experiencelife.com/article/the-dumbbell-complex-workout")],
        )
        
        add(
            "Clam",
            [
                "Lay on your side.",
                "Move your hips back about 45 degrees.",
                "Move your knees forward so that they form a 90 degree angle.",
                "Push a knee into the air as far as possible pausing at the top.",
                "Keep your feet touching.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/clam",
            )],
        )
        
        add("Clean and Press",
            [
                "Shoulder width stance with knees inside arms.",
                "Keep back straight and bend knees and hips to grab the bar with arms fully extended.",
                "Use a grip slightly wider than shoulder width with elbows pointed out to sides.",
                "Bar should be close to shins and shoulders over or slightly past the bar.",
                "Begin to pull by extending your knees and, at the same time, raising your shoulders.",
                "As the bar passes your knees extend at the ankles, knees, and hips.",
                "At max elevation your feet should clear the floor and you should enter a squatting position as you pull yourself under the bar (this is dependent upon the weight used).",
                "Rack the bar across the front of your shoulders.",
                "Stand up with the bar in the clean position.",
                "Without moving your feet press the bar overhead."],
            [("Link", "https://www.bodybuilding.com/exercises/clean-and-press")],
        )
        
        add("Close-Grip Bench Press",
            [
                "Lay on a flat bench.",
                "Hands about shoulder width apart.",
                "Slowly lower the bar to your middle chest.",
                "Keep elbows tucked into torso at all times.",
                "Note that failed lifts tend to occur more suddenly than with wide grip bench presses."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/close-grip-barbell-bench-press")],
        )
        
        add("Close-Grip Lat Pulldown",
            ["Use a grip smaller than shoulder width.",
                "Palms facing forward.",
                "Lean torso back about thirty degrees, stick chest out.",
                "Touch the bar to chest keeping torso still.",
                "Squeeze shoulders together.",
            ],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/close-grip-front-lat-pulldown")],
        )
        
        add("Complex - beginner",
            ["[Sumo Deadlift - 10 reps](https://lipsticklifters.com/exercises/bum-exercises/dumbbell-sumo-deadlift/)",
             "[Bent Over Row - 10 reps](https://lipsticklifters.com/exercises/back-exercises/bent-over-row/)",
             "[Goblet Squat - 10 reps](https://lipsticklifters.com/exercises/leg-exercises/goblet-squat/)",
             "[Shoulder Press - 8 reps](https://lipsticklifters.com/exercises/shoulder-exercises/dumbbell-shoulder-press/)",
             "[Lunges - 8 reps/leg](https://lipsticklifters.com/exercises/leg-exercises/lunges/)",
             "Do all of these in order without resting or putting the weight down.",
            ],
            [("Link", "https://lipsticklifters.com/articles/dumbbell-complex/#three-complete-dumbbell-complexe/")],
        )
        
        add("Complex - intermediate",
            ["[Sumo Deadlift - 10 reps](https://lipsticklifters.com/exercises/bum-exercises/dumbbell-sumo-deadlift/)",
             "[Clean - 6 reps](https://lipsticklifters.com/exercises/full-body-exercises/kettlebell-clean/)",
             "[Push Press - 6 reps](https://lipsticklifters.com/exercises/shoulder-exercises/dumbbell-push-press/)",
             "[Lunges - 8 reps/leg](https://lipsticklifters.com/exercises/leg-exercises/lunges/)",
             "[Bent Over Row - 8 reps](https://lipsticklifters.com/exercises/back-exercises/bent-over-row/)",
             "[Swing - 10 reps](https://lipsticklifters.com/exercises/leg-exercises/kettlebell-swing/)",
             "Do all of these in order without resting or putting the weight down.",
            ],
            [("Link", "https://lipsticklifters.com/articles/dumbbell-complex/#three-complete-dumbbell-complexe/")],
        )
        
        add("Cocoons",
            ["Lie down on your back with your arms extended behind your head.",
                "Tuck your knees into your chest.",
                "As you are tucking bring your head up and your hands alongside your knees.",
            ],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/cocoons")],
        )
        
        add("Concentration Curls",
            ["Sit on a flat bench with a dumbbell between your knees.",
                "Place an elbow on your inner thigh with palm facing away from thigh.",
                "Curl the weight.",
                "Keep upper arm stationary.",
                "At the top your pinky should be higher than your thumb.",
                "At the bottom your elbow should have a slight bend.",
            ],
            [("Link", "https://www.hevyapp.com/exercises/concentration-curl/")],
        )
        
        add("Cossack Squat",
            ["Take a wide squat stance with toes pointed out about 45 degrees.",
                "Lower your hips into a deep stretch position.",
                "Slide your hips from side to side keeping the heel you're sliding to on the floor.",
                "The other leg should have the heel on the ground and the toes pointed up.",
                "Back should remain flat and torso more or less upright.",
                "Difficulty can be lessened by balancing yourself with your hands on the ground.",
                "Difficulty can be increased by holding your hands over your chest."],
            [("Video", "https://www.youtube.com/watch?v=tpczTeSkHz0"), ("Gallery", "https://imgur.com/gallery/iEsaS"), ("Notes", "https://www.bodybuilding.com/fun/limber-11-the-only-lower-body-warm-up-youll-ever-need.html")],
        )
        
        add("Couch Stretch",
            ["Kneel down and back both feet up against a wall.",
                "Slide one leg back so that your knee and calf are against the wall.",
                "Bring the other leg out and post it so that your shin is vertical.",
                "Place both hands on the ground and drive your hips forward so that your back forms a straight line with your legs.",
                "Take your hands off the floor and raise your torso so that it is upright keeping your back straight.",
                "Keep abs tight.",
                "Work towards doing this two minutes a day for each leg."],
            [("Link", "http://www.active.com/triathlon/articles/the-stretch-that-could-be-the-key-to-saving-your-knees"), ("Tips", "http://breakingmuscle.com/mobility-recovery/couch-stretch-small-but-important-ways-youre-doing-it-wrong"), ("Video", "https://www.youtube.com/watch?v=JawPBvtf7Qs")],
        )
        
        add("Crunches",
            [
                "Lay flat on your back.",
                "Raise your shoulders about 30 degrees off the ground.",
                "Slowly lower yourself back to the starting position.",
                "See the link for harder variations.",],
            [("Link", "https://seven.app/articles/essentials/exercise-essentials/everything-you-need-to-know-about-crunches")],
        )
        
        add(
            "Cuban Rotation",
            [
                "Hold a stick over head with your arms forming 90 degree angles.",
                "Pull your shoulders back.",
                "Slowly lower the stick until your forearms are parallel with the floor.",
                "Keep your shoulders back.",
            ],
            [("Video", "https://www.youtube.com/watch?v=ie54TYYmwFo")],
        )
        
        add(
            "Deadbugs",
            [
                "Lie on your back with arms held straight up and legs forming a 90 degree angle.",
                "Extend one arm behind you and extend the opposite leg out.",
                "Keep your core braced.",
            ],
            [("Link", "http://www.nick-e.com/deadbug/")],
        )
        
        add("Dead Hang",
            ["Arms should be roughly shoulder width apart.",
                "Keep arms straight and stay relaxed.",
                "Work your way to a 60s hang time."],
            [("Link", "https://www.healthline.com/health/fitness-exercise/dead-hang#how-to")],
        )
        
        add("Deadlift",
            ["Walk to the bar and place feet so that the bar is over the middle of your feet.",
                "Feet should be pointed out ten to thirty degrees.",
                "Feet should be about as far apart as they would be for a vertical jump (hip width not shoulder width).",
                "Bend over and grab the bar keeping hips as high as possible.",
                "When starting to grip the bar position your hands so that the calluses on your palm are just above the bar.",
                "Place your thumb over your fingers.",
                "Pull yourself down and into the bar by engaging lats, upper back, and hip flexors.",
                "Stop once the bar touches your shins, knees touching arms.",
                "Back should be straigh hips fairly high, but seated back as much as possible.",
                "Chest ou back straigh big breath, start pulling.",
                "Keep the bar as close as possible to your legs.",
                "Push with your heels.",
                "As the bar approaches your knees drive forward with your hips.",
                "Never bend arms: all the lifting should be done with legs and back.",
                "Don't shrug or lean back too far at the top.",
                "Can help to switch to a mixed grip for the last warmup and work sets.",
                "Can build grip strength by holding a set for 10-15s."],
            [("Stronglifts", "http://stronglifts.com/deadlift/"),
            ("Thrall Video", "https://www.youtube.com/watch?v=Y1IGeJEXpF4")],
        )
        
        add("Decline Bench Press",
            ["Lay on a bench tilted such that your head is lower than your hips.",
                "Use a medium grip (so that in the middle of the movement your upper and lower arms make a 90 degree angle).",
                "Slowly lower the bar to your lower chest.",
                "A lift off from a spotter will help protect your rotator cuffs."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/decline-barbell-bench-press")],
        )
        
        add("Decline Plank",
            ["Lie prone on a mat keeping elbows below shoulders.",
                "Support your legs using your toes and a bench.",
                "Raise body upwards to create a straight line.",
            ],
            [("Progression", "http://www.startbodyweight.com/p/plank-progression.html")],
        )
        
        add(
            "Decline & March Plank",
            [
                "Lie prone on a mat keeping elbows below shoulders.",
                "Support your legs using your toes and a bench.",
                "Raise body upwards to create a straight line.",
                "Alternate between bringing each knee forward.",
            ],
            [(
                "Progression",
                "http://www.startbodyweight.com/p/plank-progression.html",
            )],
        )
        
        add(
            "Decline Situp",
            [
                "Lie on your back on a decline bench.",
                "Place your hands behind your head, but don't lock your fingers together.",
                "Push your lower back into the bench and raise your shoulders about four inches.",
                "At the top contract your abs and hold for a second.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/decline-crunch",
            )],
        )
        
        add(
            "Deep Step-ups",
            [
                "Place one foot on a high object.",
                "Place all of your weight on that object and step up onto the object.",
                "Use your back leg as little as possible.",
                "Difficulty can be increased by using a higher object or holding a weight.",
            ],
            [
                (
                    "Link",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat",
                ),
                (
                    "Body Weight Squats",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat",
                ),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/playground/deep-step-up",
                ),
                (
                    "Progression",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat",
                ),
            ],
        )
        
        add(
            "Deficit Deadlift",
            [
                "Stand on a platform or a plate or two, typically 1-4 inches off the ground.",
                "Deadlift as usual.",
            ],
            [(
                "Link",
                "https://www.t-nation.com/training/in-defense-of-deficit-deadlifts",
            )],
        )
        
        add("Diamond Pushup",
            ["Move your hands together so that the thumbs and index fingers touch (forming a triangle).",
                "Place your hands directly under your shoulders.",
                "Keep your legs together.",
                "Don't leg your hips sag.",
                "Push off with your feet to lean forward.",
                "Keep your forearms straight up and down the whole time.",
                "Go down until your arms form a ninety degree angle."],
            [("Link", "https://www.youtube.com/watch?v=_4EGPVJuqfA"),
             ("Pushups", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup"),
             ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase2/pushup"),
             ("Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup/#wiki_recommended_progression")],
        )
        
        add("Dips",
            ["Start in the raised position with elbows nearly locked.",
                "Inhale and slowly lower yourself downward.",
                "Lower until elbow hits ninety degrees.",
                "Exhale and push back up.",
                "To work the chest more than triceps lean forward thirty degrees and go a bit deeper.",
            ],
            [("Dips", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/dip")])
        
        add("Donkey Calf Raises",
            ["Either use a donkey calf machine or have someone sit low on your back.",
                "Knees should remain straight but not locked.",
                "Raise heels as high as possible.",
            ],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/donkey-calf-raises")])
        
        add(
            "Doorway Chest Stretch",
            [
                "Stand in front of a doorway.",
                "Raise hands just above shoulders with palms facing forward.",
                "Lean into the doorway supporting yourself with your forearms.",
                "Pinch shoulder blades together.",
                "Difficulty can be increased by using one arm at a time.",
                "Work towards doing three sets for 60s each.",
            ],
            [(
                "Link",
                "http://breakingmuscle.com/mobility-recovery/why-does-the-front-of-my-shoulder-hurt",
            )],
        )
        
        add(
            "Dragon Flag",
            [
                "Lay face up on a bench with your hands holding a support behind your head.",
                "Lift your body until it is above your shoulders.",
                "Slowly lower your body back down.",
                "Keep your body as straight as possible the entire time.",
            ],
            [
                ("Link", "https://www.t-nation.com/training/dragon-flag"),
                ("Video", "https://www.youtube.com/watch?v=njKXkuhY7_0"),
                (
                    "Progression",
                    "http://www.instructables.com/id/How-to-achieve-the-hanging-dragon-flag/",
                ),
            ],
        )
        
        add(
            "Dumbbell Bench Press",
            [
                "Lie flat on a bench.",
                "Rotate dumbbells so your palms are facing your feet.",
                "Move arms to sides so upper and lower arms are at ninety degree angle.",
                "Dumbbells should be just outside of chest.",
                "Raise the dumbbells so that they lightly touch one another above your chest.",
                "After completing the set kick your legs up, place the weights on your thighs, and sit up.",
                "Once you are sitting up you can place the weights on the floor."],
            [
                (
                    "Link",
                    "https://fitbod.me/exercises/dumbbell-bench-press",
                ),
                (
                    "Video",
                    "https://www.youtube.com/watch?v=VmB1G1K7v94",
                ),
                ("Positioning", "https://www.youtube.com/watch?v=1XDxtAOAIrQ"),
            ],
        )
        
        add("Dumbbell Bent Over Row",
            [
                "Hold a dumbbell in both hands with palms facing your torso.",
                "Bend your knees slightly and bend over until your torso is almost parallel with the floor.",
                "Lift the weights to your side keeping your elbows close to your body.",
                "Keep your back straight and your head up."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/bent-over-two-dumbbell-row")],
        )
        
        add(
            "Dumbbell Deadlift",
            [
                "Hands shoulder width or a bit narrower.",
                "Grasp dumbbells so that palms face backwards.",
                "Lower dumbbells to top of feet and then straighten back up.",
                "Keep back and knees straight the entire time.",
                "Keep dumbbells close to legs.",
            ],
            [(
                "Link",
                "https://www.fitandwell.com/how-to/deadlift-with-dumbbells-at-home",
            )],
        )
        
        add(
            "Dumbbell Floor Press",
            [
                "Lay flat on your back with knees raised.",
                "Grasp dumbbells so that palms are facing forward.",
                "Raise dumbbells so that they touch above chest.",
            ],
            [(
                "Link",
                "https://www.youtube.com/watch?feature=player_embedded&v=XtEzJpPR2Zg",
            )],
        )
        
        add(
            "Dumbbell Flyes",
            [
                "Position dumbbells in front of shoulders with palms facing each other.",
                "Raise dumbbells as if you were pressing them but don't lock them out.",
                "With a slight bend in elbows lower dumbbells to sides in a wide arc.",
                "Stop lowering the dumbbells once you feel a stretch in your chest.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/dumbbell-flyes",
            )],
        )
        
        add(
            "Dumbbell Incline Flyes",
            [
                "Position dumbbells in front of shoulders with palms facing each other.",
                "Raise dumbbells as if you were pressing them but don't lock them out.",
                "With a slight bend in elbows lower dumbbells to sides in a wide arc.",
                "Stop lowering the dumbbells once you feel a stretch in your chest.",
                "Shoulders should point down at the bottom and out at the top.",
            ],
            [(
                "Link",
                "https://www.exrx.net/WeightExercises/PectoralClavicular/DBInclineFly",
            )],
        )
        
        add(
            "Dumbbell Incline Press",
            [
                "Lie on your back on a bench so that your head is higher than your hips.",
                "Use your thighs to help push the weights to your shoulders.",
                "Rotate the weights so that your palms are facing your feet.",
                "Raise the weights over your head.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/incline-dumbbell-press",
            )],
        )
        
        add("Dumbbell Incline Row",
            ["Lie on your front on a bench so that your head is higher than your hips.",
                "Hold dumbbells in both hands with your palms facing your torso.",
                "Start with your arms extended and pull the weights to your sides.",
            ],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/dumbbell-incline-row")])
        
        add("Dumbbell Lunge",
            ["Grasp dumbbells so that palms are facing body.",
                "Alternately step forward with each leg.",
                "Lower body until rear knee is almost in contact with the floor.",
                "Longer steps work the glutes more, short lunges work quads more.",
            ],
            [("Link", "https://www.verywellfit.com/how-to-do-dumbbell-lunges-3498297")])
        
        add("Dumbbell One Arm Bench Press",
            [
                "Lie on your back on a flat bench.",
                "Use your though to help position the dumbbell in front of you at shoulder width.",
                "Rotate the weight so that your palm is facing your feet.",
                "Lift the weight up and then back down.",
            ],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/one-arm-dumbbell-bench-press")])
        
        add("Dumbbell One Arm Row",
            [
                "Hinge forward until your torso is roughly parallel with the ground.",
                "Pull the weight back until your elbow is behind your body and your shoulder blade is retracted.",
                "Don't use your other arm to brace."],
            [("Link", "https://www.muscleandstrength.com/exercises/one-arm-dumbbell-row.html")],
        )
        
        add("Dumbbell One Arm Shoulder Press",
            [
                "Stand straight up with feet shoulder width apart.",
                "Raise the dumbbell to head height with elbows extended out and palms facing forward.",
                "Raise the weight to above your head.",
                "Don't use your legs or lean backwards."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/dumbbell-one-arm-shoulder-press")],
        )
        
        add("Dumbbell Pullovers",
            [
                "Grasp a dumbbell with both hands and position yourself with your shoulder blades on a bench.",
                "Back should be straight and knees should be bent at ninety degrees.",
                "Start with the dumbbell over your head.",
                "Keep your arms straight and lower the dumbbell behind your head."],
            [("Link", "https://www.muscleandstrength.com/exercises/dumbbell-pullover.html")],
        )
        
        add("Dumbbell Romanian Deadlift",
            [
                "Stand straight up with a dumbbell in each hand.",
                "Allow your arms to hang down with palms facing backwards.",
                "Push your butt back as far as possible while slightly bending your knees.",
                "Keep your back straight the entire time."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/romanian-deadlift-with-dumbbells")],
        )
        
        add(
            "Dumbbell Seated Shoulder Press",
            [
                "Position dumbbells at shoulders with elbows below wrists.",
                "Press dumbbells upward and lightly tap them together.",
                "Can bounce the dumbbells off thighs to help get them into place.",
            ],
            [(
                "Link",
                "https://www.strengthlog.com/seated-dumbbell-shoulder-press/",
            )],
        )
        
        add("Dumbbell Shoulder Press",
            ["Stand straight up with feet shoulder width apart.",
                "Raise the dumbbells to head height with elbows extended out and palms facing forward.",
                "Raise the weights to above your head.",
                "Don't use your legs or lean backwards.",
            ],
            [("Link", "https://ericrobertsfitness.com/how-to-do-dumbbell-shoulder-press-the-correct-guide/")],
        )
        
        add("Dumbbell Shrug",
            ["Stand straight upright with a dumbbell in each hand.",
                "Palms should face one another.",
                "Light the weights by elevating your shoulders as much as possible.",
                "Avoid using your biceps.",
            ],
            [("Link", "https://exrx.net/WeightExercises/TrapeziusUpper/DBShrug")],
        )
        
        add("Dumbbell Side Bend",
            ["Stand up straight with a dumbbell held in one hand.",
                "Face the hand with the dumbbell so that it is pointed to your torso.",
                "Place your other hand on your hip.",
                "Bend as far towards the weight as you can.",
                "Then bend in the other direction.",
                "Keep your back straight and your head up.",
                "Do the recommended reps, switch hands, and start again.",
            ],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/dumbbell-side-bend")],
        )
        
        add("Dumbbell Single Leg Split Squat",
            ["Grasp dumbbells so that palms are facing inward.",
                "Extend leg backwards and rest foot on a bench or chair.",
                "Squat down until rear knee is almost in contact with the floor.",
                "Return to original standing position.",
                "Difficulty can be increased by using a box or plates to prop up your front foot 2-4 inches."],
            [("Link", "https://weighttraining.guide/exercises/dumbbell-one-leg-split-squat/")],
        )
        
        add(
            "Elliptical",
            [
                "Keep your feet parallel with the edges of the pedals.",
                "Straighten your back.",
                "Bend your knees slightly.",
            ],
            [(
                "Link",
                "https://www.ellipticalreviews.com/blog/how-to-use-an-elliptical-trainer/",
            )],
        )
        
        add(
            "Exercise Ball Back Extension",
            [
                "Lie on your stomach onto an exercise ball.",
                "Shift your position until the ball is just above your hips.",
                "Cross your arms across your chest.",
                "Raise your torso upwards.",
                "Difficulty can be increased by placing your hands behind your head (like a prisoner).",
            ],
            [(
                "Link",
                "https://gethealthyu.com/exercise/stability-ball-back-extension/",
            )],
        )
        
        add(
            "Exercise Ball Crunch",
            [
                "Lie on your lower back on an exercise ball.",
                "Plant your feet firmly on the floor.",
                "Cross your arms across your chest or place them along your sides.",
                "Lower your torso keeping your neck neutral.",
                "Contract your abs to raise your torso.",
                "Difficulty can be increased by placing your hands behind your head (like a prisoner).",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/exercise-ball-crunch",
            )],
        )
        
        add(
            "Exercise Ball Side Crunch",
            [
                "Lie on your lower back on an exercise ball.",
                "Tilt to one side so that you are lying mostly on that side.",
                "Place your hands behind your head.",
                "Contract your abs to raise your torso.",
            ],
            [(
                "Link",
                "https://www.exercise.com/exercises/swiss-ball-oblique-crunch/",
            )],
        )
        
        add("F8",
            [
                "[Overhead Squat](https://barbend.com/overhead-squat)",
                "[Back Squat](http://strengtheory.com/how-to-squat)",
                "[Good Morning](https://www.verywellfit.com/how-to-do-the-good-morning-exercise-with-barbell-3498255)",
                "[Front Squat](https://www.verywellfit.com/how-to-do-a-barbell-front-squat-4842368)",
                "[Rows](http://stronglifts.com/barbell-row)",
                "[Deadlift](http://stronglifts.com/deadlift)"],
            [("Link", "https://www.t-nation.com/training/rebuild-yourself-with-complexes")],
        )
        
        add(
            "Face Pull",
            [
                "Lift a pulley to your upper ches use a rope or a dual handle attachment.",
                "Grab the rope with a neutral grip (palms facing each other).",
                "Keep your chest up, and your shoulders back and down.",
                "Retract your shoulders as you begin to pull back.",
                "Finish in a double bicep pose: upper arms horizontal, hands at upper head height.",
            ],
            [
                (
                    "Link",
                    "https://www.verywellfit.com/face-pulls-exercise-for-stronger-shoulders-4161298",
                ),
                (
                    "Proper Form",
                    "http://seannal.com/articles/training/face-pulls-benefits-proper-form.php",
                ),
                ("Tips", "https://youtu.be/HSoHeSjvIdY"),
            ],
        )
        
        add(
            "Farmer's Walk",
            [
                "Use heavy dumbbells or custom equipment.",
                "Walk, taking short quick steps.",
                "Walk 50-100 feet.",
            ],
            [(
                "Link",
                "https://www.verywellfit.com/how-to-do-a-farmer-carry-techniques-benefits-variations-4796615",
            )],
        )
        
        add(
            "Finger Curls",
            [
                "Sit on a bench and hold a barbell with your palms facing up.",
                "Your hands should be about shoulder width apart.",
                "Allow the bar to roll forward, catching it at the final joint of your fingers.",
                "Lower the bar as far as possible.",
                "Using your fingers raise the bar as far as possible.",
            ],
            [("Link", "https://training.fit/exercise/finger-curls/")],
        )
        
        add("Finger Stretch",
            [
                "Wrap a rubber band around your fingers.",
                "Spread your fingers out.",
                "Do ten reps.",
                "If you're doing Wrist Extension or Flexion then use that arm position."],
            [("AAoS", "https://orthoinfo.aaos.org/globalassets/pdfs/a00790_therapeutic-exercise-program-for-epicondylitis_final.pdf")],
        )
        
        add("Fire Hydrant Hip Circle",
            [
                "Get on your hands and knees.",
                "Keep arms straight.",
                "Raise one leg, pull knee into your but and rotate your knee in a circle.",
                "After circling in one direction do the same in the other direction.",
                "Try and make the biggest circle you can."],
            [("Video", "https://www.youtube.com/watch?v=f-GRxDrMC4Y"), ("Gallery", "https://imgur.com/gallery/iEsaS"), ("Notes", "https://www.bodybuilding.com/fun/limber-11-the-only-lower-body-warm-up-youll-ever-need.html")],
        )
        
        add(
            "Foam Roll Lats",
            [
                "Place a foam roller under your arm pit.",
                "Roll backwards a bit.",
                "Roll back and forth.",
            ],
            [("Link", "https://www.youtube.com/watch?v=mj0Ax-9FehY")],
        )
        
        add("Foam Roll Pec Stretch",
            [
                "Lie down on top of a foam roller with the roller running length wise from your shoulders to your hips.",
                "Extend your hands straight above your chest and then allow them to fall to either side.",
                "Difficulty can be increased by placing the foam roller on a bench so that your arms can be lowered further."],
            [("Link", "http://breakingmuscle.com/mobility-recovery/why-does-the-front-of-my-shoulder-hurt")],
        )
        
        add("Foot Elevated Hamstring Stretch",
            [
                "Stand facing an elevated surface (ideally about 15\" high).",
                "Place one foot onto the surface keeping your knee straight.",
                "The foot on the ground should be pointed straight ahead.",
                "The toes of the elevated foot should be pointed straight upwards (or backwards to also stretch the calf).",
                "Gently lean forward until you feel your hamstrings stretch.",
                "Bend at the waist: don't roll your shoulders forward."],
            [("Link", "https://www.healthpro.ie/inside-exercise/exercise-guide/stretching/stretches-for-swimming/standing-hamstring-stretch-leg-elevated")],
        )
        
        add("Forearm Supination & Pronation",
            [
                "Sit in a chair with your arm resting on a table or your thigh with your palm facing sideways.",
                "To start with use no weight and bend your elbow so that your arm forms a 90 degree angle.",
                "Slowly turn your palm upwards, to the side, down, and back to the side.",
                "Keep your forearm in place the entire time.",
                "Do 30 reps. After you can do 30 reps over two days with no increase in pain increase the weight.",
                "Once three pounds is OK gradually start straightening your arm out."],
            [("Link", "https://www.acefitness.org/education-and-resources/lifestyle/exercise-library/31/wrist-supination-and-pronation/"), ("AAoS", "https://orthoinfo.aaos.org/globalassets/pdfs/a00790_therapeutic-exercise-program-for-epicondylitis_final.pdf")],
        )
        
        add("Forward Lunge Stretch",
            ["Kneel down with one leg forward and the other stretched behind you so that your weight is supported by your forward foot and back knee.",
                "Forward foot should be directly under your knee.",
                "Back leg should be stretched out straight behind you.",
                "If you're having balance problems you may rest your hands on the ground.",
                "Gently lower your hips down and forward."],
            [("Link", "http://www.topendsports.com/medicine/stretches/lunge-forward.htm"), ("Video", "https://www.doyogawithme.com/content/lunge-psoas-stretch")],
        )
        
        add(
            "Freestanding Handstand",
            [
                "Lock out your elbows and knees.",
                "Glue your legs together and point the toes.",
            ],
            [
                (
                    "Link",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/handstand",
                ),
                (
                    "Handstands",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/handstand",
                ),
            ],
        )
        
        add(
            "French Press",
            [
                "Load a barbell or EZ-bar and place it on the ground.",
                "Bend at the knees and grab the bar with palms facing down.",
                "Set your hands 8-12 inches apart.",
                "Stand up with your feet about shoulder width and a slight bend in your knees.",
                "Start with the bar overhead and a slight bend in your elbows.",
                "Lower the bar behind your head keeping your elbows in place.",
                "Raise the bar back to the starting position.",
            ],
            [(
                "Link",
                "https://www.muscleandstrength.com/exercises/french-press.html",
            )],
        )
        
        add("Frog Stance",
            [
                "Use a yoga block, a small box, a think book, or a stair step to elevate your feet.",
                "Stand on the block and squat down.",
                "Keep your knees apart and place your hands on the ground, shoulder width apart.",
                "Balance on your toes and lean forward.",
                "As your body moves forward allow your arms to bend at the elbows.",
                "Once you can do that for 30s lift one foot off the ground towards your butt.",
                "Once that is comfortable lean forward a bit more until the other foot comes off the ground."],
            [("Video", "https://www.youtube.com/watch?v=Hml31hm-Zkg"), ("Notes", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase2")],
        )
        
        add(
            "Front Scale Leg Lifts",
            [
                "Relax your shoulders, lock your legs, keep your back straight.",
                "Extend your arms out to either side.",
                "Point your toes and lift one leg off the ground.",
                "Don't lean back.",
                "Aim for raising your leg to a ninety degree angle.",
                "Raise and lower your leg and, on the last lif hold for a bit.",
            ],
            [("Video", "https://www.youtube.com/watch?v=ilBByuwM8hk")],
        )
        
        add("Front Squat",
            [
                "Bring arms up under the bar so that the bar rests on your deltoids (uppermost part of arms).",
                "Elbows should be very high.",
                "May have more control of the bar by crossing forearms.",
                "Unless you are very flexible there is no reason to actually grip the bar.",
                "Feet shoulder width apart with toes slightly pointed out.",
                "Go down slowly until thighs break parallel with the floor.",
                "Go up quickly."],
            [("Link", "https://www.verywellfit.com/how-to-do-a-barbell-front-squat-4842368"),
             ("25 Tips", "http://breakingmuscle.com/strength-conditioning/when-in-doubt-do-front-squats-25-tips-for-better-front-squats")],
        )
        
        add("Gliding Leg Curl",
            [
                "Hang from something like a bar on a squat rack.",
                "Prop your feet up on a low stool or chair.",
                "Push your heels into the floor and lift your hips off the floor.",
                "When in position your butt should be off the floor and your torso and legs should form a ninety degree angle.",
                "Flex your hips up as high as possible.",
                "Once you reach the high point swing your entire body forward."],
            [("Video", "https://www.youtube.com/watch?v=KlCOhWuPGBU")],
        )
        
        add(
            "Glute Bridge",
            [
                "Lie on your back with your hands to your sides and your knees bent.",
                "Move feet about shoulder width apart.",
                "Push your heels into the floor and lift your hips off the floor.",
                "Hold at the top for a second.",
                "Keep your back straight.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/butt-lift-bridge",
            )],
        )
        
        add("Glute Ham Raise",
            [
                "Similar to a back extension except feet are placed between rollers and braced against a plate."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/glute-ham-raise")],
        )
        
        add(
            "Glute March",
            [
                "Rest your shoulders on top of a low bench.",
                "Elevate your hips so that your body is in a straight line.",
                "Raise one foot high into the air and then the other.",
            ],
            [("Link", "https://bretcontreras.com/the-glute-march/")],
        )
        
        add(
            "Goblet Squat",
            [
                "Hold a dumbbell or kettlebell close to your chest.",
                "Squat down until your thighs touch your calves.",
                "Keep your chest up and your back straight.",
                "Keep your knees out (can push them out at the bottom using your elbows).",
            ],
            [(
                "Link",
                "https://www.verywellfit.com/how-to-goblet-squat-4589695",
            ),
             (
                "Video",
                "https://www.youtube.com/watch?v=MeIiIdhvXT4",
             )],
        )
        
        add("GMB Wrist Prep",
            [
                "Finger Pulses: bounce fingers up and down.",
                "Palm Pulses: palms down, fingers opened, raise wrists up and down.",
                "Side to Side Palm Rotations: palm down, fingers opened, roll palm from side to side.",
                "Front Facing Elbow Rotations: palm down, fingers opened, rotate arm left and right.",
                "Side to Side Wrist Stretch: palms down facing to sides, move whole body side to side.",
                "Rear Facing Wrist Stretch Palms Down: palms facing knees, rock your body forward and backward.",
                "Rear Facing Wrist Stretch Palms Up: palms facing knees, rock your body forward and backward.",
                "Rear Facing Elbow Rotations: palms down facing knees, rotate elbows left and right.",
                "Forward Facing Wrist Stretch: palms down facing forward, rock your body forward and backward."],
            [("Video", "https://www.youtube.com/watch?v=mSZWSQSSEjE")],
        )
        
        add(
            "Good Morning",
            [
                "Begin standing with the bar on your back as if you were doing a low bar squat.",
                "Bend until your torso is parallel to the floor.",
                "Keep back straight and knees slightly bent.",
            ],
            [(
                "Link",
                "https://www.verywellfit.com/how-to-do-the-good-morning-exercise-with-barbell-3498255",
            )],
        )
        
        add(
            "Hack Squat",
            [
                "Stand up straight with a barbell held behind you.",
                "Feet at shoulder width.",
                "Squat until thighs are parallel with the floor, keep head up and back straight.",
                "Go back up by pressing heels into the floor using quads.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/barbell-hack-squat",
            )],
        )
        
        add(
            "Half-kneeling Cable Anti-Rotation Press",
            [
                "Attach a straight bar to a low pulley.",
                "Kneel on one leg facing away from the pulley.",
                "Extend one arm all the way forward.",
                "Bring it back and extend the other arm all the way forward.",
            ],
            [("Video", "https://www.youtube.com/watch?v=k--dW53UQWs")],
        )
        
        add(
            "Hammer Curls",
            [
                "Stand straight upright with a dumbbell in each hand.",
                "Keep elbows close to your torso and palms facing inwards.",
                "Using only your forearms curl both dumbbells.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/hammer-curls",
            )],
        )
        
        add(
            "Hammer Strength Chest Press",
            [
                "Adjust the seat so that the handles are just below shoulder level.",
                "Grip the handles with palms down and with a width that keeps your arms straight.",
                "Don't allow your wrist to bend backwards.",
                "Retract your shoulder blades by pinching them together.",
                "Keep your shoulder blades retracted and extend your arms out.",
            ],
            [(
                "Link",
                "https://www.regularityfitness.com/hammer-strength-chest-press/",
            )],
        )
        
        add("Hamstring Lunge Stretch",
            [
                "Get on your hands and knees and extend your right leg out in front of you.",
                "Support yourself with your left hand on the ground.",
                "Wrap your right arm below your extended leg above the knee.",
                "Lean your torso into the extended leg. Keep your back straight.",
                "Slowly push your foot away.",
                "Once your foor is extended as far as you are comfortable with you can enhance the stretch by driving your heel into the ground.",
                "Repeat for the opposite side."],
            [("Video", "https://www.youtube.com/watch?v=CrF2iMnn09w&feature=youtu.be"), ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1")],
        )
        
        add(
            "Handstand",
            [
                "Place hands on the ground, shoulder width apar and with fingers spread.",
                "Hands should point forward: not turned inward.",
                "Keep a slight bend to elbows.",
            ],
            [
                ("Tutorial", "https://gmb.io/handstand/"),
                ("Bailing", "https://www.youtube.com/watch?v=P_h4rUJnJTY"),
                (
                    "Wall Assisted",
                    "https://www.womenshealthmag.com/fitness/a19918535/how-to-do-a-handstand/",
                ),
                ("Kicking Up", "https://www.youtube.com/watch?v=JcXy4wzCF50"),
                (
                    "Progression1",
                    "https://www.artofmanliness.com/articles/build-ability-full-handstand/",
                ),
                (
                    "Progression2",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase4/handstand",
                ),
            ],
        )
        
        add("Handstand Pushup",
            ["Get into a wall handstand about a foot from the wall. Hands should be shoulder width or a little wider.",
                "Lower yourself until your forehead touches the floor and raise yourself back up."],
            [("Video", "https://www.youtube.com/watch?v=5Vs-hk74zOQ"), ("Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase3/hspu")],
        )
        
        add("Hanging Dragon Flag",
            ["Grab a pole with both hands.",
                "Brace your shoulders against the poll just below your hands.",
                "Extend your body so that it is parallel to the ground.",
            ],
            [("Progression", "http://www.instructables.com/id/How-to-achieve-the-hanging-dragon-flag/")],
        )
        
        add("Hanging Leg Raise",
            ["Hang from a bar with a wide or medium grip.",
                "Raise your legs so that your thighs make a 90 degree angle with your torso.",
                "Bend your knees as you raise your legs.",
                "Slowly lower your legs back down.",
                "Difficulty can be increased by holding a dumbbell between your feet.",
            ],
            [("Link", "https://www.muscleandstrength.com/exercises/hanging-leg-raise.html")],
        )
        
        add("Heel Pulls",
            ["Get into a handstand with your toes touching a wall.",
                "Squeeze your fingers into the ground and allow your toes to come off the wall."],
            [("Video", "https://www.youtube.com/watch?v=OYehg2ruMN0"),
                ("Handstand Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase4/handstand")],
        )
        
        add("HIIT",
            ["Do a 3-4 min warmup at low to moderate intensity of whatever exercise you're doing.",
                "Do 6-10 sets of 60/60, 30/60, 30/30, 20/10 seconds of high/low intensity.",
                "Do a 3-4 min cooldown at low intensity."],
            [("Guide", "https://www.reddit.com/r/hiit/wiki/beginners_guide"),
                ("FAQ", "https://www.reddit.com/r/hiit/wiki/faq")],
        )
        
        add("High bar Squat",
            ["Bar goes at the top of shoulders at the base of the neck.",
                "Brace core and unrack the bar.",
                "Toes slightly pointed outward.",
                "Push hips back slightly, chest forward, and squat down.",
                "Keep bar over the middle of your feet.",
                "High bar depth is typically greater than low bar depth.",
                "If your neck gets sore the bar is in the wrong position.",
            ],
            [("Link", "https://squatuniversity.com/2016/03/18/how-to-perfect-the-high-bar-back-squat-2/"),
                ("Video", "https://www.youtube.com/watch?v=lUGpa_Wz2gs")],
        )
        
        add("Hip Flexor Lunge Stretch",
            ["Get on your hands and knees and extend your right leg out in front of you.",
                "Make sure your extended foot is in front of your knee.",
                "Square your hips by rotating your right hip back and your left hip forward.",
                "Place one hand below your belly button and the other on your tail bone and use them to bring the front of your hips up and your backside down.",
                "Bend the front knee.",
                "Raise your hands above your head.",
                "Repeat with the opposite side."],
            [("Video", "https://www.youtube.com/watch?v=UGEpQ1BRx-4"), ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1")],
        )
        
        add(
            "Hip Hinge with Dowel",
            [
                "Place a dowel or rod along the center line of your back.",
                "Support the dowel with one hand on your lower back and another at head height.",
                "Stand up straight and use your hips to bend down.",
                "Keep knees slightly bent.",
                "Keep back straight: dowel should only contact you at hips, shoulders, and head.",
            ],
            [("Video", "https://www.youtube.com/watch?v=gwN_nXKVXXI")],
        )
        
        add("Hip Thrust",
            [
                "Load the bar up with either 45 pound plates or bumper plates.",
                "Sit down in front of a low bench.",
                "Roll the barbell over your feet and then your legs until it is at your hips.",
                "Scoot your shoulders back so that they are supported on the bench.",
                "Bring your feet back so that your shins will be vertical when the bar is raised.",
                "Use your hips to raise the bar in a smooth motion.",
                "Keep your head in a neutral position: don't tilt it forward.",
                "Hands can be used to either help support yourself on the bench or to help control the bar."],
            [("Link", "https://bretcontreras.com/how-to-hip-thrust/"), ("Positioning", "https://bretcontreras.com/get-bar-proper-position-hip-thrusts/"), ("Video", "https://www.youtube.com/watch?v=mvBTGx5zu5I"), ("Form Video", "https://www.youtube.com/watch?v=LM8XHLYJoYs")],
        )
        
        add(
            "Hip Thrust (constant tension)",
            [
                "This is exactly like an ordinary hip thrust except that you only go about half-way down."],
            [
                (
                    "Link",
                    "https://bretcontreras.com/the-evolution-of-the-hip-thrust/",
                ),
                (
                    "Normal Hip Thrust",
                    "https://bretcontreras.com/how-to-hip-thrust/",
                ),
            ],
        )
        
        add("Hip Thrust (isohold)",
            [
                "This is exactly like an ordinary hip thrust except that you hold the top position for an extended period."],
            [("Video", "https://www.youtube.com/watch?v=DdmW_MFN_jo"), ("Normal Hip Thrust", "https://bretcontreras.com/how-to-hip-thrust/")],
        )
        
        add("Hip Thrust (rest pause)",
            [
                "This is exactly like an ordinary hip thrust except that you pause once or twice in the middle of each set."],
            [("Link", "https://bretcontreras.com/random-thoughts-12/"), ("Normal Hip Thrust", "https://bretcontreras.com/how-to-hip-thrust/")],
        )
        
        add(
            "Hollow Body Hold",
            [
                "Lie on your back.",
                "Drive legs into floor, arch back, and retract shoulders.",
                "Lower bar to sternum.",
                "Keep elbows slightly in.",
            ],
            [
                ("Link", "http://gymnasticswod.com/content/hollow-body"),
                ("Video", "https://www.youtube.com/watch?v=LlDNef_Ztsc"),
                (
                    "Antranik",
                    "https://www.youtube.com/watch?v=44ScXWFaVBs&feature=youtu.be&t=3m34s",
                ),
            ],
        )
        
        add(
            "Horizontal Rows",
            [
                "Setup using something like a pull-up bar and optionally a low stool for your feet.",
                "Pull your body into the bar and then allow it to move back down.",
                "Keep your body straight.",
                "Arms should be straight at the bottom.",
                "Don't let your shoulders shrug up.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=dvkIaarnf0g"),
                (
                    "Body Weight Rows",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/row",
                ),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase2/row",
                ),
            ],
        )
        
        add("Ido's Squat Routine",
            [
                "1. Start with knee push, 10-20 reps per side: squat down and use your hands to push your knees out.",
                "2. Hold knee ou 10-30s per side.",
                "3. Sky reaches, 10-30 reps per side: hold an ankle with one hand and extend the other elbow as high as possible and raise arm skyward.",
                "4. Static pause, 10-30s per side: sky reach with a pause at the top.",
                "5. Buddha Prayers, 10-30 reps: wedge knees apart with elbows and place hands together, Raise and lower hands, Optionally go fist to fist.",
                "6. Squat Bows, 10-30 reps: place hands on top of each other with thumbs up. Lean forward until your head touches your hand. Optionally keep thumbs down.",
                "7. Paused Bow, 10-30s."],
            [("Video", "https://www.youtube.com/watch?v=lbozu0DPcYI"), ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase2")],
        )
        
        add("Incline Bench Press",
            [
                "Use a bench incline such that your head is higher than your hips.",
                "Drive legs into floor, arch back, and retract shoulders.",
                "Lower bar to sternum.",
                "Keep elbows slightly in."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/barbell-incline-bench-press-medium-grip")],
        )
        
        add(
            "Incline Cable Flye",
            [
                "Position a bench between two low pulleys.",
                "Grab the cable attachments and bring your hands above your head.",
                "Lower your hands until you feel a stretch in your chest.",
                "Keep elbows slightly bent.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/incline-cable-flye",
            )],
        )
        
        add(
            "Incline Dumbbell Bench Press",
            [
                "Sit on an incline bench with a dumbbell in each hand.",
                "Start with the dumbbells on your thighs with your palms facing each other.",
                "Use your thighs to help lift the weights to just above your shoulders.",
                "Rotate the dumbbells so that your palms are facing your feet.",
                "Raise the dumbbells out and lock your arms.",
                "Slowly lower the weights and repeat.",
                "After completing a set put the dumbbells onto your thighs and then onto the floor.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/incline-dumbbell-press",
            )],
        )
        
        add("Incline Dumbbell Curl",
            [
                "Sit on an incline bench with a dumbbell in each hand.",
                "Keep your elbows close to your torso and rotate the dumbbells so that your palms are facing your feet.",
                "Curl the weights keeping your upper arms stationary."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/incline-dumbbell-curl")],
        )
        
        add(
            "Incline Pushup",
            [
                "Extend your arms and place both hands on a table or some other support.",
                "Walk your feet backward.",
                "Lower yourself until your chest touches the support and and then push yourself away.",
                "Difficulty can be increased by using a lower platform.",
                "Keep your body in a straight line.",
                "Lock out arms and push shoulders forward.",
                "Keep elbows in, don't let them flare outwards from your torso."],
            [
                (
                    "Link",
                    "https://www.youtube.com/watch?v=4dF1DOWzf20&feature=youtu.be&t=3m56s",
                ),
                (
                    "Pushups",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup",
                ),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase2/pushup",
                ),
                ("Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup/#wiki_recommended_progression"),
            ],
        )
        
        add("Incline Rows",
            [
                "Grab onto something that will support you and also allow you to be between vertical and horizontal.",
                "Pull your body into the support and then allow it to move back.",
                "Difficulty can be increased by using a support that will allow you to get more horizontal.",
                "Keep your body straight and elbows in.",
                "Arms should be straight at the bottom.",
                "Don't let your shoulders shrug up."],
            [("Link", "https://www.youtube.com/watch?v=tDUWmbzs154"), ("Body Weight Rows", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/row"), ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase2/row")],
        )
        
        add(
            "Intermediate Shrimp Squat",
            [
                "Stand straight up with your hands stretched out in front of you.",
                "Raise one leg so that your shin is above parallel to the floor.",
                "Squat down until your elevated leg touches down at the knee, but not at the toes.",
                "If you're having trouble balancing you can hold onto a support.",
            ],
            [
                (
                    "Video",
                    "https://www.youtube.com/watch?v=TKt0-c83GSc&feature=youtu.be&t=3m9s",
                ),
                (
                    "Progression",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat",
                ),
            ],
        )
        
        add("Inverted Row",
            [
                "Position a bar in a rack about waist height. A smith machine or a pull-up bar are also suitable.",
                "Scoot underneath the bar and grip it with hands wider than your shoulders.",
                "Keep your heels on the ground and hang with arms fully extended.",
                "Flex your elbows and pull your chest to the bar.",
                "Difficulty can be lessened by bending your knees or by increasing the angle your torso forms to the ground."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/inverted-row"), ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/row")],
        )
        
        add(
            "IT-Band Foam Roll",
            [
                "Lie on your side using your arms to support your upper body.",
                "Place the outside of your thigh on the foam roller.",
                "Slowly roll up and down and side to side.",
                "Pause on areas that are especially tender until they feel better.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/iliotibial-tract-smr",
            )],
        )
        
        add("Jump Squat",
            [
                "Stand with arms by your side and feet shoulder width apart.",
                "Keeping back straight and chest up, squat until thighs are parallel or lower to the floor.",
                "Press with the balls of your feet and jump into the air as high as possible.",
                "Immediately repeat."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/jump-squat")],
        )
        
        add("Kettlebell One-Legged Deadlift",
            [
                "Hold a kettlebell in one hand.",
                "Move the leg opposite the weight behind you.",
                "Bend at the waist and lower the kettlebell to the ground.",
                "Reverse the motion to raise the kettlebell.",
                "Throughout keep the knee supporting you slightly bent."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/kettlebell-one-legged-deadlift")],
        )
        
        add("Kettlebell Two Arm Swing",
            [
                "Stand behind a kettlebell with feet slightly more than shoulder width apart.",
                "Bend at the hips and lift the kettlebell with palms facing you.",
                "Drive hips forward and swing the weight up until your arms are parallel to the floor (or a bit past).",
                "Allow the weight to fall back between your legs.",
                "Keep your back straight.",
                "Knees can bend a bit."],
            [("Link", "http://www.exrx.net/WeightExercises/Kettlebell/KBTwoArmSwing.html")],
        )
        
        add(
            "Kneeling Plank",
            [
                "Lie prone on a mat keeping elbows below shoulders.",
                "Raise upper body upwards to create a straight line.",
                "Keep your knees on the ground.",
            ],
            [
                (
                    "Link",
                    "http://www.exrx.net/WeightExercises/RectusAbdominis/BWFrontPlank.html",
                ),
                (
                    "Progression",
                    "http://www.startbodyweight.com/p/plank-progression.html",
                ),
            ],
        )
        
        add(
            "Kneeling Shoulder Rolls",
            [
                "Lie prone on a mat keeping elbows below shoulders.",
                "Raise upper body upwards to create a straight line.",
                "Keep your knees on the ground.",
            ],
            [
                (
                    "Link",
                    "http://www.exrx.net/WeightExercises/RectusAbdominis/BWFrontPlank.html",
                ),
                (
                    "Progression",
                    "http://www.startbodyweight.com/p/plank-progression.html",
                ),
            ],
        )
        
        add(
            "Kneeling Side Plank",
            [
                "Get on your side with your knees bent behind you.",
                "Raise your upper torso off the ground using one arm.",
            ],
            [
                (
                    "Link",
                    "http://www.exrx.net/WeightExercises/RectusAbdominis/BWFrontPlank.html",
                ),
                (
                    "Progression",
                    "http://www.startbodyweight.com/p/plank-progression.html",
                ),
            ],
        )
        
        add("Kroc Row",
            [
                "Bend at the waist and use one arm to grip a suppor if using a bench place one knee on the bench.",
                "Using your other arm bring a dumbbell from the floor all the way back.",
                "At the bottom allow your shoulders to roll forward, at the top retract.",
                "Keep your shoulders higher than your hips, your back should be at a 15 degree angle to the floor.",
                "Pull the dumbbell in a straight line from directly below your chest to the lower part of your rib cage.",
                "It's OK to do less than the full ROM as you fatigue and to do these to failure."],
            [("Link1", "https://www.setforset.com/blogs/news/kroc-rows"), ("Link2", "https://www.t-nation.com/training/kroc-rows-101"), ("Video", "https://www.youtube.com/watch?v=D7jAIdoORxI")],
        )
        
        add("L-sit",
            [
                "Sit with your legs stretched out before you on the floor.",
                "Place your palms down on the floor a bit in front of your butt with your fingers pointed forward.",
                "Use your palms to raise your entire body off the floor keeping your legs extended out.",
                "Depress your shoulders, i.e. keep them down not at your ears.",
                "Target should be 60s. If you cannot do an L-sit for that long use the progression:",
                "1) Foot supported: leave your feet on the ground.",
                "2) One-foot supported: raise one leg off the ground.",
                "3) Tuck legs: bend knees about 90 degrees. Hands slightly in front of your butt.",
                "4) Slightly tuck legs: as above but bend your knees less.",
                "5) Full L-sit.",
                "When progressing use multiple sets to reach 60s as needed."],
            [("Pictures", "https://bit.ly/2MEkeBB"), ("L-sits", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/l-sit"), ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/l-sit")],
        )
        
        add(
            "L-sit pull-up",
            [
                "Hold your legs extended straight outward from your body.",
                "Do a pull-up.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=quFBLtkxMRM"),
                (
                    "Pullups",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pullup",
                ),
            ],
        )
        
        add(
            "Landmine 180's",
            [
                "Position a barbell into a landmine or a corner.",
                "Load plates onto one end.",
                "Raise the bar to shoulder height with both hands extended before you.",
                "Take a wide stance.",
                "Rotate the bar from side to side by rotating your trunk and hips.",
                "Keep your arms extended throughout.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/landmine-180s",
            )],
        )
        
        add(
            "Lat Pulldown",
            [
                "Use grip wider than shoulder width.",
                "Palms facing forward.",
                "Lean torso back about thirty degrees, stick chest out.",
                "Touch the bar to chest keeping torso still.",
                "Squeeze shoulders together.",
            ],
            [(
                "Link",
                "https://www.verywellfit.com/how-to-do-the-lat-pulldown-3498309",
            ),
             (
                "Video",
                "https://www.youtube.com/watch?v=AOpi-p0cJkc",
             )],
        )
        
        add(
            "Lat Stretch",
            [
                "Raise your arm overhead and grab a door frame or other support.",
                "Crouch down so that your arm straightens out.",
                "Force your hip out so that your body forms a bow.",
                "Try to take every bit of slack out.",
                "Can also cycle between pulling your shoulder back and forth.",
            ],
            [("Video", "https://www.youtube.com/watch?v=UYjABf_RAcM")],
        )
        
        add(
            "Leg Extensions",
            [
                "Adjust pads so that they lie on your legs just above your feet.",
                "Legs should be at a 90 degree angle (less is hard on the knees).",
                "Extend legs to the maximum.",
                "Keep body stationary.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/leg-extensions",
            )],
        )
        
        add("Leg Lift (intro)",
            [
                "Lie down with legs slightly apart and palms under your thighs.",
                "Lift your left leg, bending at the hip and the knee, while also lifting your head from the floor.",
                "Lower leg and repeat with the right leg (one rep includes both legs)."],
            [("Link", "https://www.fourmilab.ch/hackdiet/e4/")],
        )
        
        add(
            "Leg Lift Plank",
            [
                "Adopt the normal front plank position.",
                "Raise one leg so that it is parallel to the floor.",
                "Halfway through switch up your legs.",
            ],
            [(
                "Progression",
                "http://www.startbodyweight.com/p/plank-progression.html",
            )],
        )
        
        add(
            "Leg Press",
            [
                "Feet at shoulder width.",
                "Torso and legs should be ninety degrees apart.",
                "Push until legs are fully extended but **don't lock knees**.",
                "Lower platform until upper and lower legs make a ninety degree angle.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/leg-press",
            )],
        )
        
        add("Leg Swings",
            ["Hold onto a pole or some other support with one hand.",
                "Extend the other arm all the way out from your side.",
                "Cross one leg across the other and then kick it up towards your outstretched arm.",
                "Then move one leg behind you and kick towards your front.",
            ],
            [("Link", "https://www.youtube.com/watch?v=AkqakLhh1fI&feature=youtu.be")],
        )
        
        add("Low bar Squat",
            ["Hands should be as close together as possible without pain or discomfort.",
                "Bar goes as far down as it can go without sliding downwards.",
                "Wrists should be straight and thumbs above the bar.",
                "Elbows should be up.",
                "Feet should be roughly shoulder width apart and pointed out 15-30 degrees.",
                "Knees should remain over feet during the squat.",
                "Head should be in a neutral position or slightly angled down.",
                "Keep core braced during the squat (a belt can help with this).",
                "Go low enough that your thighs break parallel (or even lower if flexible enough).",
                "When starting the ascent drive shoulders back so the bar remains over mid-foot.",
                "Can help to try to screw heels inward.",
            ],
            [("The Definitive Guide", "https://stronglifts.com/squat/"),
                ("Stronglifts", "http://stronglifts.com/squat/"),
                ("Candito Video", "https://www.youtube.com/watch?v=zoZWgTrZLd8"),
                ("Problems", "https://www.trainuntamed.com/fix_your_squat/"),
            ],
        )
        
        add("Lying External Rotation",
            ["Lie down on your side with your injured arm on top.",
                "Rest your head against your other arm and bend your knees.",
                "Bend the injured arm ninety degrees with your hand down and palm facing your body.",
                "Keep your elbow tucked against your body and raise your forearm until it's parallel with the ground.",
                "Slowly lower your arm back down.",
                "Difficulty can be used by using a very light weight."],
            [("Link", "https://www.healthline.com/health/fitness-exercise/bicep-tendonitis-exercises"), ("Picture", "https://bodybuilding-wizard.com/wp-content/uploads/2015/03/side-lying-dumbbell-external-rotation-3-1.jpg")],
        )
        
        add(
            "Lying Leg Curls",
            [
                "Lay on your back on a bench with your legs hanging off the end.",
                "Place hands either under your glutes palms down or on the sides holding the bench.",
                "Raise your legs until the make a 90 degree angle with the floor.",
                "Slowly lower your legs so that they are parallel to the floot.",
                "Keep your legs straight at all times, but don't lock your knees.",
            ],
            [(
                "Link",
                "https://www.verywellfit.com/how-to-properly-execute-the-leg-curl-exercise-3498304",
            )],
        )
        
        add(
            "Lying Leg Raise",
            [
                "Adjust the machine so that the pad is a few inches below your calves.",
                "Grab the handles and point your toes straight.",
                "Curl legs upwards as far as possible without moving upper legs from the pad.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/flat-bench-lying-leg-raise",
            )],
        )
        
        add(
            "Lying Straight Leg Raise",
            [
                "Lay on your back on a bench or mat.",
                "Place your hands underneath your bottom to help support yourself.",
                "Keep your knees straight and raise your legs to a vertical position.",
                "Use slow and controlled movements.",
                "Can be made easier by bending the knees.",
                "Also can be made easier by using a mat and allowing heels to touch the ground.",
            ],
            [
                (
                    "Link",
                    "http://www.exrx.net/WeightExercises/HipFlexors/BWStraightLegRaise.html",
                ),
                (
                    "Progression",
                    "http://www.startbodyweight.com/p/leg-raises-progression.html",
                ),
            ],
        )
        
        add(
            "LYTP",
            [
                "**L** Raise elbows back and rotate forearms forward and backward.",
                "**Y** Raise arms upward keeping them about 45 degrees from head.",
                "**T** Raise arms upward keeping them 90 degrees from body.",
                "**P** Position arms so that they and your torso form a W. Bring elbows back. Pinkies up.",
                "Keep weights ligh typically three pounds or less."],
            [("Video", "https://www.youtube.com/watch?v=VyBJQQz3eok")],
        )
        
        add(
            "Machine Bench Press",
            [
                "Palms down grip.",
                "Lift arms so that upper arms are parallel to the floor.",
                "Push handles out.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/machine-bench-press",
            )],
        )
        
        add(
            "Medicine Ball Slam",
            [
                "Hold the ball with both hands.",
                "Stand with feet shoulder width apart.",
                "Raise the ball above your head.",
                "Slam it down in front of you as hard as you can.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/overhead-slam",
            )],
        )
        
        add(
            "Military Press",
            [
                "Grip the bar with palms facing out slightly wider than shoulder width.",
                "Place the bar on your collar bone.",
                "Lift it overhead without moving your hips (as you would with an OHP).",
            ],
            [(
                "Link",
                "https://www.muscleandstrength.com/exercises/military-press.html",
            )],
        )
        
        add("Mountain Climber",
            [
                "Get into a pushup position with hands a bit closer than normal.",
                "Keep arms straight.",
                "Bring one leg up and plant your foot outside your arm.",
                "Sink back leg down and repeat with other leg."],
            [("Video", "https://www.youtube.com/watch?v=flT4TIMYvzI"), ("Gallery", "https://imgur.com/gallery/iEsaS"), ("Notes", "https://www.bodybuilding.com/fun/limber-11-the-only-lower-body-warm-up-youll-ever-need.html")],
        )
        
        add("Negative Handstand Pushup",
            [
                "Get into a wall handstand about a foot from the wall. Hands should be shoulder width or a little wider.",
                "Slowly lower yourself (take up to 10s).",
                "Once your forehead touches the floor roll out."],
            [("Video", "https://www.youtube.com/watch?v=Lj2KZwbr_jo"), ("Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase3/hspu")],
        )
        
        add("Neck Flexion",
            [
                "Tuck your chin down using two fingers.",
                "Place your other hand on the back of your head and pull down.",
                "Hold for 20-30s once you feel a stretch on the back of your neck."],
            [("Link", "https://backintelligence.com/how-to-fix-forward-head-posture/")],
        )
        
        add(
            "Oblique Crunches",
            [
                "Lie on your back with your feet elevated.",
                "Place one hand behind your head and the other on the floor along your side.",
                "Elevate your body until your raised elbow touches your knee.",
                "Switch hands.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/oblique-crunches",
            )],
        )
        
        add("One-Arm Kettlebell Snatch",
            [
                "Place a kettlebell between your feet.",
                "Bend your knees and push your butt back.",
                "Look straight ahead and swing the kettlebell backwards.",
                "Immediately reverse direction and use your knees and hips to accelerate the kettlebell.",
                "As the kettlebell reaches your shoulders punch upwards and lock it out overhead."],
            [("Link", "https://www.bodybuilding.com/exercises/one-arm-kettlebell-snatch"), ("Technique", "https://www.girlsgonestrong.com/blog/strength-training/how-to-do-a-kettlebell-snatch/")],
        )
        
        add("One-Arm Pec Stretch",
            [
                "Stand close to a wall and stretch one arm out behind you.",
                "Palm should be on the wall.",
                "Pull in your stomach but don't arch back.",
                "Lean forward and slightly away from your extended arm.",
                "Tweak the angle if don't feel a stretch in your chest."],
            [("Link", "https://backintelligence.com/how-to-fix-forward-head-posture/")],
        )
        
        add("One-Handed Hang",
            [
                "With your palm facing away from you grab a chin-up bar.",
                "Keep your feet on the ground or on a support so that you're not supporting quite all of your weight.",
                "Hold that position."],
            [("Link", "https://www.bodybuilding.com/exercises/one-handed-hang")],
        )
        
        add("One-Legged Cable Kickback",
            ["Hook a cuff to a low cable pulley.",
                "Face the machine from about two feet away.",
                "Hold the machine to stay balanced.",
                "Kick the leg with the cuff backwards as high as it will comfortably go."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/one-legged-cable-kickback")],
        )
        
        add("One-Leg DB Calf Raises",
            ["Hold a dumbbell in one hand.",
                "With your leg on that side place the balls of your foot on a step.",
                "Hook your other leg behind the foot on the step.",
                "Drop your heel as far as possible.",
                "Keep your body straigh eyes forward, and raise your heel as far as possible.",
                "Pause and slowly lower your heel as far as possible.",
                "You can use your arm on the other side to support yourself.",],
            [("Link", "https://www.muscleandstrength.com/exercises/standing-one-leg-calf-raise-with-dumbbell.html")],
        )
        
        add("Overhead Press",
            ["Grip should be narrow enough that forearms are vertical at the bottom.",
                "Bar should be on the base of the palms, close to wrist.",
                "Keep wrists straight.",
                "Elbows should start under the bar and touching your lats.",
                "Feet about shoulder width apar pointed slightly out.",
                "Legs should be locked at all times.",
                "Lift chest by arching upper back.",
                "Lean backward a bit to allow the bar to clear your head and then forward once it is past your head.",
                "Stay tight by bracing your abs and squeezing your glutes together.",
                "Shrug shoulders upward at the top (this is important to prevent impingement)."],
            [("Stronglifts", "http://stronglifts.com/overhead-press/"),
             ("Rippetoe Video", "https://www.youtube.com/watch?v=tMAiNQJ6FPc")],
        )
        
        add("Overhead Pull Down (band)",
            ["Hold the band overhead and make it taut.",
                "Rotate your arms down to your side so that the band stretches outwards.",
                "The band should come down behind your back.",
                "Keep your arms straight the entire time."],
            [("Link", "https://www.youtube.com/watch?v=8lDC4Ri9zAQ&feature=youtu.be&t=4m22s")],
        )
        
        add("Pallof Press",
            ["Attach a band to a support.",
                "Grab the band with both hands and turn your body to the side.",
                "Thrust the band outwards and then back in.",
                "Keep core braced and back straight.",
                "Chin tucked and knees slightly bent.",
                "Arms stay tight beside ribs."],
            [("Video", "https://www.youtube.com/watch?v=AH_QZLm_0-s")],
        )
        
        add("Parallel Bar Support",
            ["Arms straight.",
                "Body straight or slightly hollow.",
                "Depress the shoulders."],
            [("Link", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/support"),
                ("Supports", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/support")],
        )
        
        add("Pause Bench",
            [
                "Bench normally.",
                "Pause for a full two seconds at whatever depth you are weakest at.",
                "Most people should pause just below the mid-point but you can also pause an inch or two above your chest."],
            [("Pausing", "https://www.t-nation.com/training/2-second-pause-for-big-gains")],
        )
        
        add(
            "Pause Squat",
            [
                "Squat normally.",
                "Once you hit below parallell pause for a full two seconds.",
                "Resume the squat.",
            ],
            [
                (
                    "Link",
                    "http://bruteforcestrength.com/techniques/leg-training-pause-squats/",
                ),
                (
                    "Pausing",
                    "https://www.t-nation.com/training/2-second-pause-for-big-gains",
                ),
            ],
        )
        
        add(
            "Pendlay Row",
            [
                "Bar above middle of feet. Feet about shoulder width apart.",
                "Toes out about thirty degrees.",
                "Keep knees slightly bent.",
                "Hands just outside shoulder width. Palms in. Grip close to fingers.",
                "Squeeze the bar hard.",
                "Back should remain straight the entire time.",
                "Explode the barbell up so that it touches your chest.",
                "Lower to floor slowly.",
                "Torso remain parallel to the floor and have minimal movement.",
            ],
            [
                ("Stronglifts", "http://stronglifts.com/barbell-row/"),
                ("Video", "https://www.youtube.com/watch?v=Weu9HMHdiDA"),
            ],
        )
        
        add(
            "Perry Complex",
            [
                "Start with a weight you can curl&press 10 times.",
                "Don't let the dumbbell touch the floor during a set.",
                "For lunges and curl&press do six reps for each side.",
                "Aim for no rest between sets.",
            ],
            [(
                "Link",
                "https://www.builtlean.com/2012/04/10/dumbbell-complex",
            )],
        )
        
        add(
            "Pike Pushup",
            [
                "Lay face down on the floor.",
                "Scoot your hips way up into the air.",
                "Keep your chin tucked.",
                "Lower your torso until your forehead touches the ground.",
                "Use your arms to raise your torso.",
                "Difficulty can be lessened by moving your feet backwards.",
                "Difficulty can be increased by resting your feet on a low bench or stool.",
            ],
            [
                ("Video", "https://www.youtube.com/watch?v=EA8g7q9jauM"),
                (
                    "Feet Elevated Video",
                    "https://www.youtube.com/watch?v=Oy3zxr6W-vI",
                ),
            ],
        )
        
        add(
            "Pin Squat",
            [
                "Adjust the pins within a power cage to the desired depth.",
                "Squat normally and allow the bar to rest on the pins.",
                "Don't try to anticipate the pins: drop using your normal technique.",
                "Come to a full stop and then resume the squat.",
            ],
            [(
                "Link",
                "https://testifysc.com/articles/the-pin-squat-what-how-and-why",
            )],
        )
        
        add("Pistol Squat",
            [
                "Keep your hands straight out.",
                "Stand on one leg and extend the other leg outward.",
                "Drop into a full squat with the leg you are standing on.",
                "Stand and switch legs."],
            [("Link1", "http://ashotofadrenaline.net/pistol-squat/"), ("Link2", "http://breakingmuscle.com/strength-conditioning/whats-preventing-you-from-doing-pistol-squats-how-to-progress-pistols"), ("Video", "https://www.youtube.com/watch?v=It3yvU0fomI")],
        )
        
        add("Plank",
            ["Lie prone on a mat keeping elbows below shoulders.",
             "Raise body upwards to create a straight line.",
             "Use your toes to support yourself.",
             "Difficulty can be lessened by keeping your knees on the ground.",
             "Difficulty can be increased by raising a foot and/or hand off the ground or by elevating feet."],
            [("Link", "http://www.exrx.net/WeightExercises/RectusAbdominis/BWFrontPlank.html"),
             ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1"),
             ("Antranik", "https://www.youtube.com/watch?v=44ScXWFaVBs"),
             ("Progression", "http://www.startbodyweight.com/p/plank-progression.html")],
        )
        
        add("Plank Shoulder Taps",
            [
                "Get into a plank position with your hands directly under your shoulders.",
                "Spread your legs wide.",
                "Keep your head in a neutral position: don't look up.",
                "Raise one hand and touch it to your opposite shoulder.",
                "Keep your body as still as possible.",
                "Difficulty can be increased by bringing your legs closer together."],
            [("Video", "https://www.youtube.com/watch?v=LEZq7QZ8ySQ")])
        
        add("Power Clean",
            ["This is a complex technical lift that is difficult to summarize in a short list.",
                "It's best to learn the lift from a coach or a good guide and then add a note here for those bits that give you trouble."],
            [("Link", "https://experiencelife.com/article/learn-to-power-clean/"), ("Video", "https://www.youtube.com/watch?v=_LpPUmrKEg8")])
        
        add("Power Snatch",
            ["This is a complex technical lift that is difficult to summarize in a short list.",
                "It's best to learn the lift from a coach or a good guide and then add a note here for those bits that give you trouble."],
            [("Link", "http://www.exrx.net/WeightExercises/OlympicLifts/PowerSnatch.html")])
        
        add("Preacher Curl",
            ["Sit at the preacher bench and grab an EZ bar along the inner camber.",
                "Rest elbows on the bench.",
                "Curl the bar."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/preacher-curl")])
        
        add("Prone Lift",
            ["Lie down with legs slightly apart and palms under your thighs.",
                "Lift both legs, bending at the hip, high enough that your thighs leave your hands.",
                "At the same time lift your head and shoulders from the floor.",
            ],
            [("Link", "https://www.fourmilab.ch/hackdiet/e4/")])
        
        add("Pseudo Planche Pushups",
            ["Pushup but with your body scooted forward."],
            [("Video", "https://www.youtube.com/watch?v=Cdmg0CfMZeo"),
                ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup"),
                ("Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup/#wiki_recommended_progression")])
        
        add("Pull Through",
            ["Attach a rope handle to a low pulley.",
                "Face away from the pulley straddling the cable.",
                "Bend at the hips so that the handle moves behind your butt.",
                "Using mostly your hips bring the handle in front of your hips.",
                "Keep your arms straight.",
                "Bend your knees slightly.",
            ],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/pull-through")])
        
        add("Pull-up",
            ["Hands can be wider, the same, or narrower than shoulder width.",
                "Palms face out.",
                "Bring torso back about thirty degrees and push chest out.",
                "Pull until chest touches the bar.",
                "Slowly lower back down.",
                "Difficulty can be lessened by doing negatives: jump to raised position and very slowly lower yourself.",
                "Difficulty can be increased by attaching plates to a belt."],
            [("Pullups", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pullup"),
             ("Elbow Pain", "https://breakingmuscle.com/fitness/5-ways-to-end-elbow-pain-during-chin-ups"),
             ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pullup")],
        )
        
        add(
            "Pull-up Negative",
            [
                "Jump to the top and slowly lower yourself.",
                "Work towards taking 10s to lower yourself.",
            ],
            [
                (
                    "Link",
                    "https://www.fitstream.com/exercises/negative-pull-up-a6041",
                ),
                (
                    "Pull-ups",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pullup",
                ),
                (
                    "Elbow Pain",
                    "https://breakingmuscle.com/fitness/5-ways-to-end-elbow-pain-during-chin-ups",
                ),
            ],
        )
        
        add(
            "Push Press",
            [
                "Clean the bar to your shoulders.",
                "Slightly flex hips and ankles, keeping your torso erect.",
                "Use your legs to push upwards in an explosive movement.",
                "Lock the bar overhead with shoulders shrugged up.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/push-press",
            )],
        )
        
        add(
            "Pushup (intro)",
            [
                "Lie face down with palms just outside your shoulder and arms bent.",
                "Push up until your arms are straight.",
                "Keep your knees on the floor and your upper body straight.",
            ],
            [
                ("Link", "https://www.fourmilab.ch/hackdiet/e4/"),
                ("Negatives", "https://www.youtube.com/watch?v=S7pHvvD7oqA"),
                (
                    "Pushups",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup",
                ),
            ],
        )
        
        add("Pushup",
            [
                "Hands slightly wider than shoulder width.",
                "Spread fingers and angle your hands outward slightly.",
                "Keep body straight.",
                "To reduce shoulder strain keep your elbows tucked so that your upper arms form a 45 degree angle to your torso.",
                "Difficulty can be lessened by keeping knees on the floor or by placing hands on a support.",
                "Difficulty can be increased by placing feet on a bench."],
            [("Video", "https://www.youtube.com/watch?v=4dF1DOWzf20&feature=youtu.be"), ("Link", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup"), ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase2/pushup"), ("Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup/#wiki_recommended_progression")],
        )
        
        add("Pushup Plus",
            [
                "Get into the upper portion of a pushup.",
                "While keeping your arms straight depress your chest and allow your shoulder blades to come together.",
                "Then raise your chest upwards moving your shoulder blades apart."],
            [("Video", "http://www.cornell.edu/video/push-up-plus")],
        )
        
        add(
            "Quad Sets",
            [
                "Sit on the floor with your injured leg stretched out in front of you.",
                "Tighten the muscles on top of your thigh causing your knee to press into the floor.",
                "Hold for 10s.",
                "If you feel discomfort you can add a rolled up towel under your knee.",
            ],
            [(
                "Link",
                "https://myhealth.alberta.ca/Health/Pages/conditions.aspx?hwid=zm5023&lang=en-ca",
            )],
        )
        
        add(
            "Quadruped Double Traverse Abduction",
            [
                "Crouch down on all fours.",
                "Tilt your hips to one side.",
                "Raise your opposite leg into the air as high as you can.",
            ],
            [("Video", "https://www.youtube.com/watch?v=1HrzisfjpBw")],
        )
        
        add(
            "Quadruped Thoracic Extension",
            [
                "Crouch down on all fours.",
                "Place one hand behind your head.",
                "Rotate that arm inwards so that the elbow is pointed to the opposite knee.",
                "Pause and then rotate the arm up as far as possible.",
                "Keep your lower back straight.",
            ],
            [(
                "Link",
                "https://www.exercise.com/exercises/quadruped-extension-and-rotation",
            )],
        )
        
        add(
            "Rack Chin-up",
            [
                "Use a smith machine or squat rack.",
                "Prop feet on a bench or chair.",
                "Using a wide grip do chin-ups.",
                "Difficulty can be increased by resting a dumbbell on hips.",
            ],
            [("Video", "https://www.youtube.com/watch?v=6nmrFR_ulkY")],
        )
        
        add("Rack Pulls",
            [
                "Setup inside a power rack with the pins either just below knees, at knees, or just above knees.",
                "Lift the bar off the pins just as if you were doing a deadlift.",
                "Weight should be even heavier than a deadlift so a mixed grip or straps are helpful."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/rack-pulls")],
        )
        
        add(
            "Rear Delt Band Pull Apart",
            [
                "Start by holding a band overhead and pulling it apart to create some tension.",
                "Slowly lower your arms until you notice that it is harder to hold the band apart.",
                "Pull the band far apart and finish by pinching your shoulder blades together.",
            ],
            [("Video", "https://www.youtube.com/watch?v=yLJhWWX9YT0")],
        )
        
        add(
            "Rear-foot-elevated Hip Flexor Stretch",
            [
                "Get on your knees.",
                "Prop one foot on a low support.",
                "Extend the other foot out in front of you.",
                "Keep your back straight and lean back slightly.",
                "Difficulty can be increased by placing your rear knee against a wall (couch stretch).",
            ],
            [("Video", "https://www.youtube.com/watch?v=5rLRCSLbwjQ")],
        )
        
        add(
            "Renegade Row",
            [
                "Place two kettlebells or dumbbells on the floor about shoulder width apart.",
                "Position yourself on your toes and hands with back and legs straight.",
                "Use the handles of the kettlebells to support your upper body.",
                "Feet can be spread outward.",
                "Push one kettlebell into the floor and row the other to your side.",
                "Lower the kettlebell and row the other one.",
            ],
            [
                (
                    "Link",
                    "https://www.bodybuilding.com/exercises/detail/view/name/alternating-renegade-row",
                ),
                (
                    "Tips",
                    "https://www.menshealth.com/fitness/a27178801/renegade-row-form/",
                ),
                ("Video", "https://www.youtube.com/watch?v=LccyTxiUrhg"),
            ],
        )
        
        add("Rest",
            ["For conditioning 30-90 seconds.",
                "For hypertrophy 1-2 minutes.",
                "For strength 3-5 minutes.",
            ],
            [("Link", "https://livehealthy.chron.com/much-time-rest-before-lifting-weights-again-2499.html")],
        )
        
        add("Reverse Crunch",
            ["Lie on your back with your legs fully extended and your arms at your sides.",
                "Raise your legs so that your thighs are perpendicular to the floor and your calfs are parallel to the floor.",
                "Inhale, roll backwards, and bring your knees to your chest.",
                "Roll back to the original position where your legs were off the floor."],
            [("Link", "https://www.bodybuilding.com/exercises/reverse-crunch")],
        )
        
        add("Reverse Flyes",
            ["Lie face down on an incline bench.",
                "Grab two dumbbells and angle your hands so that your palms face each other.",
                "Keeping a slight bend to your elbows bring the dumbbells from in front of you to behind your back."],
            [("Link", "https://www.acefitness.org/resources/everyone/exercise-library/34/incline-reverse-fly/?srsltid=AfmBOop3VuRw3NuAHnuLrF9wqfYfnMIbFA8TZHOnxPfMTJtdo_9CQF0S")],
        )
        
        add("Reverse Grip Wrist Curl",
            ["Grasp a barbell around shoulder width apart with your palms facing down.",
                "Stand straight up with your back straight and arms extended.",
                "The bar should not be touching your body.",
                "Keeping your eyes forward, elbows tucked in, slowly curl the bar up.",
                "Slowly lower the bar back down.",
            ],
            [("Link", "https://www.muscleandstrength.com/exercises/reverse-barbell-curl.html")],
        )
        
        add("Reverse Hyperextension",
            ["Lie on on your stomach on a high bench.",
                "Grab either handles or the sides of the bench.",
                "Keeping your legs straight raise them to parallel or a bit higher.",
            ],
            [("Link", "https://www.thefittingrooms.london/2015/01/reverse-hypers/"),
                ("Video", "https://www.youtube.com/watch?v=ZeRsNzFcQLQ&")])
        
        add("Reverse Plank",
            [
                "Lie on your back and raise your body up so that you are supported by just your palms and your feet.",
                "Straighten each leg out in turn.",
                "Pinch shoulder blades together.",
                "Bring the hips up.",
                "Keep your head in a neutral position. Don't look at your feet."],
            [("Link", "https://www.youtube.com/watch?v=44ScXWFaVBs&feature=youtu.be&t=3m34s"), ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1")],
        )
        
        add("Reverse Wrist Curl",
            ["Using a light dumbbell sit on a bench with your elbow on your leg so that your arm is bent at ninety degrees.",
                "With your palm facing the floor slowly lower and raise the weight.",
                "For Tennis Elbow (pain outside the elbow) it's recommended to repeat this with the arm held straight out."],
            [("Link", "http://www.exrx.net/WeightExercises/WristExtensors/DBReverseWristCurl.html"),
             ("Tennis Elbow", "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2515258/table/t1-0541115/")])
        
        add("Ring Ab Rollouts",
            ["Keep your elbows straight.",
                "Keep your hands as close together as you can.",
                "Remain in hollow body position.",
                "Moving the rings higher will make this easier.",
                "Elevating your feet will make this harder.",
            ],
            [("Link", "https://bit.ly/3k9saY5"), ("Video", "https://www.youtube.com/watch?v=LBUfnmugKLw")])
        
        add("Ring Dips",
            ["Hold the rings with your palms (mostly) facing forward.",
                "Go as far down as you can.",
                "Keep elbows in, don't bend at the hips.",
            ],
            [("Link", "https://www.youtube.com/watch?v=2Vymm8nH4wM"),
                ("Dips", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/dip")])
        
        add(
            "Ring Support Hold",
            [
                "Arms straight.",
                "Body straight or slightly hollow.",
                "Depress the shoulders.",
            ],
            [
                (
                    "Link",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/support",
                ),
                (
                    "Supports",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/support",
                ),
            ],
        )
        
        add(
            "Rings L-sit Dips",
            [
                "Do a ring dip with your legs extended straight outward.",
                "Difficulty can be lessened by tucking your legs.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=2Vymm8nH4wM"),
                (
                    "Dips",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/dip",
                ),
            ],
        )
        
        add(
            "Rings Pushup",
            [
                "Start from a plank position on the rings.",
                "Perform the pushup.",
                "Turn out the rings at the top (rotate so that your thumbs are pointed out).",
                "Keep your body in a straight line.",
                "Lock out arms and push shoulders forward.",
                "Keep elbows in, don't let them flare outwards from your torso.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=vBviFvN3rHw"),
                (
                    "Pushups",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup",
                ),
            ],
        )
        
        add(
            "Rings Wide Pushup",
            [
                "Start from a plank position on the rings.",
                "Lower your body while allowing the elbows to come out to your sides.",
                "Go down until your lower and upper arms form a ninety degree angle.",
                "Turn out the rings at the top (rotate so that your thumbs are pointed out).",
                "Keep your body in a straight line.",
                "Lock out arms and push shoulders forward.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=vBviFvN3rHw"),
                (
                    "Pushups",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup",
                ),
            ],
        )
        
        add(
            "RKC Plank",
            [
                "This is similar to a regular front plank except that:",
                "Elbows go further forward (place them under your head).",
                "Elbows are kept close together.",
                "Quads are contracted to lock out the knees.",
                "Glutes are contracted as hard as possible.",
            ],
            [("Link", "https://bretcontreras.com/the-rkc-plank/")],
        )
        
        add("Rocking Frog Stretch",
            [
                "Get on your hands and knees.",
                "Spread your legs out about 3-6 inches wider than your shoulders.",
                "Turn your toes so that they are facing outwards.",
                "Big toe and inside of knee should remain in contact with the floor.",
                "Bend your elbows and rest your torso on your forearms.",
                "Slowly rock your body back as far as it will go and hold for a two count.",
                "Slowly rock your body forward.",],
            [("Video", "https://www.youtube.com/watch?v=iKugmxlcE9E&ab_channel=ConnorBrowne"), ("Gallery", "https://imgur.com/gallery/iEsaS"), ("Notes", "https://www.bodybuilding.com/fun/limber-11-the-only-lower-body-warm-up-youll-ever-need.html")],
        )
        
        add("Roll-over into V-sit",
            [
                "Sit on the floor with your legs stretched out in front of you.",
                "Roll backwards onto your shoulders.",
                "Try to have your toes touch the ground behind your head.",
                "Roll forward extending your legs into a V.",
                "Bring your arms forward so that your palms rest on the ground between your legs.",
                "Try to increase the range of motion with each rep.",
                "Difficulty can be reduced by pulling on your ankles as you roll back."],
            [("Video", "https://www.youtube.com/watch?v=NcBo0wRDCCE"), ("Gallery", "https://imgur.com/gallery/iEsaS"), ("Notes", "https://www.bodybuilding.com/fun/limber-11-the-only-lower-body-warm-up-youll-ever-need.html")],
        )
        
        add("Romanian Deadlift",
            [
                "Stand upright holding the bar with palms facing inward, back arched, and knees slightly bent.",
                "Lower the bar by moving your butt backwards as far as possible.",
                "Keep bar close to body, head looking forward, and shoulders back.",
                "Don't lower bar past knees."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/romanian-deadlift")],
        )
        
        add(
            "Rope Horizontal Chop",
            [
                "Attach a straight bar attachment to a medium or low pulley.",
                "Alternate between extending one arm straight outward.",
            ],
            [("Video", "https://www.youtube.com/watch?v=_ZwskpDtXi0")],
        )
        
        add(
            "Rope Jumping",
            [
                "Hold the rope in both hands and position it behind you on the ground.",
                "Swing the rope up and around.",
                "As it hits the floor jump over it.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/rope-jumping",
            )],
        )
        
        add("Rotational Lunge",
            ["Stand up with one foot behind you and the other forward.",
                "Angle your back foot so that it is pointing to the side.",
                "Clasp your hands together, stretch them out forward, and crouch onto your back leg.",
                "It's OK if your front toes come off the ground.",
            ],
            [("Video", "https://www.youtube.com/watch?v=iH8erCfR7lQ")],
        )
        
        add(
            "Rowing Machine",
            [
                "Primarily use your leg and hips.",
                "Bring the handle to your torso after straightening your legs.",
                "Keep your core tight throughout.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/rowing-stationary",
            )],
        )
        
        add(
            "RTO Pushup",
            [
                "Start from a plank position on the rings with the rings turned out.",
                "Perform the pushup.",
                "Keep the rings turned out the entire time.",
                "Keep your body in a straight line.",
                "Lock out arms and push shoulders forward.",
                "Keep elbows in, don't let them flare outwards from your torso.",
            ],
            [
                (
                    "Link",
                    "https://www.youtube.com/watch?v=MrlyEIpe0LI&t=2m55s",
                ),
                (
                    "Pushups",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup",
                ),
            ],
        )
        
        add(
            "RTO PPPU",
            [
                "Start from a plank position on the rings with the rings turned out.",
                "Lean forward until your shoulders are in front of your hands.",
                "Perform the pushup while maintaining the lean.",
                "Difficulty can be increased by leaning forward more.",
                "Keep your body in a straight line.",
                "Lock out arms and push shoulders forward.",
                "Keep elbows in, don't let them flare outwards from your torso.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=-kwe1EOiWMY"),
                (
                    "Pushups",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup",
                ),
            ],
        )
        
        add(
            "RTO Support Hold",
            [
                "Arms straight.",
                "Body straight or slightly hollow.",
                "Depress the shoulders.",
            ],
            [
                (
                    "Link",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/support",
                ),
                (
                    "Supports",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/support",
                ),
            ],
        )
        
        add("Run and Jump (intro)",
            [
                "Run in place at a brisk pace lifting your feet 4-6 inches from the floor with each step.",
                "Every 75th time your left foot touches the ground stop and do 7 introductory jumping jacks.",
                "For the jumping jacks stand with legs together, arms at your sides, and jump into the air extending your legs to the side and arms level with your shoulders."],
            [("Link", "https://www.fourmilab.ch/hackdiet/e4/")],
        )
        
        add("Run and Jump",
            [
                "Run in place at a brisk pace lifting your feet 4-6 inches from the floor with each step.",
                "Every 75th time your left foot touches the ground stop and do 10 jumping jacks.",
                "For the jumping jacks stand with legs together, arms at your sides, and jump into the air extending your legs to the side and arms as high as you can."],
            [("Link", "https://www.fourmilab.ch/hackdiet/e4/")],
        )
        
        add(
            "Russian Leg Curl",
            [
                "Lie down on your stomach.",
                "Secure your feet.",
                "Cross your hands over your chest.",
                "Bring your torso up as high as possible.",
                "Keep your back straight at all times.",
            ],
            [
                (
                    "Link",
                    "https://bretcontreras.com/nordic-ham-curl-staple-exercise-athletes/",
                ),
                ("Video", "https://www.youtube.com/watch?v=d8AAPcYxPo8"),
            ],
        )
        
        add(
            "Scapular Pulls",
            [
                "Hang down from a pull-up bar.",
                "Keeping your arms straight.",
            ],
            [
                (
                    "Video",
                    "https://www.youtube.com/watch?v=FgYoc4O-cio&feature=youtu.be&t=1m21s",
                ),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pullup",
                ),
            ],
        )
        
        add(
            "Scapular Rows",
            [
                "Lay down and use a bar to elevate your torso above the ground.",
                "Use your arms to lift your shoulders upwards.",
                "Keeping your arms straight raise your torso by shrugging your shoulders forward.",
                "Move slowly, pinch your shoulder blades together.",
            ],
            [
                ("Video", "https://www.youtube.com/watch?v=XzSNFureSCE"),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1",
                ),
            ],
        )
        
        add(
            "Scapular Shrugs",
            [
                "Crouch on your hands and knees with arms straight.",
                "Push your shoulder blades back as much as possible.",
                "Push your shoulder blades forward as much as possible.",
                "Difficulty can be increased by doing this in a pushup position or by using a band.",
            ],
            [
                ("Video", "https://www.youtube.com/watch?v=akgQbxhrhOc"),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1",
                ),
            ],
        )
        
        add(
            "SCM Stretch",
            [
                "This can be done either seated or standing.",
                "Keep back straight and neck inline with spine.",
                "Depress chest with one hand.",
                "Rotate head in the direction hand is pointed.",
                "Tilt head backwards until you feel a stretch.",
                "Hold for 30-60s and then switch sides.",
                "Ideally do these 2-3x a day.",
            ],
            [("Link", "https://www.youtube.com/watch?v=wQylqaCl8Zo")],
        )
        
        add(
            "Seated Cable Row",
            [
                "Use a V-bar (which allows palms to face each other).",
                "Pull back until torso is at 90-degree angle from legs with chest out.",
                "Keep torso stationary and pull hands back to torso.",
            ],
            [(
                "Link",
                "https://www.verywellfit.com/how-to-do-the-cable-row-3498605",
            )],
        )
        
        add("Seated Calf Raises",
            [
                "Sit on the machine, place toes on the lower portion of the platform with heels extending off.",
                "Place thighs under lever pad.",
                "Raise and lower heels."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/seated-calf-raise")],
        )
        
        add(
            "Seated Hip Abduction",
            [
                "Sit on the machine (it's the one where your legs go inside the padded levers).",
                "Move legs as far apart as possible.",
            ],
            [(
                "Link",
                "http://www.exrx.net/WeightExercises/HipAbductor/LVSeatedHipAbduction.html",
            )],
        )
        
        add("Seated Hip Adduction",
            ["Sit on the machine (it's the one where your legs go outside the padded levers).",
                "Move legs together.",
            ],
            [("Link", "http://www.exrx.net/WeightExercises/HipAdductors/LVSeatedHipAdduction.html")],
        )
        
        add("Seated Leg Curl",
            ["Adjust the machine so that the lower pad is a few inches below your calves.",
                "Adjust the machine so that the upper pad is just above the knees.",
                "Grab the handles and point your toes straight.",
                "Curl legs upwards as far as possible without moving your torso.",
            ],
            [("Link", "https://us.myprotein.com/thezone/training/hamstring-seated-leg-curl-exercise-technique-common-mistakes/"),
             ("Video", "https://us.myprotein.com/thezone/training/hamstring-seated-leg-curl-exercise-technique-common-mistakes/")],
        )
        
        add("Seated Piriformis Stretch",
            ["Sit down on a chair and cross your legs.",
                "Pull your knee up and lean your chest forward slightly.",
                "Back should remain straight."],
            [("Video", "https://www.youtube.com/watch?v=DE-GGsRtb6k"), ("Gallery", "https://imgur.com/gallery/iEsaS"), ("Notes", "https://www.bodybuilding.com/fun/limber-11-the-only-lower-body-warm-up-youll-ever-need.html")],
        )
        
        add("Seated Triceps Press",
            ["Sit on a bench with back support.",
                "Hold a dumbbell overhead with palms facing inwards.",
                "Lower the weight behind your head until your forearms touch your biceps.",
                "Keep elbows in and upper arms stationary.",
            ],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/seated-triceps-press")],
        )
        
        add("Shoulder Dislocate",
            ["Use a dowel or a broom or a belt or a towel.",
                "Take a wide grip and slowly raise your arms up as far behind your head as possible.",
                "Keep your arms straight the entire time.",
                "Difficulty can be lessened by taking a wider grip.",
                "Difficulty can be increased by adding **small** weights.",
                "Do 1-3 sets of 15 reps."],
            [("Link", "https://www.reddit.com/r/bodyweightfitness/comments/2v5smy/the_shoulder_dislocate_a_must_read_for_all/"), ("Video", "https://www.youtube.com/watch?v=02HdChcpyBs")],
        )
        
        add(
            "Shoulder Dislocate (band)",
            [
                "Start with your arms extending straight out.",
                "Rotate your arms behind your back as far as they will go.",
                "Elevate your shoulders as your arms pass over your head.",
                "Keep your arms straight the entire time.",
            ],
            [(
                "Link",
                "https://www.youtube.com/watch?v=8lDC4Ri9zAQ&feature=youtu.be&t=4m22s",
            )],
        )
        
        add("Shoulder Rolls",
            [
                "Stand upright with your arms at your side.",
                "Roll shoulders forward, up to ears, back, and down.",
                "Difficulty can be increased by:\n1. Holding your hands straight out in front of you.\n2. Holding your hands straight up above your head.\n3. Crouching on your hands and knees with elbows locked.\n4. Sticking your butt in the air so that your torso and legs form a ninety degree angle."],
            [("Video", "https://www.youtube.com/watch?v=H01oGIS1C_g")],
        )
        
        add(
            "Side Bend (45 degree)",
            [
                "Lie on your side on an inclined support leaving your torso unsupported.",
                "Clasp your hands behind your head.",
                "Bend your torso towards the floor so that it forms a 45 degree angle to your hips.",
            ],
            [("Video", "https://www.youtube.com/watch?v=a3ToFRkvVNA")],
        )
        
        add(
            "Side Lateral Raise",
            [
                "Hold two dumbbells along your sides with palms facing inwards.",
                "Raise arms until they are parallel to the floor.",
                "Keep elbows slightly bent.",
            ],
            [(
                "Link",
                "https://exrx.net/WeightExercises/DeltoidLateral/DBLateralRaise",
            )],
        )
        
        add("Side Lying Abduction",
            [
                "Lay down on your side with a forearm supporting your head.",
                "Keeping both legs straight raise your free leg into the air.",
                "Stop lifting once you begin to feel tension in your hips.",
                "Go slowly and keep your back straight."],
            [("Link", "https://www.verywellfit.com/side-lying-hip-abductions-techniques-benefits-variations-4783963")],
        )
        
        add(
            "Side Lying Hip Raise",
            [
                "Lay down on your side so that your body is supported by a forearm and knee.",
                "Bring your feet back so that your lower and upper legs form a ninety degree angle.",
                "Place your other hand on your hip.",
                "Raise the leg that isn't supporting you into the air.",
            ],
            [("Video", "https://www.youtube.com/watch?v=xLbZJaR3il0")],
        )
        
        add("Side Plank",
            ["Lie on your side keeping your elbow below the shoulder and legs together.",
                "Raise body upwards to create a straight line.",
                "Difficulty can be reduced by keeping your knees on the floor.",
                "Difficulty can be increased by keeping legs apart.",
            ],
            [("Link", "http://www.exrx.net/WeightExercises/Obliques/BWSidePlank.html"),
                ("Antranik", "https://www.youtube.com/watch?v=44ScXWFaVBs&feature=youtu.be&t=1m19s"),
                ("Alternative", "http://i.imgur.com/6NM22BF.jpg"),
                ("Abduction Video", "https://www.youtube.com/watch?v=x6eHE2ox_Oo"),
                ("Progression", "http://www.startbodyweight.com/p/plank-progression.html")],
        )
        
        add("Single Leg Dumbbell Deadlift",
            ["Hold a dumbbell in each hand.",
                "Feet should width apart with toes pointed straight outward.",
                "Lift chest out and pinch shoulder blades together.",
                "Keep the dumbbells as close to your body as possible.",
                "Tighten stomach and hinge forward extended your other leg behind you.",
                "When your hips cannot go back any further reverse by pushing your hips forward."],
            [("Link", "https://www.puregym.com/exercises/legs/hamstring-exercises/deadlifts/single-leg-deadlift/")],
        )
        
        add("Single Leg Glute Bridge",
            ["Lie on your back with your hands to your sides and your knees bent.",
                "Raise one leg, pulling your knee into your chest.",
                "Push your heels into the floor and lift your hips off the floor.",
                "Hold at the top for a second.",
                "Keep your back straight.",
                "Difficulty can be increased by elevating your body by placing one foot on a chair or bench."],
            [("Link", "https://www.verywellfit.com/single-leg-bridge-exercise-3120739"), ("Elevated Video", "https://www.youtube.com/watch?v=juyqMVIzDkQ")],
        )
        
        add("Single Leg Romanian Deadlift",
            ["Start in a standing position with your arms hanging down holding a barbell.",
                "Lower the barbell towards the ground while at the same time raising one leg behind you.",
                "Keep your back straight and try to make your raised leg form a a straight line with your back.",
                "Tuck your chin.",
                "Slightly bend the knee your weight is resting on."],
            [("Link", "http://tonygentilcore.com/2009/06/exercises-you-should-be-doing-1-legged-barbell-rdl/")],
        )
        
        add("Single Shoulder Flexion",
            ["Stand up with your arms at your sides.",
                "Keeping your arm straight raise it forward and up until it points to the ceiling.",
                "Hold for five seconds and return to the starting position."],
            [("Link", "https://www.healthline.com/health/fitness-exercise/bicep-tendonitis-exercises"), ("Picture", "https://myhealth.alberta.ca/HealthTopics/breast-cancer-surgery/PublishingImages/12Active-Shoulder-Flex.jpg")],
        )
        
        add(
            "Situp (intro)",
            [
                "Lie down with feet slightly apart and hands at your sides.",
                "Lift your head and shoulders high enough that you can see your heels.",
                "Lower your head back to the floor and repeat.",
            ],
            [("Link", "https://www.fourmilab.ch/hackdiet/e4/")],
        )
        
        add(
            "Situp",
            [
                "Lie down with feet held by a partner or under something that will not move.",
                "Knees should be off the floor.",
                "Lock your hands behind your head.",
                "Raise your torso upwards.",
                "Difficulty can be increased by crossing your arms in front while holding a plate.",
            ],
            [
                (
                    "Link",
                    "https://www.bodybuilding.com/exercises/detail/view/name/sit-up",
                ),
                (
                    "Weighted",
                    "http://www.exrx.net/WeightExercises/RectusAbdominis/WtSitUp.html",
                ),
            ],
        )
        
        add("Skater Squat",
            [
                "Stand on one leg.",
                "Lean forward and squat down.",
                "Stand back up and repeat."],
            [("Video", "https://www.youtube.com/watch?v=qIi5bsSjdw4"), ("Details", "https://www.girlsgonestrong.com/blog/strength-training/exercise-spotlight-skater-squat/")],
        )
        
        add(
            "Skull Crushers",
            [
                "Lie on back on a flat bench.",
                "Grip an EZ bar using a close grip with elbows in and bar behind head.",
                "Bring bar to a position above forehead.",
                "Keep upper arms stationary.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/ez-bar-skullcrusher",
            )],
        )
        
        add(
            "Sleeper Stretch",
            [
                "Lie down on your injured side.",
                "Use a pillow for your head and bend your knees.",
                "Bend the elbow of your injured arm so that your fingers point to the ceiling.",
                "Use your other arm to gently push your injured arm to the floor.",
                "Resist the motion to feel the stretch and keep your shoulder blades pushed together.",
                "Hold the stretch 30 seconds.",
            ],
            [
                (
                    "Link",
                    "https://www.healthline.com/health/fitness-exercise/bicep-tendonitis-exercises",
                ),
                (
                    "Picture",
                    "https://www.espclinics.com/patients/stretches-exercises/sleeper-stretch/",
                ),
            ],
        )
        
        add(
            "Sliding Leg Curl",
            [
                "Lay down on your back.",
                "Place slides under your feet (or a towel if you have a smooth floor).",
                "Bring your feet in and raise your hips off the ground.",
                "Slide your feet all the way forward.",
                "Bring your feet back in until your shins are vertical.",
                "Keep your hips up at all times.",
            ],
            [("Video", "https://www.youtube.com/watch?v=RmsTFCQ3Qig")],
        )
        
        add("Smith Machine Bench",
            [
                "Plce the bar at a height that you can reach with arms almost fully extended while lying down.",
                "Using a grip wider than shoulder width unrack the bar to start.",
                "Lower the bar to middle ches around nipples.",
                "Raise the bar back up."],
            [("Link", "https://www.bodybuilding.com/exercises/smith-machine-bench-press")],
        )
        
        add(
            "Smith Machine Shrug",
            [
                "Set the bar height to be about the middle of your thighs.",
                "Grab the bar with your palms facing you.",
                "Lift the bar up keeping your arms fully extended.",
                "Raise your shoulders until they come close to touching your ears.",
                "Lower your shoulders.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/smith-machine-shrug",
            )],
        )
        
        add(
            "SMR Glutes with Ball",
            [
                "Use a lacrosse or hockey ball.",
                "Sit on the ball and roll it back and forth on your glutes.",
                "Difficulty can be lessened by using a foam roller.",
                "Pause on areas that are especially tender until they feel better.",
            ],
            [("Video", "https://www.youtube.com/watch?v=M9Ix8OIPF-U")],
        )
        
        add("Spell Caster",
            [
                "Grab a pair of dumbbells with your palms facing backwards.",
                "Shift the weights to one side of your hips, rotating your torso as you go.",
                "Keeping your arms straight rotate your torso the other way so that the weights move to your other side.",
                "As you move the weights to the other side raise them to chest height."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/spell-caster")],
        )
        
        add("Spider Curls",
            [
                "Sit at the preacher bench and scoot forward so that your stomach is on the bench and your upper arms are against the sides of the bench.",
                "Grab an EZ bar at about shoulder width.",
                "Curl the bar."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/spider-curl")],
        )
        
        add(
            "Squat Jumps",
            [
                "Stand straight up.",
                "Drop down into a squat.",
                "Jump into the air as high as possible.",
            ],
            [("Link", "https://www.youtube.com/watch?v=CVaEhXotL7M")],
        )
        
        add(
            "Squat Sky Reaches",
            [
                "Squat down with your arms on your knees.",
                "Grab an ankle with one hand, clench the other arm and bring that elbow straight overhead.",
                "Once the elbow is overhead extend the arm straight up."],
            [(
                "Video",
                "https://www.youtube.com/watch?v=lbozu0DPcYI&feature=youtu.be&t=42s",
            )],
        )
        
        add(
            "Squat to Stand",
            [
                "Stand with feet shoulder width apart.",
                "Keeping legs as straight as possible, bend over and grab your toes.",
                "Lower your hips into a squat while pushing shoulders and chest up.",
                "Raise your hips back to the starting position keeping your hands on your toes.",
            ],
            [(
                "Link",
                "https://www.exercise.com/exercises/sumo-squat-to-stand",
            )],
        )
        
        add("Stack Complex",
            [
                "[Push Press](https://greatist.com/health/dumbbell-push-press#how-to-do-a-dumbbell-push-press) (all for 8 reps)",
                "[Front Squat](https://www.nasm.org/exercise-library/dumbbell-front-squat)",
                "[Romanian Deadlift](https://www.nasm.org/exercise-library/dumbbell-romanian-deadlift)",
                "[Bent-over Row](https://www.muscleandstrength.com/exercises/bent-over-dumbbell-row.html)",
                "[Elevated Pushups](https://www.livestrong.com/article/13771062-dumbbell-push-ups/)",
                "Rest for 30s.",
                "[30s Bike Sprints](https://www.t-nation.com/training/4-dumbest-forms-of-cardio)"],
            [("Link", "https://www.stack.com/a/a-dumbbell-complex-workout-to-build-muscle-and-quickly-shed-fat")],
        )
        
        add(
            "Standing Calf Raises",
            [
                "Use a a Smith machine or free weights.",
                "Keep knees slightly bent at all times.",
                "Keep your back straight.",
                "Don't allow your knees to move around.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/standing-calf-raises",
            )],
        )
        
        add(
            "Standing Double Abduction",
            [
                "Stand on one leg with your hands on your hips.",
                "Bring your other foot a foot or so off the ground.",
                "While sinking into a quarter squat curl your body towards the leg that is supporting you.",
                "Bring your raised knee up as high as you can keeping the foot behind you."],
            [("Video", "https://www.youtube.com/watch?v=syUYsbFtqSE")],
        )
        
        add(
            "Standing Dumbbell Calf Raises",
            [
                "Stand upright while holding two dumbbells.",
                "Place the balls of your feet on a board 2-3\" high.",
                "Raise your heels as high as possible.",
                "Lower your heels to the floor.",
                "To hit all the muscles equally keep your toes pointed straight out.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/standing-dumbbell-calf-raise",
            )],
        )
        
        add(
            "Standing IT Band Stretch",
            [
                "Stand up straight and cross one leg over the other.",
                "Raise the arm on the same side as your back leg high into the air.",
                "Bend towards the side with your arm down until you feel the stretch.",
            ],
            [(
                "Video",
                "https://www.ogradyorthopaedics.com/video-collection/standing-it-band-stretch/",
            )],
        )
        
        add(
            "Standing One Arm Cable Row",
            [
                "Use a low or medium height pulley.",
                "Drive elbow back as far as possible.",
                "Keep torso upright and don't twist.",
            ],
            [(
                "Link",
                "http://www.trainbetterfitness.com/standing-1-arm-cable-row/",
            )],
        )
        
        add("Standing Quad Stretch",
            ["Stand at a right angle to a wall.",
                "Extend your arm straight out and use the wall for support.",
                "With the other hand grab your ankle and pull your foot back to your butt.",
                "Don't arch or twist your back.",
                "Keep your knees together.",
            ],
            [("Link", "https://www.verywellfit.com/standing-quadriceps-stretch-3120301")])
        
        add("Standing Triceps Press",
            ["Stand with feet about shoulder width apart.",
                "Start with the dumbbells behind your head.",
                "Raise the weights until your arms point straight upwards.",
                "Minimize the motion in your upper arms.",
            ],
            [("Link", "https://www.anabolicaliens.com/blog/overhead-triceps-extension-exercise")])
        
        add("Standing Wide Leg Straddle",
            ["Stand with your legs spread wide apart and feet pointer straight out.",
                "Straighten your legs.",
                "Place your fingertips (or palms) on the ground below your shoulders.",
                "You may also grab your big toes.",
                "Keep your eyes forward and your back concave.",
            ],
            [("Link", "http://yahwehyoga.com/pose-descriptions/cool-down/standing-wide-leg-straddle/")])
        
        add("Static Hold",
            [
                "Use chalk.",
                "Setup inside a power rack with the pins set above your knees.",
                "When starting to grip the bar position your hands so that the calluses on your palm are just above the bar.",
                "Place your thumb over your fingers.",
                "Grip the bar as tight as you can.",
                "Lift the bar off the pins just as if you were doing a deadlift.",
                "Hold the bar until your grip begins to loosen.",],
            [("Link", "http://jasonferruggia.com/mythbusting-improve-grip-strength-deadlifting/"), ("Grip", "https://strengthandgain.com/increase-forearm-and-grip-strength/")],
        )
        
        add(
            "Step-ups (Intro)",
            [
                "Place one foot on a support 3-5\" high.",
                "Keep your other foor flat on the floor and then slowly raise that foot off the ground.",
                "Slowly lower your foot back onto the ground."],
            [("Rehab", "https://theprehabguys.com/step-ups")],
        )
        
        add(
            "Step-ups",
            [
                "Place one foot on a high object.",
                "Place all of your weight on that object and step up onto the object.",
                "Minimize pushing with your back leg.",
                "Difficulty can be increased by using a higher step or by holding dumbbells.",
            ],
            [
                (
                    "Link",
                    "https://www.bodybuilding.com/exercises/detail/view/name/dumbbell-step-ups",
                ),
                (
                    "Progression",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/squat",
                ),
                ("Rehab", "https://theprehabguys.com/step-ups"),
            ],
        )
        
        add("Stiff-Legged Deadlift",
            [
                "Like a normal deadlift except that the knees are only slightly bent and remain stationary."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/stiff-legged-barbell-deadlift")],
        )
        
        add(
            "Stomach to Wall Handstand",
            [
                "Toes are the only point that should be in contact with the wall.",
                "Arms and legs are straight and locked.",
                "Hands should be close together (closer than you initially think).",
                "Push up through the shoulders, elevating your shoulder blades.",
                "Squeeze your legs together and point your toes up.",
            ],
            [
                ("Video", "https://www.youtube.com/watch?v=m64XxmNHjfs"),
                (
                    "Progression",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase4/handstand",
                ),
            ],
        )
        
        add(
            "Straight Leg Raise",
            [
                "Lie on your back with your good leg pulled back.",
                "Raise your other leg into the air keeping it straight.",
                "Move slowly both up and down.",
            ],
            [(
                "Link",
                "https://www.verywellhealth.com/how-to-the-straight-leg-raise-2696526",
            )],
        )
        
        add(
            "Straight Leg Situp",
            [
                "Lie on your back, optionally with your feet held in place.",
                "Cross your hands over your chest.",
                "Keep your legs extended straight outwards.",
                "Raise your torso up.",
                "As you come up extend your hands and touch your toes.",
            ],
            [("Video", "https://www.youtube.com/watch?v=AT6zWvOI6_o")],
        )
        
        add("Stress Ball Squeeze",
            [
                "Squeeze a rubber stress ball for either 10 reps or 30s.",
                "If you're doing Wrist Extension or Flexion then use that arm position."],
            [("Link", "https://www.greencroft.org/Library/docLib/2020/04/5-Minute-Stress-Ball-Workout.pdf"), ("AAoS", "https://orthoinfo.aaos.org/globalassets/pdfs/a00790_therapeutic-exercise-program-for-epicondylitis_final.pdf")],
        )
        
        add(
            "Suboccipitals Release",
            [
                "Place a tennis ball on the upper back side of the neck.",
                "Lie on your back with the ball on one side of your neck.",
                "Can use one hand to hold the ball in place.",
                "Tuck your chin up and down for 10 deep breaths.",
                "Then do the other side.",
                "Ideally do these 2-3x a day.",
            ],
            [("Link", "https://www.youtube.com/watch?v=wQylqaCl8Zo")],
        )
        
        add(
            "Sumo Deadlift",
            [
                "Take a wide stance with knees pushed out.",
                "Place bar below middle of feet with toes pointed out slightly.",
                "Grab the bar by bending over at the hips instead of squatting down.",
                "Your arms should be hanging from the shoulders and between your legs.",
                "Drop low by driving knees out hard, keep lower back arched and hamstrings stretched.",
                "Wedge hips into bar and raise chest.",
                "Try to use feet to spread the floor apart and explode up.",
                "At the midpoint push hips into the bar.",
            ],
            [
                (
                    "Link",
                    "https://www.bodybuilding.com/exercises/detail/view/name/sumo-deadlift",
                ),
                (
                    "7-Steps",
                    "https://www.elitefts.com/education/7-step-guide-to-learning-the-sumo-deadlift/",
                ),
                (
                    "Mastering",
                    "https://www.t-nation.com/training/6-tips-to-master-the-sumo-deadlift",
                ),
            ],
        )
        
        add("Sumo Squat",
            [
                "Turn feet so toes are pointed outwards.",
                "Stand with your feet double shoulder width.",
                "Squat down keeping your feet flat on the ground.",
                "Difficulty can be increased with dumbbells."],
            [("Link", "https://www.surreyphysio.co.uk/top-5/best-5-exercises-for-an-adductor-strain/")],
        )
        
        add(
            "Swiss Ball Hip Internal Rotation",
            [
                "Lie on your back on a swiss ball.",
                "Cross your hands over your chest.",
                "Raise your hips up slightly and slowly rock forward and backward.",
                "As you're rocking bring your knees inward a bit.",
            ],
            [("Video", "https://www.youtube.com/watch?v=aVRidEHlbMA")],
        )
        
        add(
            "T-Bar Row",
            [
                "Keep your back straight.",
                "Pull the bar towards you by flexing your elbows and retracting your shoulder blades.",
                "Pull the weight to your chest.",
            ],
            [("Link", "https://www.bodybuilding.com/exercises/t-bar-row")],
        )
        
        add(
            "Third World Squat",
            [
                "Look straight ahead and hold hands straight out.",
                "Feet about shoulder width apar feet slightly angled out.",
                "Drop hips and knees together.",
                "Knees out.",
                "Difficulty can be lessened by using a wider stance and by angling feet outward more.",
                "Work towards holding the squat for one minute for multiple reps."],
            [
                ("Link", "https://www.physio-form.co.uk/article/improve-your-mobility-for-sport-and-everyday-life"),
                ("Video", "https://vimeo.com/116283733"),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1",
                ),
            ],
        )
        
        add(
            "Tiger Tail Roller",
            [
                "Apply about ten pounds of force.",
                "Try to relax your muscles.",
                "Discomfort is OK, major pain is not.",
                "Spend 10-20 seconds on each muscle group.",
            ],
            [("Link", "https://www.tigertailusa.com/pages/how-to-roll")],
        )
        
        add(
            "Toe Pulls",
            [
                "Get into a handstand with your toes touching a wall.",
                "Push your butt ou bring your toes off the wall, and re-balance.",
            ],
            [
                ("Video", "https://www.youtube.com/watch?v=J9-7QXCsPL0"),
                (
                    "Handstand Progression",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase4/handstand",
                ),
            ],
        )
        
        add(
            "Trap Bar Deadlift",
            [
                "Feet should be roughly hip-width with toes slightly pointed out.",
                "Grip handles. Sit hips back until feel a stretch in hamstrings.",
                "Lift chest and flatten back. Look ahead or slightly down.",
                "While keeping arms straight rotate elbows to face behind you and pull shoulders down.",
                "Pull on the bar to create maximum tension in your body.",
                "Take a deep breath into stomach and contract abs.",
                "Drive heels into the ground.",
                "As the bar approaches your knees drive forward with your hips.",
                "Repeat.",
            ],
            [
                (
                    "Link",
                    "https://www.chrisadamspersonaltraining.com/trap-bar-deadlift.html",
                ),
                (
                    "Guide",
                    "https://www.garagegymreviews.com/trap-bar-deadlift",
                ),
            ],
        )
        
        add(
            "Trap-3 Raise",
            [
                "Hold a light weight with one hand.",
                "Bend over about 45 degrees.",
                "Allow your arm to hang free and retract your shoulder blade.",
                "Raise your arm upwards until it is inline with your torso.",
                "Keep your arm about 30 degrees away from your center line.",
            ],
            [("Video", "https://www.youtube.com/watch?v=pHvTWgWyDWs")],
        )
        
        add("Triceps Pushdown (rope)",
            [
                "Attach a rope attachment to a high pulley.",
                "Grab the attachment with palms facing each other.",
                "Stand straight up with a slight forward lean.",
                "Bring upper arms close to your torso and perpendicular to the ground.",
                "Start with forearms parallel to the ground.",
                "Using only your forearms bring the attachment down to your thighs.",
                "At the end your arms should be fully extended."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/triceps-pushdown-rope-attachment")],
        )
        
        add(
            "Tuck Front Lever",
            [
                "Use a shoulder width grip on a pull-up bar.",
                "Tuck legs and bring them up to your chest.",
                "Keep hips at the same height as your head.",
                "Difficulty can be increased by tucking less.",
                "Hold that position.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=tiST0765Sfo"),
                (
                    "Body Weight Rows",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/row",
                ),
            ],
        )
        
        add(
            "Tuck Front Lever Row",
            [
                "Get into a tuck front level position.",
                "Pull your body up as high as possible while remaining horizontal.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=F-xEL0Ot0HA"),
                (
                    "Body Weight Rows",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/row",
                ),
            ],
        )
        
        add(
            "Tuck Ice Cream Maker",
            [
                "From the top point of a pull-up on rings tuck your legs.",
                "Then lean back while keeping body horizontal.",
                "Lock out arms and pause for a second in tuck front level position.",
            ],
            [
                (
                    "Untucked Video",
                    "https://www.youtube.com/watch?v=AszLwoAvLKg",
                ),
                (
                    "Body Weight Rows",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/row",
                ),
            ],
        )
        
        add(
            "Turkish Get-Up",
            [
                "Cradle and grip the kettlebell.",
                "Press the kettlebell overhead (using both hands is OK).",
                "Roll up onto your far elbow and then your hand.",
                "Lift your hips off the floor.",
                "Sweep the leg and find a lunge.",
                "Stand up from the lunge.",
                "Descend from the lunge.",
                "Keep your wrist straight and elbow locked the entire time.",
                "Instead of shrugging your shoulder up pull your shoulder blades down.",
            ],
            [
                (
                    "Link",
                    "https://www.bodybuilding.com/fun/the-ultimate-guide-to-the-turkish-get-up.html",
                ),
                ("Video", "https://www.youtube.com/watch?v=0bWRPC49-KI"),
            ],
        )
        
        add(
            "Underhand Cable Pulldowns",
            [
                "Sit at a lat pulldown machine with a wide bar attached to the pulley.",
                "Grab the bar with your palms facing you at closer than shoulder width.",
                "Stick your chest out and lean back about thirty degrees.",
                "Pull the bar to your upper chest keeping elbows in tight.",
            ],
            [(
                "Link",
                "https://www.bodybuilding.com/exercises/detail/view/name/underhand-cable-pulldowns",
            )],
        )
        
        add("Upper Trapezius Stretch",
            [
                "Start either standing or sitting.",
                "Place one hand on the opposite side of your head.",
                "Place your other hand behind your back.",
                "Use your hand to bring your head down towards your shoulder.",
            ],
            [("Link", "https://backintelligence.com/how-to-fix-forward-head-posture/")],
        )
        
        add("Upright Row",
            [
                "Grasp a barbell with palms facing inward slightly less than shoulder width.",
                "Rest the bar on thighs with elbows slightly bent.",
                "Keep back straight.",
                "Raise bar to chin keeping elbows higher than forearms.",
                "Lower bar back to thighs.",
                "Note that many people discourage performing this exercise because it can cause shoulder impingement."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/upright-barbell-row"), ("Dangers", "https://www.t-nation.com/training/five-exercises-you-should-stop-doing-forever")],
        )
        
        add(
            "Vertical Pushup",
            [
                "Stand upright facing a wall.",
                "Extend your arms and place both hands on the wall.",
                "Take a small step back and lift up onto your toes.",
                "Lower yourself into the wall and then push yourself away.",
                "Keep your body in a straight line.",
                "Lock out arms and push shoulders forward.",
                "Keep elbows in, don't let them flare outwards from your torso.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=a6YHbXD2XlU"),
                (
                    "Pushups",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup",
                ),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase2/pushup",
                ),
                ("Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/pushup/#wiki_recommended_progression"),
            ],
        )
        
        add(
            "Vertical Rows",
            [
                "Grab a door frame and pull your body into the frame and then allow it to move back.",
                "Keep your body straight and elbows in.",
                "Arms should be straight at the bottom.",
                "Don't let your shoulders shrug up.",
            ],
            [
                ("Link", "https://www.youtube.com/watch?v=e5fdh9_kH_Y"),
                (
                    "Body Weight Rows",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/row",
                ),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase2/row",
                ),
            ],
        )
        
        add(
            "Walking Knee Hugs",
            [
                "Stand up straight with your arms ar your sides.",
                "Bring one knee up, grab it with both hands, and gently pull it higher and in.",
            ],
            [("Link", "https://blackbeltwiki.com/walking-knee-hugs")],
        )
        
        add(
            "Wall Ankle Mobility",
            [
                "Place one foot 3-4 inches away from a wall.",
                "Place the other foot well behind you.",
                "While keeping your front heel on the floor, drive your knees forward.",
                "Your rear heel should be off the floor.",
            ],
            [("Video", "https://www.youtube.com/watch?v=eGjJkurZlGw")],
        )
        
        add("Wall Biceps Stretch",
            [
                "Face a wall standing about six inches away.",
                "Extend your arm along the wall and with your palm down touch the thumb side of your hand to the wall.",
                "Keep your arm straight and turn your body away from your arm until you feel the bicep stretch.",
                "Hold for about fifteen seconds."],
            [("Link", "https://www.healthline.com/health/fitness-exercise/bicep-tendonitis-exercises"), ("Picture", "https://www.triathlete.com/wp-content/uploads/sites/4/2016/12/1-1-3.jpg")],
        )
        
        add("Wall Extensions",
            [
                "Sit with your back straight up against a wall.",
                "Raise your arms as if you are surrendering pressing your upper arms against the wall.",
                "Start with your lower and upper arms forming a 90 degree angle.",
                "Once your upper arms are in place move your forearms against the wall.",
                "Keeping forearms completely vertical and your body against the wall slide your hands as high as they will go.",
                "Difficulty can be lessened by starting with elbows further down.",
                "Work towards 8-10 reps."],
            [("Link", "https://www.gymnasticbodies.com/forum/topic/846-wall-extensions/")],
        )
        
        add(
            "Wall Extensions (floor)",
            [
                "Lie down on the floor.",
                "Keep your lower back touching the floor.",
                "Start with your lower and upper arms forming a 90 degree angle.",
                "If possible start with your elbows on the floor.",
                "Move your arms up as far as possible but stop if your elbows begin to raise.",
            ],
            [
                (
                    "Link",
                    "https://www.gymnasticbodies.com/forum/topic/846-wall-extensions/",
                ),
                (
                    "Cues",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase1",
                ),
            ],
        )
        
        add("Wall Handstand",
            [
                "Perform a handstand with your belly facing a wall and your feet braced against the wall.",
                "Once you can hold the position for more than 30s start take a foot from the wall and then both feet."],
            [("Link", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/handstand"), ("Handstands", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/handstand")],
        )
        
        add(
            "Wall Plank",
            [
                "Put your feet up against a wall and do a plank hold.",
                "Don't allow your hips to sag: dig your soles hard into the wall.",
                "Work on getting your feet higher and higher.",
            ],
            [
                ("Video", "https://www.youtube.com/watch?v=6jm4R3K4sJA"),
                (
                    "Link",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/handstand",
                ),
                (
                    "Handstands",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/handstand",
                ),
                (
                    "Handstand Progression",
                    "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase4/handstand",
                ),
                (
                    "Dragon Flag Progression",
                    "http://www.startbodyweight.com/p/plank-progression.html",
                ),
            ],
        )
        
        add("Wall March Plank",
            ["Put your feet up against a wall and do a plank hold.",
                "Don't allow your hips to sag: dig your soles hard into the wall.",
                "Work on getting your feet higher and higher.",
                "Alternate between bringing each knee forward."],
            [("Progression", "http://www.startbodyweight.com/p/plank-progression.html")],
        )
        
        add("Walking",
            ["Keep your head up: focus about 10-20 feet in front of you.",
             "Straighten Your Back.",
             "Keep your shoulders down and back.",
             "Swing your arms.",
             "Step from heel to toe."],
            [("Link", "https://www.uchicagomedicineadventhealth.org/blog/ways-improve-your-walking-technique")])
        
        add("Wall Scissors",
            ["Get into a full hand stand next to a wall.",
                "Scissor one leg out and one leg in so that a toe touches the wall.",
            ],
            [("Video", "https://www.youtube.com/watch?v=wspEkEzsZyQ"),
             ("Handstand Progression", "https://www.reddit.com/r/bodyweightfitness/wiki/move/phase4/handstand")])
        
        add("Weighted Inverted Row",
            ["Can use a belt with attached weigh a weight ves or a plate on your chest/belly."],
            [("Link", "https://bit.ly/37B9D1Q")])
        
        add("Wide Rows",
            ["Setup a pull-up bar, a barbell, or rings. Use a grip at 1.5x shoulder width.",
                "Pull your body into the bar and then allow it to move back down.",
                "Keep your body straight and elbows in.",
                "Arms should be straight at the bottom.",
                "Don't let your shoulders shrug up.",
            ],
            [("Link", "https://www.youtube.com/watch?v=1yMRvsuk9Xg"),
             ("Body Weight Rows", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/row"),
             ("Cues", "https://www.reddit.com/r/bodyweightfitness/wiki/exercises/row")])
        
        add("Wrist Curls",
            ["Sit down on the end of a bench and grab a dumbbell with your palm facing up.",
                "Rest your forearm on your thigh so that the dumbbell is just off the end of your leg.",
                "Drop the dumbbell as far as it will go.",
                "Slowly raise the dumbbell up as far as it will go.",
                "Bend only at the wrist.",
            ],
            [("Link", "https://www.muscleandstrength.com/exercises/one-arm-seated-dumbbell-wrist-curl.html")])
        
        add("Wrist Extension",
            [
                "Sit in a chair with your arm resting on a table or your thigh with your palm facing down.",
                "To start with use no weight and bend your elbow so that your arm forms a 90 degree angle.",
                "Bend your wrist upwards as far as you can.",
                "Hold for a one count and then use a three count to slowly lower the weight back down.",
                "Keep your forearm in place the entire time.",
                "Do 30 reps. After you can do 30 reps over two days with no increase in pain increase the weight.",
                "Once three pounds is OK gradually start straightening your arm out."],
            [("Link", "https://www.saintlukeskc.org/health-library/wrist-extension-strength"),
             ("AAoS", "https://orthoinfo.aaos.org/globalassets/pdfs/a00790_therapeutic-exercise-program-for-epicondylitis_final.pdf")])
        
        add("Wrist Extension Stretch",
            ["Extend your arm out with the palm facing down.",
                "Use your other hand to pull your fingers and palm up and towards your body.",
                "Don't lock your elbow.",
                "Hold the stretch for 15s. Repeat 5x.",
                "Do this up to 4x a day, especially before activities that involve gripping."],
            [("Link", "https://www.topendsports.com/medicine/stretches/wrist-extension.htm"),
             ("AAoS", "https://orthoinfo.aaos.org/globalassets/pdfs/a00790_therapeutic-exercise-program-for-epicondylitis_final.pdf")])
        
        add("Wrist Flexion",
            ["Sit in a chair with your arm resting on a table or your thigh with your palm facing up.",
                "To start with use no weight and bend your elbow so that your arm forms a 90 degree angle.",
                "Bend your wrist upwards as far as you can.",
                "Hold for a one count and then use a three count to slowly lower the weight back down.",
                "Keep your forearm in place the entire time.",
                "Do 30 reps. After you can do 30 reps over two days with no increase in pain increase the weight.",
                "Once three pounds is OK gradually start straightening your arm out."],
            [("Link", "https://www.saintlukeskc.org/health-library/wrist-flexion-strength"),
             ("AAoS", "https://orthoinfo.aaos.org/globalassets/pdfs/a00790_therapeutic-exercise-program-for-epicondylitis_final.pdf")])
        
        add("Wrist Flexion Stretch",
            ["Extend your arm out with the palm facing down.",
                "Use your other hand to pull your fingers and palm down and towards your body.",
                "Don't lock your elbow.",
                "Hold the stretch for 15s. Repeat 5x.",
                "Do this up to 4x a day, especially before activities that involve gripping."],
            [("Link", "https://www.topendsports.com/medicine/stretches/wrist-flexion.htm"),
             ("AAoS", "https://orthoinfo.aaos.org/globalassets/pdfs/a00790_therapeutic-exercise-program-for-epicondylitis_final.pdf")])
        
        add("Wrist Mobility",
            ["Crouch on your hands and knees with arms straight.",
                "1 Keep your fingers on the ground while raising and lowering your palms.",
                "2 Rotate palm left and right.",
                "3 Place hands sideways and rock side to side.",
                "4 Place hands palm up and rock backwards and forwards.",
                "5 Do the Star Trek salute and stick your hands, palm up again, around your knees. Rotate your elbows back and forth.",
                "6 Place palms on the ground in front of you and rotate your elbows back and forth.",
                "7 Place your hands backwards with the palms down, bring knees forward, and sit back on your heels and come back up.",
                "8 Place your hands with palms down and facing forward. Lean forward and then back.",
                "Difficulty can be increased by doing these in a plank position."],
            [("Link", "https://www.youtube.com/watch?v=8lDC4Ri9zAQ&feature=youtu.be&t=4m22s")])
        
        add("Yuri's Shoulder Band",
            ["Attach a band to a support at about shoulder height.",
                "Extend an arm straight backwards and move forward until there is tension on the band.",
                "Bring your arm in to your back so that the forearm is against your lower back.",
                "Extend the arm straight back again.",
                "Bring your forearm to the back of your head and then circle it around your far shoulder and then to your far elbow.",
                "Reverse the movement so that your arm is again straight behind you.",
                "Repeat."],
            [("Video", "https://www.youtube.com/watch?v=Vwn5hSf3WEg")])
        
        add("X-Band Walk",
            ["Put a resistance band beneath your fee twist it so that it forms an X, and raise it to your chest.",
                "Walk sideways several steps.",
                "Walk back to your starting position."],
            [("Link", "https://www.exercise.com/exercises/x-resistance-band-walk")])
        
        add("Z Press",
            ["Sit inside a power rack.",
                "Adjust the pins so that the bar is a couple of inches below your shoulders.",
                "Extend your legs out straight in front of you.",
                "Keep your back straight: don't slouch.",
                "Keep the bar over your center of mass.",
                "Try not to move your feet or legs.",
            ],
            [("Link", "https://www.t-nation.com/training/z-press-advanced-overhead-pressing")])
        
        add("Zercher Squat",
            ["Load a bar on a squat rack where the bar is above your waist but below your chest.",
                "Lock your hands together and pick the bar up with it resting on your forearms just below the elbow.",
                "Step away from the rack and take a shoulder width stance.",
                "Point toes out slightly.",
                "Squat down until your thighs just break parallel with the ground.",
                "At the bottom your knees should be over your toes.",
                "Keep your head up at all times."],
            [("Link", "https://www.bodybuilding.com/exercises/detail/view/name/zercher-squats"),
             ("Details", "https://www.t-nation.com/training/complete-guide-to-zerchers")])
    }
    
    private func add(_ name: String, _ lines: [String], _ links: [(String, String)]) {
        let body = lines.map({"• \($0)"}).joined(separator: "\n")
        let trailer = links.map({"[\($0.0)](\($0.1))"}).joined(separator: "\n")
        defaults[name] = "\(body)\n\n\(trailer)"
    }
}

// TODO add unit tests to spell check
// TODO add unit tests to check links
