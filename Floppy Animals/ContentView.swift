import SwiftUI
import AVFoundation
import AudioToolbox

// MARK: - 🎮 GAME TYPES

enum CharacterType: String, CaseIterable, Identifiable {
    case monkey = "🐒 Monkey", chicken = "🐔 Chicken", bird = "🐦 Bird", eagle = "🦅 Eagle"
    var id: String { rawValue }
    var jumpStrength: CGFloat { [.monkey:-10.5, .chicken:-11.5, .bird:-11.0, .eagle:-9.5][self]! }
    var displayName: String { String(rawValue.dropFirst(2)) }
}

enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy", medium = "Medium", expert = "Expert"
    var id: String { rawValue }
    var pipeSpeed: CGFloat { [.easy:2.0, .medium:3.0, .expert:4.0][self]! }
    var pipeGapRatio: CGFloat { [.easy:0.49, .medium:0.42, .expert:0.37][self]! }
    static let normalGravity: CGFloat = 0.40
}

enum GunType: String, CaseIterable, Identifiable {
    case green, purple, red
    var id: String { rawValue }
    var ammo: Int { [.green:3, .purple:5, .red:7][self]! }
    var baseColor: Color { [
        .green:Color(red:0.18, green:0.72, blue:0.28),
        .purple:Color(red:0.48, green:0.22, blue:0.78),
        .red:Color(red:0.82, green:0.18, blue:0.18)
    ][self]! }
    var lightColor: Color { [
        .green:Color(red:0.35, green:0.92, blue:0.45),
        .purple:Color(red:0.65, green:0.40, blue:0.98),
        .red:Color(red:1.0, green:0.35, blue:0.35)
    ][self]! }
    var darkColor: Color { [
        .green:Color(red:0.08, green:0.42, blue:0.15),
        .purple:Color(red:0.25, green:0.10, blue:0.50),
        .red:Color(red:0.52, green:0.05, blue:0.05)
    ][self]! }
}

// MARK: - 🎨 THEME SYSTEM

enum GameTheme: String, CaseIterable, Identifiable {
    case theme1 = "1. Default (Beta 0.5)"
    case theme2 = "2. Neon Cyberpunk"
    case theme3 = "3. Soft Pastel"
    case theme4 = "4. Dark Luxury Gold ⭐"
    case theme5 = "5. Cartoon Adventure"
    
    var id: String { rawValue }
    
    var gradient: LinearGradient {
        switch self {
        case .theme1:
            return LinearGradient(colors: [
                Color(red: 0.4, green: 0.8, blue: 1.0),
                Color(red: 0.7, green: 0.95, blue: 0.85)
            ], startPoint: .top, endPoint: .bottom)
        case .theme2:
            return LinearGradient(colors: [
                Color(red: 0.05, green: 0.02, blue: 0.15),
                Color(red: 0.30, green: 0.05, blue: 0.45),
                Color(red: 0.05, green: 0.35, blue: 0.55)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .theme3:
            return LinearGradient(colors: [
                Color(red: 0.88, green: 0.92, blue: 1.0),
                Color(red: 1.00, green: 0.90, blue: 0.95),
                Color(red: 0.92, green: 0.95, blue: 0.88)
            ], startPoint: .top, endPoint: .bottom)
        case .theme4:
            return LinearGradient(colors: [
                Color(red: 0.05, green: 0.04, blue: 0.02),
                Color(red: 0.22, green: 0.16, blue: 0.05),
                Color(red: 0.60, green: 0.42, blue: 0.10)
            ], startPoint: .bottom, endPoint: .top)
        case .theme5:
            return LinearGradient(colors: [
                Color(red: 0.45, green: 0.75, blue: 1.0),
                Color(red: 0.60, green: 0.90, blue: 0.60)
            ], startPoint: .top, endPoint: .bottom)
        }
    }
    
    var accentColor: Color {
        switch self {
        case .theme1: return .white
        case .theme2: return Color(red:1.0, green:0.2, blue:0.8)
        case .theme3: return Color(red:0.3, green:0.3, blue:0.5)
        case .theme4: return Color(red:1.0, green:0.8, blue:0.2)
        case .theme5: return Color(red:0.2, green:0.5, blue:1.0)
        }
    }
    
    var primaryText: Color {
        switch self {
        case .theme1: return .white
        case .theme2: return Color(red: 0.95, green: 0.85, blue: 1.0)
        case .theme3: return Color(red: 0.12, green: 0.12, blue: 0.28)
        case .theme4: return Color(red: 1.0, green: 0.92, blue: 0.65)
        case .theme5: return Color(red: 0.05, green: 0.06, blue: 0.18)
        }
    }
    
    var secondaryText: Color { primaryText.opacity(0.82) }
}

// MARK: - 📏 DYNAMIC ADAPTIVE SCREEN (LANDSCAPE & PORTRAIT SUPPORT)

class AdaptiveScreenManager: NSObject, ObservableObject {
    @Published var width: CGFloat = UIScreen.main.bounds.width
    @Published var height: CGFloat = UIScreen.main.bounds.height
    
    static let shared = AdaptiveScreenManager()
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateDimensions),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        updateDimensions()
    }
    
    @objc func updateDimensions() {
        DispatchQueue.main.async {
            self.width = UIScreen.main.bounds.width
            self.height = UIScreen.main.bounds.height
        }
    }
    
    var minDim: CGFloat { min(width, height) }
    var maxDim: CGFloat { max(width, height) }
    var isLandscape: Bool { width > height }
    
    func scale(_ v: CGFloat) -> CGFloat { v * (minDim / 375) }
    func gapHeight(for ratio: CGFloat) -> CGFloat { minDim * ratio }
    
    var pipeWidth: CGFloat { scale(65) }
    var hitboxSize: CGFloat { scale(18) }
    var birdX: CGFloat { scale(isLandscape ? 70 : 85) }
    var groundOffset: CGFloat { scale(55) }
    var ceilingOffset: CGFloat { scale(45) }
    var bulletSize: CGFloat { scale(12) }
    var gunSize: CGFloat { scale(48) }
    var charSize: CGFloat { scale(42) }
}

// Convenience accessor
let AdaptiveScreen = AdaptiveScreenManager.shared

// MARK: - 🔊 SOUND MANAGER

@MainActor
final class SoundManager: NSObject {
    static let shared = SoundManager()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var pendingGreeting: DispatchWorkItem?
    private lazy var greetingVoices: [AVSpeechSynthesisVoice] = {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let lilyVoice = voices.first { voice in
            voice.name.localizedCaseInsensitiveContains("Lily Ki") && voice.language.hasPrefix("en")
        }
        let femaleVoices = voices.filter { voice in
            voice.language.hasPrefix("en") && voice.gender == .female
        }
        let maleVoices = voices.filter { voice in
            voice.language.hasPrefix("en") && voice.gender == .male
        }
        let selectedFemaleVoice = lilyVoice
            ?? femaleVoices.first(where: { $0.quality == .premium })
            ?? femaleVoices.first
            ?? AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-premium")
            ?? AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-compact")
        let selectedMaleVoice = maleVoices.first(where: { $0.quality == .premium })
            ?? maleVoices.first
            ?? AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Alex-premium")
            ?? AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Alex-compact")
        return [selectedFemaleVoice, selectedMaleVoice].compactMap { $0 }
    }()
    private lazy var fallbackGreetingVoice: AVSpeechSynthesisVoice = AVSpeechSynthesisVoice(language: "en-US")!
    private let greetings = [
        "Good job!",
        "You're amazing!",
        "You did it!",
        "Excellent!",
        "Awesome work!",
        "Great move!",
        "Fantastic!",
        "Nice one!",
        "You're flying high!",
        "Keep it up!",
        "Incredible!",
        "Super cool!",
        "You rock!",
        "Brilliant!",
        "Way to go!",
        "Spectacular!",
        "Outstanding!",
        "Perfectly done!",
        "You're on fire!",
        "Unstoppable!",
        "Amazing flight!",
        "Sharp reflexes!",
        "What a save!",
        "Brilliant flying!",
        "Great timing!",
        "Fantastic reflexes!",
        "You are incredible!",
        "That was perfect!",
        "Beautiful move!",
        "Strong performance!",
        "Excellent flying!",
        "You nailed it!",
        "What a champion!",
        "Keep soaring!",
        "Wonderful control!",
        "That was smooth!",
        "Elite move!",
        "You are a star!",
        "Top-level flying!",
        "Great concentration!",
        "Amazing control!",
        "That was awesome!",
        "Brave and bold!",
        "You are a winner!",
        "Super performance!",
        "Perfect reaction!",
        "Excellent control!",
        "You are on a roll!",
        "Fantastic flight!",
        "Incredible timing!",
        "What a legend!",
        "Great confidence!",
        "That was impressive!",
        "Superb flying!",
        "You make it look easy!",
        "Amazing progress!",
        "Outstanding control!",
        "That was a master move!",
        "You are flying like a champion!",
        "Brilliant reaction!",
        "Perfect path!",
        "Great challenge conquered!",
        "You are unstoppable today!",
        "Excellent decision!",
        "What an incredible move!",
        "Fantastic focus!",
        "You are rising higher!",
        "Great obstacle clear!",
        "Superstar flying!",
        "That was skillful!",
        "Wonderful timing!",
        "You have got this!",
        "Amazing achievement!",
        "Strong and steady!",
        "Brilliant obstacle clear!",
        "Perfect flying form!",
        "You are dominating!",
        "Great work, pilot!",
        "Incredible skill!",
        "That was flawless!",
        "Keep chasing the high score!",
        "You are doing fantastic!",
        "Outstanding reaction!",
        "Excellent obstacle dodge!",
        "What a brilliant pilot!",
        "You are built for this!",
        "Amazing momentum!",
        "Great job, superstar!",
        "That was beautifully done!",
        "You are breaking records!",
        "Fantastic obstacle clear!",
        "Sharp move!",
        "You are playing brilliantly!",
        "Perfect focus!",
        "That was next level!",
        "Strong flying skills!",
        "You are a natural!",
        "Great escape!",
        "Incredible confidence!",
        "That was spectacular flying!",
        "Amazing work, champion!",
        "You cleared it like a pro!",
        "Brilliant and fearless!",
        "Excellent run!",
        "You are flying beautifully!",
        "What a fantastic save!",
        "Keep that energy!",
        "You are the sky master!",
        "Perfect obstacle timing!",
        "Superb performance!",
        "You are making history!",
        "Fantastic run!",
        "That was pure skill!",
        "Amazing job, pilot!",
        "You cleared the way!",
        "Outstanding flight, champion!"
    ]
    
    private override init() {
        super.init()
        speechSynthesizer.delegate = self
        speechSynthesizer.usesApplicationAudioSession = true
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers, .defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    private func playSound(_ id: UInt32) {
        guard !UserDefaults.standard.bool(forKey: "Muted") else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            AudioServicesPlaySystemSound(id)
        }
    }
    
    func playJump(_ c: CharacterType) {
        playSound([.monkey:1306, .chicken:1315, .bird:1307, .eagle:1318][c]!)
    }
    
    func playScore(_ c: CharacterType) {
        playSound([.monkey:1057, .chicken:1003, .bird:1004, .eagle:1113][c]!)
    }
    
    func playGameOver(_ c: CharacterType) {
        playSound([.monkey:1053, .chicken:1050, .bird:1052, .eagle:1051][c]!)
    }
    
    func playPickup() {
        playSound(1025)
    }
    
    func playShoot() {
        playSound(1103)
    }
    
    func playExplode() {
        playSound(1006)
    }
    
    func playSelect() {
        playSound(1104)
    }
    
    func playMilestone() {
        playSound(1325)
    }
    
    func playRandomGreeting() {
        guard !UserDefaults.standard.bool(forKey: "Muted") else { return }
        pendingGreeting?.cancel()

        let greetingTask = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard !UserDefaults.standard.bool(forKey: "Muted") else { return }

            let greeting = greetings.randomElement() ?? "Good job!"
            let utterance = AVSpeechUtterance(string: greeting)
            utterance.voice = greetingVoices.randomElement() ?? fallbackGreetingVoice
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.78
            utterance.pitchMultiplier = 1.22
            utterance.volume = 1.0
            utterance.preUtteranceDelay = 0.02
            utterance.postUtteranceDelay = 0.12

            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [.duckOthers, .defaultToSpeaker])
                try session.setActive(true)
            } catch {
                print("Greeting audio session error: \(error)")
            }

            self.speechSynthesizer.speak(utterance)
        }

        pendingGreeting = greetingTask
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18, execute: greetingTask)
    }

    func stopGreeting() {
        pendingGreeting?.cancel()
        pendingGreeting = nil
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}

extension SoundManager: AVSpeechSynthesizerDelegate {}

// MARK: - 💾 HIGH SCORE & COIN MANAGER

class HighScoreManager: ObservableObject {
    static let shared = HighScoreManager()
    private var lastMilestone = 0
    func getHighScore(_ d: Difficulty) -> Int { UserDefaults.standard.integer(forKey: "HS_Diff_\(d.id)") }
    func saveHighScore(_ d: Difficulty, _ s: Int) {
        let current = getHighScore(d)
        if s > current { UserDefaults.standard.set(s, forKey: "HS_Diff_\(d.id)") }
    }
    func checkMilestone(_ score: Int) -> Bool {
        let current = score / 5
        if current > lastMilestone { lastMilestone = current; return true }
        return false
    }
    func resetMilestone() { lastMilestone = 0 }
}

class CoinManager: ObservableObject {
    static let shared = CoinManager()
    @Published var totalCoins: Int = UserDefaults.standard.integer(forKey: "TotalCoins")
    @Published var sessionEarnedCoins: Int = 0
    func addCoins(from score: Int) {
        let earned = score / 100
        guard earned > 0 else { return }
        totalCoins += earned; sessionEarnedCoins += earned
        UserDefaults.standard.set(totalCoins, forKey: "TotalCoins")
    }
    func spendCoins(_ amount: Int) -> Bool {
        guard totalCoins >= amount else { return false }
        totalCoins -= amount; UserDefaults.standard.set(totalCoins, forKey: "TotalCoins")
        return true
    }
}

// MARK: - 🎨 REALISTIC 3D GUN VIEW

struct Realistic3DGun: View {
    let gun: GunType
    let size: CGFloat
    var isFiring: Bool = false
    
    @State private var flashScale: CGFloat = 0.6
    @State private var flashOpacity: Double = 0.0
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: size*0.12)
                .fill(Color.black.opacity(0.35))
                .frame(width: size*1.9, height: size*0.6)
                .offset(x: size*0.08, y: size*0.12)
                .blur(radius: 3)
            
            RoundedRectangle(cornerRadius: size*0.12)
                .fill(LinearGradient(colors: [gun.lightColor, gun.baseColor, gun.darkColor], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size*1.9, height: size*0.6)
                .shadow(color: gun.darkColor.opacity(0.6), radius: 5, x: 2, y: 3)
            
            RoundedRectangle(cornerRadius: size*0.06)
                .fill(LinearGradient(colors: [Color(white: 0.85), Color(white: 0.25)], startPoint: .top, endPoint: .bottom))
                .frame(width: size*0.9, height: size*0.22)
                .offset(x: size*1.0, y: -size*0.02)
                .overlay(
                    Circle().stroke(Color.black.opacity(0.7), lineWidth: size*0.05)
                        .frame(width: size*0.18, height: size*0.18)
                        .offset(x: size*1.46)
                )
            
            RoundedRectangle(cornerRadius: size*0.08)
                .fill(LinearGradient(colors: [Color(red:0.22, green:0.18, blue:0.12), Color(red:0.10, green:0.09, blue:0.06)], startPoint: .top, endPoint: .bottom))
                .frame(width: size*0.36, height: size*0.46)
                .offset(x: size*0.72, y: size*0.30)
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 1, y: 2)
            
            RoundedRectangle(cornerRadius: size*0.02)
                .fill(Color.black.opacity(0.65))
                .frame(width: size*0.28, height: size*0.06)
                .offset(x: size*0.28, y: -size*0.18)
                .overlay(RoundedRectangle(cornerRadius: size*0.02).stroke(Color.white.opacity(0.08), lineWidth: 0.5))
            
            Text("\(gun.ammo)")
                .font(.system(size: size*0.32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 1, x: 1, y: 1)
                .offset(x: size*1.28, y: -size*0.05)
            
            ZStack {
                Circle()
                    .fill(RadialGradient(gradient: Gradient(colors: [Color.yellow, Color.orange, Color.red.opacity(0.9)]), center: .center, startRadius: 0, endRadius: size*0.4))
                    .frame(width: size*0.8 * flashScale, height: size*0.6 * flashScale)
                    .blendMode(.screen)
                
                Triangle()
                    .fill(Color.orange)
                    .frame(width: size*0.5 * flashScale, height: size*0.3 * flashScale)
                    .offset(x: size*0.45 * flashScale)
                    .rotationEffect(.degrees(-15))
            }
            .offset(x: size*1.62, y: 0)
            .opacity(flashOpacity)
            .allowsHitTesting(false)
            .animation(.easeOut(duration: 0.12), value: flashOpacity)
        }
        
        .onChange(of: isFiring) { newValue in
            if newValue {
                flashScale = 1.0
                flashOpacity = 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                    withAnimation(.easeOut(duration: 0.12)) {
                        flashOpacity = 0.0
                        flashScale = 0.6
                    }
                }
            }
        }
    }
}

// MARK: - 🎨 ANIMALS & PIPES

struct AnimatedAnimalView: View {
    let type: CharacterType, wingPhase: Double, fallingAngle: Double
    @ObservedObject var screen = AdaptiveScreen
    
    var body: some View {
        let s = screen.scale
        
        return ZStack {
            switch type {
            case .monkey:
                ZStack {
                    Circle().fill(Color(red:0.50, green:0.32, blue:0.15)).frame(width: s(36), height: s(36)).shadow(color: .black.opacity(0.3), radius:4, x:2, y:3)
                    Circle().fill(Color(red:0.72, green:0.52, blue:0.32)).frame(width: s(24), height: s(24))
                    Circle().fill(.black).frame(width: s(4)).offset(x: s(-5), y: s(-4))
                    Circle().fill(.black).frame(width: s(4)).offset(x: s(5), y: s(-4))
                }
            case .chicken:
                ZStack {
                    Circle().fill(Color(red:1.0, green:0.85, blue:0.25)).frame(width: s(34), height: s(34)).shadow(color: .black.opacity(0.3), radius:4, x:2, y:3)
                    Ellipse().fill(Color(red:0.98, green:0.78, blue:0.20)).frame(width: s(20), height: s(9)).offset(y: sin(wingPhase)*s(6))
                    Circle().fill(.black).frame(width: s(4.5)).offset(x: s(-6), y: s(-4))
                    Triangle().fill(Color(red:1.0, green:0.55, blue:0.15)).frame(width: s(8), height: s(6)).rotationEffect(.degrees(90)).offset(x: s(12), y:0)
                }
            case .bird:
                ZStack {
                    Ellipse().fill(Color(red:0.20, green:0.60, blue:1.0)).frame(width: s(30), height: s(24)).shadow(color: .black.opacity(0.3), radius:4, x:2, y:3)
                    Ellipse().fill(Color(red:0.35, green:0.75, blue:1.0)).frame(width: s(22), height: s(10)).offset(y: sin(wingPhase)*s(7)).rotationEffect(.degrees(sin(wingPhase)*18))
                    Circle().fill(.white).frame(width: s(6.5)).offset(x: s(6), y: s(-4))
                    Circle().fill(.black).frame(width: s(3)).offset(x: s(7), y: s(-4))
                    Triangle().fill(Color.orange).frame(width: s(8), height: s(5)).rotationEffect(.degrees(90)).offset(x: s(13), y:0)
                }
            case .eagle:
                ZStack {
                    Ellipse().fill(Color(red:0.40, green:0.30, blue:0.20)).frame(width: s(32), height: s(22)).shadow(color: .black.opacity(0.4), radius:5, x:2, y:4)
                    Ellipse().fill(Color(red:0.60, green:0.50, blue:0.35)).frame(width: s(24), height: s(16)).offset(y: s(-2))
                    Ellipse().fill(Color(red:0.30, green:0.25, blue:0.15)).frame(width: s(20), height: s(8)).offset(x: s(-14), y: sin(wingPhase)*s(8))
                    Ellipse().fill(Color(red:0.30, green:0.25, blue:0.15)).frame(width: s(20), height: s(8)).offset(x: s(14), y: sin(wingPhase)*s(8))
                    Circle().fill(.yellow).frame(width: s(6)).offset(x: s(6), y: s(-4))
                    Circle().fill(.black).frame(width: s(2.5)).offset(x: s(6.5), y: s(-4))
                    Triangle().fill(Color(red:0.95, green:0.75, blue:0.25)).frame(width: s(10), height: s(6)).rotationEffect(.degrees(90)).offset(x: s(14), y:0)
                }
            }
        }
        .rotationEffect(.degrees(fallingAngle))
    }
}

struct BambooPipeView: View {
    let pipe: ContentView.Pipe, gapHeight: CGFloat, bypass: Bool
    @ObservedObject var screen = AdaptiveScreen
    
    var body: some View {
        let s = screen.scale
        let w = screen.pipeWidth
        let gapTop = pipe.gapCenterY - gapHeight/2
        let bambooGradient = LinearGradient(colors: [
            Color(red:0.76, green:0.87, blue:0.48),
            Color(red:0.62, green:0.77, blue:0.32),
            Color(red:0.76, green:0.87, blue:0.48)
        ], startPoint: .leading, endPoint: .trailing)
        
        return ZStack {
            VStack(spacing:0) {
                Rectangle().fill(bambooGradient).frame(width:w, height:gapTop)
                ForEach(0..<Int(gapTop/40), id:\.self) { _ in Rectangle().fill(Color(red:0.35, green:0.50, blue:0.20)).frame(height:2) }
            }.frame(width:w, height:gapTop).position(x: pipe.x + w/2, y: gapTop/2)
            
            VStack(spacing:0) {
                ForEach(0..<Int((screen.maxDim - gapTop - gapHeight)/40), id:\.self) { _ in Rectangle().fill(Color(red:0.35, green:0.50, blue:0.20)).frame(height:2) }
                Rectangle().fill(bambooGradient).frame(width:w, height: screen.maxDim - gapTop - gapHeight)
            }.frame(width:w, height: screen.maxDim - gapTop - gapHeight)
                .position(x: pipe.x + w/2, y: gapTop + gapHeight + (screen.maxDim - gapTop - gapHeight)/2)
            
            RoundedRectangle(cornerRadius: s(4)).fill(Color(red:0.45, green:0.65, blue:0.25)).frame(width:w+8, height:s(18)).position(x: pipe.x + w/2, y: gapTop)
            RoundedRectangle(cornerRadius: s(4)).fill(Color(red:0.45, green:0.65, blue:0.25)).frame(width:w+8, height:s(18)).position(x: pipe.x + w/2, y: gapTop + gapHeight)
        }
        .opacity(bypass ? 0.4 : 1.0)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct BulletView: View {
    let b: ContentView.Bullet; let color: Color
    @ObservedObject var screen = AdaptiveScreen
    
    var body: some View {
        Circle().fill(RadialGradient(colors: [color.opacity(0.9), color], center: .center, startRadius:0, endRadius: screen.bulletSize/2))
            .frame(width: screen.bulletSize)
            .shadow(color: color.opacity(0.6), radius:3)
            .position(x: b.x, y: b.y)
    }
}

// MARK: - 🃏 DIFFICULTY CARD

struct DifficultyCard: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let highScore: Int
    let theme: GameTheme
    let action: () -> Void
    @ObservedObject var screen = AdaptiveScreen
    
    var body: some View {
        let s = screen.scale
        
        return Button(action: action) {
            VStack(spacing: 6) {
                Text(difficulty.rawValue)
                    .font(.system(size: s(15), weight: .bold))
                    .foregroundColor(theme.primaryText)
                
                Text("🏆 \(highScore)")
                    .font(.system(size: s(11), weight: .medium))
                    .foregroundColor(.yellow)
                
                HStack(spacing: 3) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(i <= Difficulty.allCases.firstIndex(of: difficulty)! ? theme.accentColor : Color.white.opacity(0.2))
                            .frame(width: s(6), height: s(6))
                    }
                }
            }
            .frame(width: s(90), height: s(85))
            .background(isSelected ? LinearGradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(s(14))
            .shadow(color: isSelected ? Color.white.opacity(0.15) : .clear, radius: isSelected ? 8 : 0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ⚙️ SETTINGS VIEW

struct SettingsViewImproved: View {
    @Binding var char: CharacterType
    @Binding var diff: Difficulty
    @Binding var theme: GameTheme
    @Binding var muted: Bool
    let start: () -> Void
    @ObservedObject var screen = AdaptiveScreen
    
    var body: some View {
        let s = screen.scale
        
        return ZStack {
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: s(18)) {
                        VStack(spacing: s(10)) {
                            HStack {
                                Text("🎨 THEME")
                                    .font(.system(size: s(18), weight: .heavy))
                                    .foregroundColor(theme.primaryText)
                                Spacer()
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: s(12)) {
                                    ForEach(GameTheme.allCases) { t in
                                        Button { theme = t; SoundManager.shared.playSelect() } label: {
                                            VStack(spacing: 4) {
                                                Text(String(t.rawValue.split(separator: ". ").last!))
                                                    .font(.system(size: s(12), weight: .bold))
                                                    .foregroundColor(theme == t ? theme.primaryText : theme.secondaryText)
                                                if t == .theme4 {
                                                    Text("⭐ RECOMMENDED")
                                                        .font(.system(size: s(9)))
                                                        .foregroundColor(.yellow)
                                                }
                                            }
                                            .padding(.horizontal, s(14))
                                            .padding(.vertical, s(10))
                                            .background(theme == t ? Color.white.opacity(0.35) : Color.white.opacity(0.12))
                                            .cornerRadius(s(12))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        
                        VStack(spacing: s(10)) {
                            HStack {
                                Text("🐾 CHARACTER")
                                    .font(.system(size: s(18), weight: .heavy))
                                    .foregroundColor(theme.primaryText)
                                Spacer()
                            }
                            HStack(spacing: s(12)) {
                                ForEach(CharacterType.allCases) { c in
                                    Button { char = c; SoundManager.shared.playSelect() } label: {
                                        Text(String(c.rawValue.prefix(2)))
                                            .font(.system(size: s(32)))
                                            .frame(width: s(70), height: s(80))
                                            .background(char == c ? LinearGradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.2)], startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom))
                                            .cornerRadius(s(14))
                                            .shadow(color: char == c ? Color.white.opacity(0.15) : .clear, radius: char == c ? 6 : 0)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        VStack(spacing: s(10)) {
                            HStack {
                                Text("🎯 DIFFICULTY")
                                    .font(.system(size: s(18), weight: .heavy))
                                    .foregroundColor(theme.primaryText)
                                Spacer()
                            }
                            HStack(spacing: s(12)) {
                                ForEach(Difficulty.allCases) { d in
                                    DifficultyCard(
                                        difficulty: d,
                                        isSelected: diff == d,
                                        highScore: HighScoreManager.shared.getHighScore(d),
                                        theme: theme,
                                        action: { diff = d; SoundManager.shared.playSelect() }
                                    )
                                }
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("🔊 SOUND")
                                    .font(.system(size: s(16), weight: .bold))
                                    .foregroundColor(theme.primaryText)
                                Text(muted ? "Effects are muted" : "Sound effects on")
                                    .font(.system(size: s(11)))
                                    .foregroundColor(theme.secondaryText)
                            }
                            Spacer()
                            Toggle(isOn: $muted) {
                                Text(muted ? "Off" : "On")
                                    .font(.system(size: s(14), weight: .semibold))
                            }
                            .labelsHidden()
                            .onChange(of: muted) { newValue in
                                UserDefaults.standard.set(newValue, forKey: "Muted")
                                if !newValue { SoundManager.shared.playSelect() }
                            }
                        }
                        .padding(.horizontal, s(16))
                        .padding(.vertical, s(14))
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(s(14))
                        
                        Spacer()
                            .frame(height: s(120))
                    }
                    .padding(.horizontal, s(18))
                    .padding(.vertical, s(12))
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                Button(action: start) {
                    HStack(spacing: s(10)) {
                        Text("▶️")
                            .font(.system(size: s(20)))
                        Text("START GAME")
                            .font(.system(size: s(18), weight: .heavy))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, s(30))
                    .padding(.vertical, s(14))
                    .background(
                        LinearGradient(
                            colors: [Color(red:0.20, green:0.75, blue:0.30), Color(red:0.10, green:0.55, blue:0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(s(16))
                    .shadow(color: Color.green.opacity(0.35), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, s(24))
                .padding(.vertical, s(16))
                .background(Color.black.opacity(0.3))
            }
        }
    }
}

// MARK: - ✅ MAIN GAME

struct ContentView: View {
    @State private var birdY: CGFloat = 0
    @State private var prevBirdY: CGFloat = 0
    @State private var birdVelocity: CGFloat = 0
    @State private var pipes: [Pipe] = []
    @State private var bullets: [Bullet] = []
    @State private var powerUps: [PowerUp] = []
    @State private var score = 0
    @State private var ammoCount = 0
    @State private var activeGun: GunType = .green
    @State private var gameState: GameState = .settings
    @State private var wingPhase = 0.0
    @State private var selectedCharacter: CharacterType = .monkey
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var selectedTheme: GameTheme = GameTheme(rawValue: UserDefaults.standard.string(forKey: "SelectedTheme") ?? GameTheme.theme1.rawValue) ?? .theme1
    @State private var bypassMode = false
    @State private var autoFireTimer: Timer? = nil
    @State private var showMilestone = false
    @State private var hitExplosions: [Explosion] = []
    @StateObject private var coinManager = CoinManager()
    @State private var hudGunFiring = false
    @AppStorage("Muted") private var isMuted: Bool = false
    @ObservedObject var screen = AdaptiveScreenManager.shared
    
    private let timer = Timer.publish(every: 1/45, on: .main, in: .common).autoconnect()
    
    enum GameState { case settings, ready, playing, gameOver }
    struct Pipe: Identifiable { let id=UUID(); var x: CGFloat; var gapCenterY: CGFloat; var passed=false; var destroyed=false }
    struct Bullet: Identifiable { let id=UUID(); var x: CGFloat; var y: CGFloat }
    struct PowerUp: Identifiable { let id=UUID(); var x: CGFloat; var y: CGFloat; var gun: GunType }
    struct Explosion: Identifiable { let id=UUID(); var x: CGFloat; var y: CGFloat; var opacity=1.0 }
    
    var body: some View {
        ZStack {
            selectedTheme.gradient.ignoresSafeArea()
            
            if selectedTheme == .theme1 || selectedTheme == .theme5 {
                Circle().fill(Color.yellow.opacity(0.9)).frame(width: screen.scale(55))
                    .position(x: screen.width - screen.scale(60), y: screen.scale(70))
            } else if selectedTheme == .theme4 {
                Circle().fill(Color(red:1.0, green:0.85, blue:0.20).opacity(0.85)).frame(width: screen.scale(55))
                    .position(x: screen.width - screen.scale(60), y: screen.scale(70))
            }
            Ellipse().fill(Color.white.opacity(0.12)).frame(width: screen.scale(80), height: screen.scale(35))
                .position(x: screen.scale(120), y: screen.scale(110))
            
            ForEach(powerUps) { Realistic3DGun(gun: $0.gun, size: screen.gunSize).position(x: $0.x, y: $0.y) }
            ForEach(pipes) { if !$0.destroyed { BambooPipeView(pipe: $0, gapHeight: screen.gapHeight(for: selectedDifficulty.pipeGapRatio), bypass: bypassMode) } }
            ForEach(bullets) { BulletView(b: $0, color: activeGun.baseColor) }
            ForEach(hitExplosions) { Circle().fill(activeGun.baseColor.opacity($0.opacity)).frame(width: screen.scale(40)).blur(radius:6).position(x: $0.x, y: $0.y) }
            
            if gameState == .playing || gameState == .ready || gameState == .gameOver {
                AnimatedAnimalView(type: selectedCharacter, wingPhase: wingPhase, fallingAngle: min(max(Double(birdVelocity/15)*25, -25), 25))
                    .position(x: screen.birdX, y: birdY)
            }
            
            if showMilestone {
                Text("🦅 SUPER SCORE! 🦅")
                    .font(.system(size: screen.scale(28), weight: .heavy))
                    .foregroundColor(selectedTheme.primaryText)
                    .shadow(color: .orange, radius:4)
                    .transition(.scale.combined(with: .opacity))
                    .onAppear { DispatchQueue.main.asyncAfter(deadline: .now()+1.5) { showMilestone = false } }
            }
            
            VStack {
                if gameState == .playing {
                    HStack {
                        HStack(spacing: 8) {
                            Realistic3DGun(gun: activeGun, size: screen.scale(28), isFiring: hudGunFiring)
                                .frame(width: screen.scale(28)*1.9, height: screen.scale(28)*0.6)
                            Text("×\(ammoCount)")
                                .font(.system(size: screen.scale(16), weight: .bold))
                                .foregroundColor(ammoCount>0 ? selectedTheme.accentColor : selectedTheme.secondaryText)
                                .shadow(color: .black.opacity(0.5), radius:1)
                        }
                        Spacer()
                        HStack(spacing: 16) {
                            HStack(spacing:4) {
                                Image(systemName: "circle.fill").foregroundColor(.yellow).font(.system(size: screen.scale(18)))
                                Text("\(coinManager.totalCoins)")
                                    .font(.system(size: screen.scale(18), weight: .bold))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .black.opacity(0.5), radius:1)
                            }
                            Text("\(score)")
                                .font(.system(size: screen.scale(50), weight: .heavy))
                                .foregroundColor(selectedTheme.primaryText)
                                .shadow(color: .black.opacity(0.3), radius:3)
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            Button { bypassMode.toggle(); SoundManager.shared.playSelect() } label: {
                                Image(systemName: bypassMode ? "shield.fill" : "shield")
                                    .font(.system(size: screen.scale(22)))
                                    .foregroundColor(bypassMode ? .green : selectedTheme.primaryText)
                            }
                            Button {
                                isMuted.toggle()
                                UserDefaults.standard.set(isMuted, forKey: "Muted")
                                if !isMuted { SoundManager.shared.playSelect() }
                            } label: {
                                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: screen.scale(20)))
                                    .foregroundColor(selectedTheme.primaryText)
                            }
                        }
                    }
                    .padding(.top, screen.scale(40)).padding(.horizontal)
                    if ammoCount > 0 {
                        Text("🔥 AUTO-FIRE ACTIVE!")
                            .font(.system(size: screen.scale(13), weight: .bold))
                            .foregroundColor(activeGun.lightColor)
                            .shadow(color: .black.opacity(0.5), radius:1)
                            .padding(.top,2)
                    }
                }
                Spacer()
                switch gameState {
                case .settings:
                    SettingsViewImproved(char: $selectedCharacter, diff: $selectedDifficulty, theme: $selectedTheme, muted: $isMuted, start: {
                        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "SelectedTheme")
                        UserDefaults.standard.set(isMuted, forKey: "Muted")
                        gameState = .ready
                    })
                case .ready:
                    ReadyView(char: selectedCharacter, diff: selectedDifficulty, theme: selectedTheme, start: startGame)
                case .playing:
                    EmptyView()
                case .gameOver:
                    GameOverView(score: score, diff: selectedDifficulty, theme: selectedTheme, earnedCoins: coinManager.sessionEarnedCoins, restart: startGame, settings: { gameState = .settings })
                }
            }
        }
        .onTapGesture {
            if gameState == .playing { jump() }
            else if gameState == .ready || gameState == .gameOver { startGame() }
        }
        .onReceive(timer) { _ in
            if gameState == .playing {
                updateGame()
                wingPhase += 0.25
                hitExplosions.indices.reversed().forEach { hitExplosions[$0].opacity -= 0.08 }
                hitExplosions.removeAll { $0.opacity <= 0 }
            }
        }
        .onAppear {
            birdY = screen.height / 2
            prevBirdY = birdY
        }
    }
    
    func canFireNow() -> Bool {
        let forwardZoneMaxX = screen.birdX + screen.scale(220)
        return pipes.contains { pipe in
            guard !pipe.destroyed else { return false }
            let pipeLeft = pipe.x
            let pipeRight = pipe.x + screen.pipeWidth
            return pipeRight >= screen.birdX && pipeLeft <= forwardZoneMaxX
        }
    }
    
    func startGame() {
        SoundManager.shared.stopGreeting()
        gameState = .playing
        birdY = screen.height/2
        prevBirdY = birdY
        birdVelocity = 0
        pipes.removeAll(); bullets.removeAll(); powerUps.removeAll(); hitExplosions.removeAll()
        score = 0; ammoCount = 0; wingPhase = 0; showMilestone = false; activeGun = .green
        coinManager.sessionEarnedCoins = 0; HighScoreManager.shared.resetMilestone(); stopAutoFire(); addPipe()
    }
    
    func jump() { birdVelocity = selectedCharacter.jumpStrength; SoundManager.shared.playJump(selectedCharacter) }
    
    func startAutoFire() {
        stopAutoFire()
        autoFireTimer = Timer.scheduledTimer(withTimeInterval: 0.18, repeats: true) { _ in
            if gameState != .playing { stopAutoFire(); return }
            if ammoCount <= 0 { stopAutoFire(); return }
            if canFireNow() {
                hudGunFiring = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { hudGunFiring = false }
                ammoCount -= 1
                bullets.append(Bullet(x: screen.birdX + screen.scale(32), y: birdY))
                SoundManager.shared.playShoot()
            }
        }
    }
    
    func stopAutoFire() { autoFireTimer?.invalidate(); autoFireTimer = nil }
    
    func updateGame() {
        prevBirdY = birdY
        birdVelocity += Difficulty.normalGravity
        birdY += birdVelocity
        if birdY > screen.height - screen.groundOffset {
            birdY = screen.height - screen.groundOffset
            if !bypassMode { gameOver() }
            return
        }
        if birdY < screen.ceilingOffset {
            birdY = screen.ceilingOffset
            birdVelocity = 0
        }
        
        pipes.indices.forEach { pipes[$0].x -= selectedDifficulty.pipeSpeed }
        bullets.indices.forEach { bullets[$0].x += 14 }
        powerUps.indices.forEach { powerUps[$0].x -= selectedDifficulty.pipeSpeed }
        
        if pipes.first?.x ?? 0 < -screen.pipeWidth { pipes.removeFirst(); addPipe() }
        bullets.removeAll { $0.x > screen.width + 50 }
        powerUps.removeAll { $0.x < -50 }
        
        checkCollisions()
    }
    
    func addPipe() {
        let safeRange = screen.minDim * 0.32
        let gapY = CGFloat.random(in: screen.height - screen.height + safeRange ... screen.height - safeRange)
        pipes.append(Pipe(x: screen.width + screen.scale(80), gapCenterY: gapY))
    }
    
    func checkCollisions() {
        let gapH = screen.gapHeight(for: selectedDifficulty.pipeGapRatio)
        let hitR = screen.hitboxSize / 2
        let birdL = screen.birdX - hitR
        
        for bi in bullets.indices.reversed() {
            for pi in pipes.indices.reversed() where !pipes[pi].destroyed {
                let b = bullets[bi], p = pipes[pi]
                if b.x > p.x && b.x < p.x + screen.pipeWidth {
                    pipes[pi].destroyed = true
                    hitExplosions.append(Explosion(x: b.x, y: b.y))
                    bullets.remove(at: bi)
                    score += 3
                    SoundManager.shared.playExplode()
                    SoundManager.shared.playRandomGreeting()
                    break
                }
            }
        }
        
        for pi in powerUps.indices.reversed() {
            let pu = powerUps[pi]
            if hypot(screen.birdX - pu.x, birdY - pu.y) < hitR + screen.gunSize/2 {
                powerUps.remove(at: pi)
                SoundManager.shared.playPickup()
                ammoCount = pu.gun.ammo
                activeGun = pu.gun
                startAutoFire()
            }
        }
        
        for pi in pipes.indices where !pipes[pi].destroyed && !bypassMode {
            let p = pipes[pi]
            let gapTop = p.gapCenterY - gapH/2, gapBottom = p.gapCenterY + gapH/2
            let pipeL = p.x, pipeR = p.x + screen.pipeWidth
            let birdR = screen.birdX + hitR
            if birdR > pipeL && birdL < pipeR {
                if prevBirdY - hitR < gapTop || prevBirdY + hitR > gapBottom || birdY - hitR < gapTop || birdY + hitR > gapBottom {
                    gameOver()
                    return
                }
            }
            if !p.passed && pipeR < screen.birdX {
                pipes[pi].passed = true
                score += 1
                SoundManager.shared.playScore(selectedCharacter)
                SoundManager.shared.playRandomGreeting()
                if HighScoreManager.shared.checkMilestone(score) {
                    showMilestone = true
                    SoundManager.shared.playMilestone()
                }
                if Double.random(in: 0...1) < 0.22 {
                    let randomGun = GunType.allCases.randomElement()!
                    powerUps.append(PowerUp(x: screen.width + screen.scale(60), y: CGFloat.random(in: screen.scale(150)...screen.height-screen.scale(150)), gun: randomGun))
                }
            }
        }
    }
    
    func gameOver() {
        SoundManager.shared.stopGreeting()
        gameState = .gameOver
        stopAutoFire()
        SoundManager.shared.playGameOver(selectedCharacter)
        HighScoreManager.shared.saveHighScore(selectedDifficulty, score)
        coinManager.addCoins(from: score)
    }
}

// MARK: - 📋 READY & GAME OVER VIEWS

struct ReadyView: View {
    let char: CharacterType, diff: Difficulty, theme: GameTheme, start: () -> Void
    @ObservedObject var screen = AdaptiveScreenManager.shared
    
    var body: some View {
        let s = screen.scale
        
        return VStack(spacing: s(12)) {
            Text(String(char.rawValue.prefix(2))).font(.system(size: s(60)))
            Text("READY TO FLY?").font(.system(size: s(26), weight: .heavy)).foregroundColor(theme.primaryText)
            Text("Theme: \(theme.rawValue)")
                .font(.system(size: s(14)))
                .foregroundColor(theme.secondaryText)
            Text("Difficulty: \(diff.rawValue) | 🏆 Best: \(HighScoreManager.shared.getHighScore(diff))")
                .font(.system(size: s(16))).foregroundColor(theme.secondaryText)
            Text("👆 Tap = Jump | 🟢3 🟣5 🔴7 Bullets | 🪙 100 Score = 1 Coin")
                .font(.system(size: s(12), weight: .bold)).foregroundColor(.orange)
            Text("TAP ANYWHERE TO START").font(.system(size: s(16), weight: .bold)).foregroundColor(theme.secondaryText.opacity(0.95))
        }
        .padding(.bottom, s(80))
    }
}

struct GameOverView: View {
    let score: Int, diff: Difficulty, theme: GameTheme, earnedCoins: Int
    let restart: () -> Void, settings: () -> Void
    @ObservedObject var screen = AdaptiveScreenManager.shared
    
    var body: some View {
        let s = screen.scale
        
        return VStack(spacing: s(10)) {
            Text("GAME OVER 😢").font(.system(size: s(30), weight: .heavy)).foregroundColor(theme.primaryText)
            Text("Score: \(score)").font(.system(size: s(36), weight: .bold)).foregroundColor(theme.secondaryText)
            if earnedCoins > 0 {
                Text("🪙 Earned: +\(earnedCoins) Coins!").font(.system(size: s(18), weight: .semibold)).foregroundColor(.yellow)
            }
            Text("🏆 Best: \(HighScoreManager.shared.getHighScore(diff))").font(.system(size: s(18))).foregroundColor(theme.secondaryText)
            HStack(spacing: s(15)) {
                Button(action: restart) {
                    Text("🔄 RESTART")
                        .font(.system(size: s(16), weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, s(24))
                        .padding(.vertical, s(12))
                        .background(Color.green)
                        .cornerRadius(s(12))
                }
                .buttonStyle(.plain)
                
                Button(action: settings) {
                    Text("⚙️ SETTINGS")
                        .font(.system(size: s(16), weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, s(24))
                        .padding(.vertical, s(12))
                        .background(Color.blue)
                        .cornerRadius(s(12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, s(80))
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

