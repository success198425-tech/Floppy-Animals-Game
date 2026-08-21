

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
    var baseColor: Color { [.green:Color(red:0.18, green:0.72, blue:0.28), .purple:Color(red:0.48, green:0.22, blue:0.78), .red:Color(red:0.82, green:0.18, blue:0.18)][self]! }
    var lightColor: Color { [.green:Color(red:0.35, green:0.92, blue:0.45), .purple:Color(red:0.65, green:0.40, blue:0.98), .red:Color(red:1.0, green:0.35, blue:0.35)][self]! }
    var darkColor: Color { [.green:Color(red:0.08, green:0.42, blue:0.15), .purple:Color(red:0.25, green:0.10, blue:0.50), .red:Color(red:0.52, green:0.05, blue:0.05)][self]! }
}

// MARK: - 🎨 THEME SYSTEM — YOUR 5 THEMES!
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
}

// MARK: - 📏 DYNAMIC SCREEN
struct AdaptiveScreen {
    static var width: CGFloat { UIScreen.main.bounds.width }
    static var height: CGFloat { UIScreen.main.bounds.height }
    static var minDim: CGFloat { min(width, height) }
    static var maxDim: CGFloat { max(width, height) }
    static var isLandscape: Bool { width > height }
    
    static func scale(_ v: CGFloat) -> CGFloat { v * (minDim / 375) }
    static func gapHeight(for ratio: CGFloat) -> CGFloat { minDim * ratio }
    
    static let pipeWidth: CGFloat = scale(65)
    static let hitboxSize: CGFloat = scale(18)
    static var birdX: CGFloat { scale(isLandscape ? 70 : 85) }
    static let groundOffset: CGFloat = scale(55)
    static let ceilingOffset: CGFloat = scale(45)
    static let bulletSize: CGFloat = scale(12)
    static let gunSize: CGFloat = scale(48)
    static let charSize: CGFloat = scale(42)
}

// MARK: - 🔊 SOUND MANAGER
class SoundManager {
    static let shared = SoundManager()
    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    private func playSound(_ id: UInt32) { AudioServicesPlaySystemSound(id) }
    func playJump(_ c: CharacterType) { playSound([.monkey:1306, .chicken:1315, .bird:1307, .eagle:1318][c]!) }
    func playScore(_ c: CharacterType) { playSound([.monkey:1057, .chicken:1003, .bird:1004, .eagle:1113][c]!) }
    func playGameOver(_ c: CharacterType) { playSound([.monkey:1053, .chicken:1050, .bird:1052, .eagle:1058][c]!) }
    func playPickup() { playSound(1025) }
    func playShoot() { playSound(1103) }
    func playExplode() { playSound(1006) }
    func playSelect() { playSound(1104) }
    func playMilestone() { playSound(1325) }
}

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

// MARK: - 🎨 3D GUN VIEW
struct Realistic3DGun: View {
    let gun: GunType; let size: CGFloat
    @State private var pulse = false
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: size*0.12).fill(Color.black.opacity(0.3)).frame(width: size*1.8, height: size*0.55).offset(x: size*0.08, y: size*0.1).blur(radius: 4)
            RoundedRectangle(cornerRadius: size*0.12).fill(LinearGradient(colors: [gun.lightColor, gun.baseColor, gun.darkColor], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: size*1.8, height: size*0.55).shadow(color: gun.darkColor.opacity(0.5), radius: 4, x: 2, y: 3)
            RoundedRectangle(cornerRadius: size*0.06).fill(LinearGradient(colors: [Color.gray.opacity(0.9), Color(white:0.3), Color.black], startPoint: .top, endPoint: .bottom)).frame(width: size*0.7, height: size*0.22).offset(x: size*0.05, y: -size*0.02)
            RoundedRectangle(cornerRadius: size*0.08).fill(LinearGradient(colors: [Color(red:0.3, green:0.22, blue:0.15), Color(red:0.18, green:0.12, blue:0.08)], startPoint: .top, endPoint: .bottom)).frame(width: size*0.35, height: size*0.45).offset(x: size*0.75, y: size*0.28)
            RoundedRectangle(cornerRadius: size*0.12).fill(Color.white.opacity(0.25)).frame(width: size*1.5, height: size*0.18).blur(radius: 2).offset(x:0, y: -size*0.12)
            Text("\(gun.ammo)").font(.system(size: size*0.32, weight: .heavy, design: .rounded)).foregroundColor(.white).shadow(color: .black.opacity(0.6), radius:1, x:1, y:1).offset(x: size*1.2, y: -size*0.05)
        }
        .scaleEffect(pulse ? 1.05 : 1.0)
        .onAppear { withAnimation(.easeInOut(duration:1.2).repeatForever()) { pulse = true } }
    }
}

// MARK: - 🎮 MAIN GAME
struct ContentView: View {
    @State private var birdY = AdaptiveScreen.height/2
    @State private var prevBirdY = AdaptiveScreen.height/2
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
    private let timer = Timer.publish(every: 1/45, on: .main, in: .common).autoconnect()
    
    enum GameState { case settings, ready, playing, gameOver }
    struct Pipe: Identifiable { let id=UUID(); var x: CGFloat; var gapCenterY: CGFloat; var passed=false; var destroyed=false }
    struct Bullet: Identifiable { let id=UUID(); var x: CGFloat; var y: CGFloat }
    struct PowerUp: Identifiable { let id=UUID(); var x: CGFloat; var y: CGFloat; var gun: GunType }
    struct Explosion: Identifiable { let id=UUID(); var x: CGFloat; var y: CGFloat; var opacity=1.0 }
    
    var body: some View {
        ZStack {
            // ✨ LIVE THEME BACKGROUND — CHANGES WHEN YOU SELECT!
            selectedTheme.gradient.ignoresSafeArea()
            
            // Decorations match theme
            if selectedTheme == .theme1 || selectedTheme == .theme5 {
                Circle().fill(Color.yellow.opacity(0.9)).frame(width: AdaptiveScreen.scale(55))
                    .position(x: AdaptiveScreen.width - AdaptiveScreen.scale(60), y: AdaptiveScreen.scale(70))
            } else if selectedTheme == .theme4 {
                Circle().fill(Color(red:1.0, green:0.85, blue:0.20).opacity(0.85)).frame(width: AdaptiveScreen.scale(55))
                    .position(x: AdaptiveScreen.width - AdaptiveScreen.scale(60), y: AdaptiveScreen.scale(70))
            }
            Ellipse().fill(Color.white.opacity(0.15)).frame(width: AdaptiveScreen.scale(80), height: AdaptiveScreen.scale(35))
                .position(x: AdaptiveScreen.scale(120), y: AdaptiveScreen.scale(110))
            
            ForEach(powerUps) { Realistic3DGun(gun: $0.gun, size: AdaptiveScreen.gunSize).position(x: $0.x, y: $0.y) }
            ForEach(pipes) { if !$0.destroyed { BambooPipeView(pipe: $0, gapHeight: AdaptiveScreen.gapHeight(for: selectedDifficulty.pipeGapRatio), bypass: bypassMode) } }
            ForEach(bullets) { BulletView(b: $0, color: activeGun.baseColor) }
            ForEach(hitExplosions) { Circle().fill(activeGun.baseColor.opacity($0.opacity)).frame(width: AdaptiveScreen.scale(40)).blur(radius:6).position(x: $0.x, y: $0.y) }
            
            if gameState == .playing || gameState == .ready || gameState == .gameOver {
                AnimatedAnimalView(type: selectedCharacter, wingPhase: wingPhase, fallingAngle: min(max(Double(birdVelocity/15)*25, -25), 25))
                    .position(x: AdaptiveScreen.birdX, y: birdY)
            }
            
            if showMilestone {
                Text("🦅 SUPER SCORE! 🦅")
                    .font(.system(size: AdaptiveScreen.scale(28), weight: .heavy))
                    .foregroundColor(selectedTheme.accentColor)
                    .shadow(color: .orange, radius:4)
                    .transition(.scale.combined(with: .opacity))
                    .onAppear { DispatchQueue.main.asyncAfter(deadline: .now()+1.5) { showMilestone = false } }
            }
            
            VStack {
                if gameState == .playing {
                    HStack {
                        HStack(spacing:4) {
                            Realistic3DGun(gun: activeGun, size: AdaptiveScreen.scale(28))
                            Text("×\(ammoCount)").font(.system(size: AdaptiveScreen.scale(16), weight: .bold)).foregroundColor(ammoCount>0 ? selectedTheme.accentColor : .gray).shadow(color: .black.opacity(0.5), radius:1)
                        }
                        Spacer()
                        HStack(spacing:4) {
                            Image(systemName: "circle.fill").foregroundColor(.yellow).font(.system(size: AdaptiveScreen.scale(18)))
                            Text("\(coinManager.totalCoins)").font(.system(size: AdaptiveScreen.scale(18), weight: .bold)).foregroundColor(.yellow).shadow(color: .black.opacity(0.5), radius:1)
                        }
                        Spacer()
                        Text("\(score)").font(.system(size: AdaptiveScreen.scale(50), weight: .heavy)).foregroundColor(selectedTheme.accentColor).shadow(color: .black.opacity(0.3), radius:3)
                        Spacer()
                        Button { bypassMode.toggle(); SoundManager.shared.playSelect() } label: {
                            Image(systemName: bypassMode ? "shield.fill" : "shield").font(.system(size: AdaptiveScreen.scale(22))).foregroundColor(bypassMode ? .green : selectedTheme.accentColor)
                        }
                    }
                    .padding(.top, AdaptiveScreen.scale(40)).padding(.horizontal)
                    if ammoCount > 0 { Text("🔥 AUTO-FIRE ACTIVE!").font(.system(size: AdaptiveScreen.scale(13), weight: .bold)).foregroundColor(activeGun.lightColor).shadow(color: .black.opacity(0.5), radius:1).padding(.top,2) }
                }
                Spacer()
                switch gameState {
                case .settings: SettingsView(char: $selectedCharacter, diff: $selectedDifficulty, theme: $selectedTheme, start: {
                    UserDefaults.standard.set(selectedTheme.rawValue, forKey: "SelectedTheme")
                    gameState = .ready
                })
                case .ready: ReadyView(char: selectedCharacter, diff: selectedDifficulty, theme: selectedTheme, start: startGame)
                case .playing: EmptyView()
                case .gameOver: GameOverView(score: score, diff: selectedDifficulty, theme: selectedTheme, earnedCoins: coinManager.sessionEarnedCoins, restart: startGame, settings: { gameState = .settings })
                }
            }
        }
        .onTapGesture { if gameState == .playing { jump() } else if gameState == .ready || gameState == .gameOver { startGame() } }
        .onReceive(timer) { _ in
            if gameState == .playing { updateGame(); wingPhase += 0.25; hitExplosions.indices.reversed().forEach { hitExplosions[$0].opacity -= 0.08 }; hitExplosions.removeAll { $0.opacity <= 0 } }
        }
    }
    
    func startGame() {
        gameState = .playing; birdY = AdaptiveScreen.height/2; prevBirdY = birdY; birdVelocity = 0
        pipes.removeAll(); bullets.removeAll(); powerUps.removeAll(); hitExplosions.removeAll()
        score = 0; ammoCount = 0; wingPhase = 0; showMilestone = false; activeGun = .green
        coinManager.sessionEarnedCoins = 0; HighScoreManager.shared.resetMilestone(); stopAutoFire(); addPipe()
    }
    func jump() { birdVelocity = selectedCharacter.jumpStrength; SoundManager.shared.playJump(selectedCharacter) }
    func startAutoFire() {
        stopAutoFire()
        autoFireTimer = Timer.scheduledTimer(withTimeInterval:0.35, repeats:true) { _ in
            if ammoCount>0 && gameState == .playing { ammoCount -= 1; bullets.append(Bullet(x: AdaptiveScreen.birdX + AdaptiveScreen.scale(32), y: birdY)); SoundManager.shared.playShoot() }
            else { stopAutoFire() }
        }
    }
    func stopAutoFire() { autoFireTimer?.invalidate(); autoFireTimer = nil }
    func updateGame() {
        prevBirdY = birdY; birdVelocity += Difficulty.normalGravity; birdY += birdVelocity
        if birdY > AdaptiveScreen.height - AdaptiveScreen.groundOffset { birdY = AdaptiveScreen.height - AdaptiveScreen.groundOffset; if !bypassMode { gameOver() }; return }
        if birdY < AdaptiveScreen.ceilingOffset { birdY = AdaptiveScreen.ceilingOffset; birdVelocity = 0 }
        pipes.indices.forEach { pipes[$0].x -= selectedDifficulty.pipeSpeed }
        bullets.indices.forEach { bullets[$0].x += 14 }
        powerUps.indices.forEach { powerUps[$0].x -= selectedDifficulty.pipeSpeed }
        if pipes.first?.x ?? 0 < -AdaptiveScreen.pipeWidth { pipes.removeFirst(); addPipe() }
        bullets.removeAll { $0.x > AdaptiveScreen.width + 50 }
        powerUps.removeAll { $0.x < -50 }
        checkCollisions()
    }
    func addPipe() {
        let safeRange = AdaptiveScreen.minDim * 0.32
        let gapY = CGFloat.random(in: AdaptiveScreen.height - AdaptiveScreen.height + safeRange ... AdaptiveScreen.height - safeRange)
        pipes.append(Pipe(x: AdaptiveScreen.width + AdaptiveScreen.scale(80), gapCenterY: gapY))
    }
    func checkCollisions() {
        let gapH = AdaptiveScreen.gapHeight(for: selectedDifficulty.pipeGapRatio)
        let hitR = AdaptiveScreen.hitboxSize / 2
        let birdL = AdaptiveScreen.birdX - hitR
        
        for bi in bullets.indices.reversed() {
            for pi in pipes.indices.reversed() where !pipes[pi].destroyed {
                let b = bullets[bi], p = pipes[pi]
                if b.x > p.x && b.x < p.x + AdaptiveScreen.pipeWidth {
                    pipes[pi].destroyed = true; hitExplosions.append(Explosion(x: b.x, y: b.y)); bullets.remove(at: bi); score += 3; SoundManager.shared.playExplode(); break
                }
            }
        }
        for pi in powerUps.indices.reversed() {
            let pu = powerUps[pi]
            if hypot(AdaptiveScreen.birdX - pu.x, birdY - pu.y) < hitR + AdaptiveScreen.gunSize/2 {
                powerUps.remove(at: pi); SoundManager.shared.playPickup(); ammoCount = pu.gun.ammo; activeGun = pu.gun; startAutoFire()
            }
        }
        for pi in pipes.indices where !pipes[pi].destroyed && !bypassMode {
            let p = pipes[pi]
            let gapTop = p.gapCenterY - gapH/2, gapBottom = p.gapCenterY + gapH/2
            let pipeL = p.x, pipeR = p.x + AdaptiveScreen.pipeWidth
            let birdR = AdaptiveScreen.birdX + hitR
            if birdR > pipeL && birdL < pipeR {
                if prevBirdY - hitR < gapTop || prevBirdY + hitR > gapBottom || birdY - hitR < gapTop || birdY + hitR > gapBottom { gameOver(); return }
            }
            if !p.passed && pipeR < AdaptiveScreen.birdX {
                pipes[pi].passed = true; score += 1; SoundManager.shared.playScore(selectedCharacter)
                if HighScoreManager.shared.checkMilestone(score) { showMilestone = true; SoundManager.shared.playMilestone() }
                if Double.random(in: 0...1) < 0.22 {
                    let randomGun = GunType.allCases.randomElement()!
                    powerUps.append(PowerUp(x: AdaptiveScreen.width + AdaptiveScreen.scale(60), y: CGFloat.random(in: AdaptiveScreen.scale(150)...AdaptiveScreen.height-AdaptiveScreen.scale(150)), gun: randomGun))
                }
            }
        }
    }
    func gameOver() {
        gameState = .gameOver; stopAutoFire(); SoundManager.shared.playGameOver(selectedCharacter)
        HighScoreManager.shared.saveHighScore(selectedDifficulty, score); coinManager.addCoins(from: score)
    }
}

// MARK: - 🎨 ANIMALS & PIPES
struct AnimatedAnimalView: View {
    let type: CharacterType, wingPhase: Double, fallingAngle: Double
    let s = AdaptiveScreen.scale
    var body: some View {
        ZStack {
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
    let s = AdaptiveScreen.scale, w = AdaptiveScreen.pipeWidth
    var body: some View {
        let gapTop = pipe.gapCenterY - gapHeight/2
        let bambooGradient = LinearGradient(colors: [
            Color(red:0.76, green:0.87, blue:0.48),
            Color(red:0.62, green:0.77, blue:0.32),
            Color(red:0.76, green:0.87, blue:0.48)
        ], startPoint: .leading, endPoint: .trailing)
        ZStack {
            VStack(spacing:0) {
                Rectangle().fill(bambooGradient).frame(width:w, height:gapTop)
                ForEach(0..<Int(gapTop/40), id:\.self) { _ in Rectangle().fill(Color(red:0.35, green:0.50, blue:0.20)).frame(height:2) }
            }.frame(width:w, height:gapTop).position(x: pipe.x + w/2, y: gapTop/2)
            VStack(spacing:0) {
                ForEach(0..<Int((AdaptiveScreen.maxDim - gapTop - gapHeight)/40), id:\.self) { _ in Rectangle().fill(Color(red:0.35, green:0.50, blue:0.20)).frame(height:2) }
                Rectangle().fill(bambooGradient).frame(width:w, height: AdaptiveScreen.maxDim - gapTop - gapHeight)
            }.frame(width:w, height: AdaptiveScreen.maxDim - gapTop - gapHeight)
            .position(x: pipe.x + w/2, y: gapTop + gapHeight + (AdaptiveScreen.maxDim - gapTop - gapHeight)/2)
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
    var body: some View {
        Circle().fill(RadialGradient(colors: [color.opacity(0.8), color], center: .center, startRadius:0, endRadius: AdaptiveScreen.bulletSize/2))
            .frame(width: AdaptiveScreen.bulletSize)
            .shadow(color: color, radius:3)
            .position(x: b.x, y: b.y)
    }
}

// MARK: - 📋 UI SCREENS WITH THEME SELECTOR
struct SettingsView: View {
    @Binding var char: CharacterType
    @Binding var diff: Difficulty
    @Binding var theme: GameTheme
    let start: () -> Void
    let s = AdaptiveScreen.scale
    
    var body: some View {
        VStack(spacing: s(16)) {
            // THEME SELECTOR — NEW!
            VStack(spacing: s(10)) {
                Text("🎨 SELECT THEME")
                    .font(.system(size: s(18), weight: .bold)).foregroundColor(.white)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: s(10)) {
                        ForEach(GameTheme.allCases) { t in
                            Button { theme = t; SoundManager.shared.playSelect() } label: {
                                VStack(spacing: 4) {
                                    Text(String(t.rawValue.split(separator: ". ").last!))
                                        .font(.system(size: s(12), weight: .bold))
                                        .foregroundColor(theme == t ? .white : .white.opacity(0.8))
                                    if t == .theme4 { Text("⭐ RECOMMENDED").font(.system(size: s(9))).foregroundColor(.yellow) }
                                }
                                .padding(.horizontal, s(12)).padding(.vertical, s(8))
                                .background(theme == t ? Color.white.opacity(0.35) : Color.white.opacity(0.12))
                                .cornerRadius(s(10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            VStack(spacing: s(12)) {
                Text("⚙️ SELECT CHARACTER")
                    .font(.system(size: s(18), weight: .bold)).foregroundColor(.white)
                HStack(spacing: s(10)) {
                    ForEach(CharacterType.allCases) { c in
                        Button { char = c; SoundManager.shared.playSelect() } label: {
                            Text(String(c.rawValue.prefix(2))).font(.system(size: s(30)))
                                .frame(width: s(65), height: s(75))
                                .background(char == c ? Color.white.opacity(0.35) : .white.opacity(0.12))
                                .cornerRadius(s(10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            VStack(spacing: s(12)) {
                Text("🎯 SELECT DIFFICULTY")
                    .font(.system(size: s(18), weight: .bold)).foregroundColor(.white)
                HStack(spacing: s(10)) {
                    ForEach(Difficulty.allCases) { d in
                        Button { diff = d; SoundManager.shared.playSelect() } label: {
                            VStack(spacing: 4) {
                                Text(d.rawValue).font(.system(size: s(14), weight: .bold))
                                    .foregroundColor(.white)
                                Text("🏆 \(HighScoreManager.shared.getHighScore(d))")
                                    .font(.system(size: s(10))).foregroundColor(.yellow)
                            }
                            .frame(width: s(85), height: s(100))
                            .background(diff == d ? Color.white.opacity(0.35) : .white.opacity(0.12))
                            .cornerRadius(s(10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, s(15))
        
        Button(action: start) {
            Text("▶️ START GAME")
                .font(.system(size: s(18), weight: .heavy)).foregroundColor(.white)
                .padding(.horizontal, s(35)).padding(.vertical, s(12))
                .background(Color.green.opacity(0.8)).cornerRadius(s(12))
        }
        .buttonStyle(.plain)
        .padding(.top, s(15))
    }
}

struct ReadyView: View {
    let char: CharacterType, diff: Difficulty, theme: GameTheme, start: () -> Void
    let s = AdaptiveScreen.scale
    var body: some View {
        VStack(spacing: s(12)) {
            Text(String(char.rawValue.prefix(2))).font(.system(size: s(60)))
            Text("READY TO FLY?").font(.system(size: s(26), weight: .heavy)).foregroundColor(theme.accentColor)
            Text("Theme: \(theme.rawValue)")
                .font(.system(size: s(14))).foregroundColor(.white.opacity(0.8))
            Text("Difficulty: \(diff.rawValue) | 🏆 Best: \(HighScoreManager.shared.getHighScore(diff))")
                .font(.system(size: s(16))).foregroundColor(.white.opacity(0.8))
            Text("👆 Tap = Jump | 🟢3 🟣5 🔴7 Bullets | 🪙 100 Score = 1 Coin")
                .font(.system(size: s(12), weight: .bold)).foregroundColor(.orange)
            Text("TAP ANYWHERE TO START").font(.system(size: s(16), weight: .bold)).foregroundColor(.white.opacity(0.9))
        }
        .padding(.bottom, s(80))
    }
}

struct GameOverView: View {
    let score: Int, diff: Difficulty, theme: GameTheme, earnedCoins: Int
    let restart: () -> Void, settings: () -> Void
    let s = AdaptiveScreen.scale
    var body: some View {
        VStack(spacing: s(10)) {
            Text("GAME OVER 😢").font(.system(size: s(30), weight: .heavy)).foregroundColor(theme.accentColor)
            Text("Score: \(score)").font(.system(size: s(36), weight: .bold)).foregroundColor(.white)
            if earnedCoins > 0 {
                Text("🪙 +\(earnedCoins) Coins Earned!")
                    .font(.system(size: s(18), weight: .bold)).foregroundColor(.yellow)
            }
            Text("🏆 Best for \(diff.rawValue): \(HighScoreManager.shared.getHighScore(diff))")
                .font(.system(size: s(18))).foregroundColor(.yellow)
            Text("TAP ANYWHERE TO PLAY AGAIN").font(.system(size: s(16), weight: .bold)).foregroundColor(.white.opacity(0.9))
            Button("⚙️ CHANGE SETTINGS", action: settings)
                .font(.system(size: s(14))).foregroundColor(.white.opacity(0.8))
        }
        .padding(.bottom, s(90))
    }
}

#Preview { ContentView() }

