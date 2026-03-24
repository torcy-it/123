//
//  GameView.swift
//  AppGame123
//
//  Created by Adolfo Torcicollo on 12/12/25.
//
import SwiftUI

struct GameView: View {
    let onBack: () -> Void
    @EnvironmentObject private var appSettings: AppSettings
    @StateObject private var viewModel = GameViewModel()
    @Environment(\.watchLayoutMetrics) private var metrics
    @Environment(\.scenePhase) private var scenePhase
    
    
    private var isPlayerTurn: Bool {
        switch viewModel.turnState {
        case .normal(let playerTurn):
            return playerTurn
        case .forced(let playerTurn, _):
            return playerTurn
        default:
            return false
        }
    }

    /// Chi inizia quando la pila è vuota (dopo aver preso le carte)
    private var whoStartsWhenPileEmpty: Bool {
        switch viewModel.turnState {
        case .collecting(let collectorIsPlayer):
            return collectorIsPlayer  // chi ha preso le carte inizia
        case .normal(let playerTurn), .forced(let playerTurn, _):
            return playerTurn
        default:
            return false
        }
    }
    
    private var collectingMessage: String? {
        if case .collecting(let collectorIsPlayer) = viewModel.turnState {
            return collectorIsPlayer
            ? appSettings.text(.game_you_took_all_table)
            : appSettings.text(.game_cpu_took_all_table)
        }
        return nil
    }
    
    private var starburstMessage: String? {
        if let collecting = collectingMessage {
            return collecting
        }

        if viewModel.showMessage {
            return viewModel.gameMessage
        }

        return nil
    }
    
    private var isPaused: Bool {
        if case .paused = viewModel.turnState { return true }
        return false
    }
    
    var body: some View {
        ZStack {
            // Background - dietro a tutto
            BackgroundTexture()
                .ignoresSafeArea()
                .zIndex(0)
            
            VStack(spacing: 0) {
                
                ZStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 0) {
                        Button(action: {
                            if !viewModel.gameOver {
                                viewModel.pause()
                            }
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: metrics.scaled(12)))
                                .foregroundColor(.black)
                                .frame(width: metrics.scaled(28), height: metrics.scaled(28))
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(red: 209/255, green: 211/255, blue: 38/255))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                        .fixedSize()
                        Spacer(minLength: 0)
                    }
                    
                    Text(appSettings.text(.game_cards_title))
                        .font(.custom("PressStart2P-Regular", size: metrics.scaledText(16)))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, metrics.scaled(10))
                .padding(.vertical, metrics.scaled(4))
                .padding(.top, metrics.scaled(16))
                
                                    
                // Info giocatori + bottone tutorial
                HStack(alignment: .center, spacing: metrics.scaled(8)) {
                    HStack(spacing: metrics.scaled(12)) {
                        VStack(spacing: metrics.scaled(2)) {
                            Text(appSettings.text(.game_you))
                                .font(.custom("PressStart2P-Regular", size: metrics.scaledText(10)))
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(viewModel.playerDeck.count)")
                                .font(.custom("PressStart2P-Regular", size: metrics.scaledText(18)))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: metrics.scaled(2)) {
                            Text(appSettings.text(.game_cpu))
                                .font(.custom("PressStart2P-Regular", size: metrics.scaledText(10)))
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(viewModel.cpuDeck.count)")
                                .font(.custom("PressStart2P-Regular", size: metrics.scaledText(18)))
                                .foregroundColor(.white)
                        }
                    }
                    
                    
                }
                .padding(.horizontal, metrics.scaled(10))
                .padding(.top, metrics.scaled(12))
                
                Spacer().frame(height: metrics.scaled(12))
                
                Text(viewModel.displayMessage)
                    .font(.custom("PressStart2P-Regular", size: metrics.scaledText(12)))
                    .foregroundColor(
                        viewModel.displayColor == "green"
                            ? Color(red: 0/255, green: 255/255, blue: 100/255)
                            : viewModel.displayColor == "pink"
                            ? Color(red: 218/255, green: 0/255, blue: 206/255)
                            : Color(red: 255/255, green: 200/255, blue: 0/255)
                    )
                    .multilineTextAlignment(.center)
                
                ZStack(alignment: .top) {
                    if !viewModel.visiblePile.isEmpty {
                        let visibleCards = viewModel.visiblePile

                        ForEach(visibleCards.indices, id: \.self) { i in
                            let entry = visibleCards[i]
                            let slot = i % 3
                            let isLast = i == visibleCards.count - 1

                            CardView(
                                card: entry.card,
                                isPlayerCard: entry.isPlayer,
                                isLastPlayed: isLast,
                                scale: metrics.scale
                            )
                            .scaleEffect(0.60)
                            .rotationEffect(.degrees(rotationForSlot(slot)))
                            .offset(
                                x: offsetXForSlot(slot) * metrics.scale,
                                y: offsetYForSlot(slot) * metrics.scale
                            )
                            .zIndex(Double(i))
                        }
                    } else {
                        VStack(spacing: metrics.scaled(15)) {
                            Text(whoStartsWhenPileEmpty ? appSettings.text(.game_you_start) : appSettings.text(.game_cpu_start))
                                .font(.custom("PressStart2P-Regular", size: metrics.scaledText(12)))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: metrics.scaled(100))
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.top, metrics.scaled(-12))
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isPaused {
                        viewModel.playerTap()
                    }
                }
                .padding(.bottom, metrics.scaled(8))
            
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, metrics.scaled(4))
            .padding(.top, metrics.scaled(4))
            .ignoresSafeArea(edges: .top)
            .zIndex(1)

            
            // FINESTRA PAUSA
            if isPaused && !viewModel.gameOver {
                ZStack {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                    VStack(spacing: metrics.scaled(8)) {
                        Spacer().frame(height: metrics.scaled(2))
                        
                        Text(appSettings.text(.game_paused))
                            .font(.custom("PressStart2P-Regular", size: metrics.scaledText(15)))
                            .foregroundColor(.white)
                        
                        Spacer().frame(height: metrics.scaled(4))
                        
                        
                        PixelButton(
                            text: appSettings.text(.game_resume),
                            action: {
                                viewModel.resume()
                            },
                            width: metrics.scaled(170),
                            height: metrics.scaled(40),
                            primaryColor: Color(red: 0/255, green: 255/255, blue: 120/255),
                            secondaryColor: Color(red: 0/255, green: 140/255, blue: 70/255),
                            highlightedColor: Color(red: 180/255, green: 255/255, blue: 210/255),
                            textColor: Color.black
                        )
                        
                        Spacer().frame(height: metrics.scaled(4))
                        
                        PixelButton(
                            text: appSettings.text(.game_main_menu),
                            action: {
                                onBack()
                            },
                            width: metrics.scaled(170),
                            height: metrics.scaled(40),
                            primaryColor: Color(red: 218/255, green: 0/255, blue: 206/255),
                            secondaryColor: Color(red: 134/255, green: 0/255, blue: 126/255),
                            highlightedColor: Color(red: 250/255, green: 115/255, blue: 251/255),
                            textColor: Color.white
                        )
                        
                        Spacer().frame(height: metrics.scaled(4))

                
                    }
                    .padding(metrics.scaled(8))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    )
                    .padding(metrics.scaled(6))
                    
                }.offset(y: metrics.scaled(-35))
                .zIndex(3)
            }
            
            // Game Over
            if viewModel.gameOver {
                ZStack {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                    VStack(spacing: metrics.scaled(8)) {
                        Spacer().frame(height: metrics.scaled(2))
                        
                        Text(appSettings.text(.game_over))
                            .font(.custom("PressStart2P-Regular", size: metrics.scaledText(15)))
                            .foregroundColor(.white)
                        
                        Spacer().frame(height: metrics.scaled(4))
                        
                        Text(viewModel.winner.uppercased() == "PLAYER" ? appSettings.text(.game_you_win) : appSettings.text(.game_house_wins))
                            .font(.custom("PressStart2P-Regular", size: metrics.scaledText(8)))
                            .foregroundColor(Color(red: 0/255, green: 255/255, blue: 100/255))
                            .multilineTextAlignment(.center)
                        
                        PixelButton(
                            text: appSettings.text(.game_main_menu),
                            action: {
                                onBack()
                            },
                            width: metrics.scaled(180),
                            height: metrics.scaled(40),
                            primaryColor: Color(red: 218/255, green: 0/255, blue: 206/255),
                            secondaryColor: Color(red: 134/255, green: 0/255, blue: 126/255),
                            highlightedColor: Color(red: 250/255, green: 115/255, blue: 251/255),
                            textColor: Color.white
                        )
                        
                        Spacer().frame(height: metrics.scaled(4))
                    }
                    .padding(metrics.scaled(8))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    )
                    .padding(metrics.scaled(6))
                }
                .offset(y: metrics.scaled(-35))
                .zIndex(3)
            }
        }
        .onAppear {
            viewModel.configure(settings: appSettings)
        }
        .onChange(of: appSettings.language) { _ in
            viewModel.applySettingsUpdate(settings: appSettings)
        }
        .onChange(of: appSettings.difficulty) { _ in
            viewModel.applySettingsUpdate(settings: appSettings)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .inactive, .background:
                viewModel.pause()
            case .active:
                break
            @unknown default:
                break
            }
        }
        .overlay {
            if let message = viewModel.notificationMessage {
                ZStack {
                    Color.black.opacity(0.55)
                    NotificationBannerView(message: message, scale: metrics.scale)
                        .offset(y: starburstOffsetY(for: message) + notificationBannerVerticalBias)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .transition(.opacity)
            }
        }
    }
    

    /// Compensa il testo più compatto nello starburst (sembra più in alto senza questo).
    private var notificationBannerVerticalBias: CGFloat { metrics.scaled(14) }

    private func starburstOffsetY(for message: String) -> CGFloat {
        let u = message.uppercased()
        if u.contains("CAUGHT") || u.contains("CATTUR") { return metrics.scaled(40) }
        if u.contains("PENALTY") || u.contains("PENAL") { return metrics.scaled(-5) }
        if u.contains("TAKE") || u.contains("PREND") { return metrics.scaled(-5) }
        return metrics.scaled(0)
    }

    private func rotationForSlot(_ slot: Int) -> Double {
        switch slot {
        case 0: return -25
        case 1: return 0
        case 2: return 25
        default: return 0
        }
    }

    private func offsetXForSlot(_ slot: Int) -> CGFloat {
        switch slot {
        case 0: return -60
        case 1: return 0
        case 2: return 60
        default: return 0
        }
    }

    private func offsetYForSlot(_ slot: Int) -> CGFloat {
        switch slot {
        case 1: return -8
        default: return 8
        }
    }
}

// MARK: - Card View
struct CardView: View {
    let card: Card
    let isPlayerCard: Bool
    let isLastPlayed: Bool
    var scale: CGFloat = 1.0

    private var cardWidth: CGFloat { 140 * scale }
    private var cardHeight: CGFloat { 200 * scale }
    private var inset: CGFloat { 14 * scale }

    var body: some View {
        ZStack {
            // Ombra
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .frame(width: cardWidth, height: cardHeight)
                .offset(x: 4 * scale, y: 6 * scale)

            // Carta
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isPlayerCard
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 100/255, green: 255/255, blue: 100/255),
                                Color(red: 80/255, green: 240/255, blue: 80/255)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                      )
                    : AnyShapeStyle(
                        Color(red: 209/255, green: 211/255, blue: 38/255)
                      )
                )

                .frame(width: cardWidth, height: cardHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: max(2, 4 * scale))
                )

            // Numero centrale
            PixelNumber(value: card.value, size: 64 * scale)
        }
        // Angoli — overlay separati e sicuri
        .overlay(alignment: .topLeading) {
            cornerNumber
                .padding(inset)
        }
        .overlay(alignment: .topTrailing) {
            cornerNumber
                .padding(inset)
        }
        .overlay(alignment: .bottomLeading) {
            cornerNumber
                .padding(inset)
        }
        .overlay(alignment: .bottomTrailing) {
            cornerNumber
                .padding(inset)
        }
    }

    private var cornerNumber: some View {
        PixelNumber(value: card.value, size: 18 * scale)
    }
}

// MARK: - Pixel Number (per numeri in stile pixel)
struct PixelNumber: View {
    let value: Int
    var size: CGFloat = 24
    
    var body: some View {
        Text("\(value)")
            .font(.custom("PressStart2P-Regular", size: size))
            .foregroundColor(.black)
    }
}

// MARK: - Notification Banner (YOU BEAT CPU, THE TEN!, ecc.) - stile esplosione comics
// Testo vincolato all’area centrale dello starburst: frame fisso + minimumScaleFactor basso
// così le frasi lunghe (EN/IT) si restringono invece di uscire dalle punte.
struct NotificationBannerView: View {
    let message: String
    var scale: CGFloat = 1.0
    
    private var bannerWidth: CGFloat { 300 * scale }
    private var bannerHeight: CGFloat { 110 * scale }
    
    /// Rettangolo massimo per il testo, dentro la parte “piena” della stella (non le punte).
    private var textBoxWidth: CGFloat { bannerWidth * 0.70 }
    private var textBoxHeight: CGFloat { bannerHeight * 0.66 }
    
    private var bannerBurst: StarburstShape {
        StarburstShape(
            points: 16,
            innerRadiusRatio: 0.74,
            horizontalStretch: 2.45,
            verticalStretch: 1.0
        )
    }
    
    var body: some View {
        ZStack {
            bannerBurst
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 255/255, green: 235/255, blue: 80/255),
                            Color(red: 255/255, green: 200/255, blue: 30/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(bannerBurst.stroke(Color.black, lineWidth: 3))
                .shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
            
            Text(message)
                .font(.custom("PressStart2P-Regular", size: 11 * scale))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(1 * scale)
                .lineLimit(12)
                .minimumScaleFactor(0.12)
                .frame(width: textBoxWidth, height: textBoxHeight, alignment: .center)
        }
        .frame(width: bannerWidth, height: bannerHeight)
    }
}

struct StarburstShape: Shape {
    let points: Int
    let innerRadiusRatio: CGFloat
    let horizontalStretch: CGFloat
    let verticalStretch: CGFloat

    init(
        points: Int = 16,
        innerRadiusRatio: CGFloat = 0.55,
        horizontalStretch: CGFloat = 1.45,
        verticalStretch: CGFloat = 1.15
    ) {
        self.points = points
        self.innerRadiusRatio = innerRadiusRatio
        self.horizontalStretch = horizontalStretch
        self.verticalStretch = verticalStretch
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let baseRadius = min(rect.width, rect.height) / 2
        let outerRadius = baseRadius
        let innerRadius = baseRadius * innerRadiusRatio

        let angleStep = .pi * 2 / CGFloat(points * 2)

        var path = Path()

        for i in 0..<(points * 2) {
            let radius: CGFloat
            if i.isMultiple(of: 2) {
                radius = outerRadius
            } else {
                // irregolarità fumetto
                radius = innerRadius * (i.isMultiple(of: 4) ? 0.9 : 1.1)
            }

            let angle = CGFloat(i) * angleStep - .pi / 2

            let x = center.x + cos(angle) * radius * horizontalStretch
            let y = center.y + sin(angle) * radius * verticalStretch

            let point = CGPoint(x: x, y: y)

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}




#Preview("Game") {
    GeometryReader { geo in
        GameView(onBack: {})
            .environment(\.watchLayoutMetrics, WatchLayoutMetrics.from(proxy: geo))
            .environmentObject(AppSettings.preview)
    }
    .previewDevice("Apple Watch Series 10 (41mm)")
}

#Preview("Notification Banner") {
    ZStack {
        Color.gray.opacity(0.3)
        VStack(spacing: 8) {
            NotificationBannerView(message: "YOU CAUGHT\nA TEN", scale: 1.0)
            NotificationBannerView(message: "CPU TAKES THE CARDS", scale: 1.0)
            NotificationBannerView(message: "LA CPU HA PRESO\nTUTTE LE CARTE SUL\nTAVOLO !!", scale: 0.48)
        }
    }
    .previewDevice("Apple Watch Series 10 (41mm)")
}



