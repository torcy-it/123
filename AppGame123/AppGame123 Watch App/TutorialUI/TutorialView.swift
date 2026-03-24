//
//  TutorialView.swift
//  AppGame123
//
//  Created by Adolfo Torcicollo on 12/12/25.
//

import SwiftUI

struct TutorialView: View {
    @StateObject var tutorialVM: TutorialViewModel
    let onFinish: () -> Void
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.watchLayoutMetrics) private var metrics
    @State private var isTutorialPaused = false

    // MARK: - Posizione pausa quando c’è la finestrella
    // Valori in “punti” (~@1x); in UI usiamo `metrics.scaled(...)`.
    // Aumenta `leading` → bottone verso destra | `top` → verso il basso.
    // `offset`: ritocco fine (x+ destra, y+ giù).
    private let tutorialOverlayPauseLeadingPoints: CGFloat = 2
    private let tutorialOverlayPauseTopPoints: CGFloat = 2
    private let tutorialOverlayPauseOffsetXPoints: CGFloat = 4
    private let tutorialOverlayPauseOffsetYPoints: CGFloat = 15
    /// Margine sotto al bottone per lo `Color.clear` della HUD (allinea a `top + altezza bottone ~28 + questo`)
    private let tutorialOverlayPauseBelowButtonPoints: CGFloat = 8

    var body: some View {
        ZStack(alignment: .top) {
            BackgroundTexture()
                .ignoresSafeArea()

            // Layout identico a GameView (con finestrella: header solo sopra l’overlay, qui solo spazio)
            VStack(spacing: 0) {
                Group {
                    if tutorialVM.showDarkOverlay {
                        Color.clear
                            .frame(height: tutorialOverlayTopClearHeight)
                    } else {
                        tutorialHeader
                    }
                }
                tutorialHUD
                Spacer().frame(height: metrics.scaled(12))
                demoDisplayMessage
                demoCardArea
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, metrics.scaled(4))
            .padding(.top, metrics.scaled(0))
            .ignoresSafeArea(edges: .top)
            .padding(.bottom, metrics.scaled(8))

            // Overlay fullscreen con finestrella centrata (come prima); pausa in alto a sinistra fuori dal box
            if tutorialVM.showDarkOverlay {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                    .overlay(alignment: .center) {
                        darkOverlayFinestrellaCard
                    }
                    .zIndex(1)

                ZStack(alignment: .topLeading) {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)
                    pauseToolbarButton { isTutorialPaused = true }
                        .padding(.leading, metrics.scaled(tutorialOverlayPauseLeadingPoints))
                        .padding(.top, metrics.scaled(tutorialOverlayPauseTopPoints))
                        .offset(
                            x: metrics.scaled(tutorialOverlayPauseOffsetXPoints),
                            y: metrics.scaled(tutorialOverlayPauseOffsetYPoints)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .ignoresSafeArea(edges: .top)
                .zIndex(2)
            }
        }
        .overlay {
            if tutorialVM.showStarburst {
                ZStack {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                    NotificationBannerView(message: tutorialVM.starburstMessage, scale: metrics.scale)
                        .offset(y: starburstOffsetY(for: tutorialVM.starburstMessage) + notificationBannerVerticalBias)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .transition(.opacity)
            }
        }
        .overlay {
            if isTutorialPaused {
                tutorialPauseMenu
            }
        }
        .onAppear {
            tutorialVM.bind(settings: appSettings)
            tutorialVM.start()
        }
        .onChange(of: appSettings.language) { _ in
            tutorialVM.bind(settings: appSettings)
        }
    }

    /// Spazio sotto al pulsante pausa in overlay, per non far saltare la HUD (aggiorna se cambi altezza bottone).
    private var tutorialOverlayTopClearHeight: CGFloat {
        metrics.scaled(tutorialOverlayPauseTopPoints + 28 + tutorialOverlayPauseBelowButtonPoints)
            + metrics.scaled(tutorialOverlayPauseOffsetYPoints)
    }

    /// Contenuto tappabile della finestrella (centrata sull’overlay).
    private var darkOverlayFinestrellaCard: some View {
        VStack(spacing: metrics.scaled(12)) {
            Text(tutorialVM.darkOverlayText)
                .font(.custom("PressStart2P-Regular", size: metrics.scaledText(12)))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .lineLimit(nil)
            if tutorialVM.waitingForTap {
                if tutorialVM.isLastStep {
                    // Stesso stile del bottone viola «START GAME» in ContentView + icona casa (menu principale)
                    PixelButton(
                        text: appSettings.text(.game_main_menu),
                        action: { onFinish() },
                        width: metrics.scaled(190),
                        primaryColor: Color(red: 218/255, green: 0/255, blue: 206/255),
                        secondaryColor: Color(red: 134/255, green: 0/255, blue: 126/255),
                        highlightedColor: Color(red: 250/255, green: 115/255, blue: 251/255),
                        textColor: Color.white
                    )
                } else {
                    Text(appSettings.text(.tutorial_tap_to_continue))
                        .font(.custom("PressStart2P-Regular", size: metrics.scaledText(9)))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, metrics.scaled(20))
        .padding(.vertical, metrics.scaled(34))
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(metrics.scaled(6))
        .contentShape(Rectangle())
        .onTapGesture {
            if tutorialVM.waitingForTap, !tutorialVM.isLastStep {
                tutorialVM.tapScreen()
            }
        }
    }

    @ViewBuilder
    private func pauseToolbarButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
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
    }

    /// Stessa finestra pausa di `GameView` (RESUME / MAIN MENU).
    private var tutorialPauseMenu: some View {
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
                    action: { isTutorialPaused = false },
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
                        isTutorialPaused = false
                        onFinish()
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
        }
        .offset(y: metrics.scaled(-35))
    }

    private var tutorialHeader: some View {
        ZStack(alignment: .center) {
            HStack(alignment: .center, spacing: 0) {
                pauseToolbarButton { isTutorialPaused = true }
                Spacer(minLength: 0)
            }
            Text(appSettings.text(.game_cards_title))
                .font(.custom("PressStart2P-Regular", size: metrics.scaledText(16)))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, metrics.scaled(10))
        .padding(.vertical, metrics.scaled(4))
        .padding(.top, metrics.scaled(8))
    }

    private var tutorialHUD: some View {
        VStack(spacing: 0) {
            HStack(spacing: metrics.scaled(12)) {
                VStack(spacing: metrics.scaled(2)) {
                    Text(appSettings.text(.game_you))
                        .font(.custom("PressStart2P-Regular", size: metrics.scaledText(10)))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(tutorialVM.demoYouCount)")
                        .font(.custom("PressStart2P-Regular", size: metrics.scaledText(18)))
                        .foregroundColor(.white)
                }
                VStack(spacing: metrics.scaled(2)) {
                    Text(appSettings.text(.game_cpu))
                        .font(.custom("PressStart2P-Regular", size: metrics.scaledText(10)))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(tutorialVM.demoCpuCount)")
                        .font(.custom("PressStart2P-Regular", size: metrics.scaledText(18)))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, metrics.scaled(10))
            .padding(.top, metrics.scaled(12))
        }
    }

    private var demoDisplayMessage: some View {
        Text(tutorialVM.demoActionText)
            .font(.custom("PressStart2P-Regular", size: metrics.scaledText(12)))
            .foregroundColor(
                tutorialVM.demoDisplayColor == "green"
                    ? Color(red: 0/255, green: 255/255, blue: 100/255)
                    : tutorialVM.demoDisplayColor == "pink"
                    ? Color(red: 218/255, green: 0/255, blue: 206/255)
                    : Color(red: 255/255, green: 200/255, blue: 0/255)
            )
            .multilineTextAlignment(.center)
    }

    /// Stesso schema di `GameView`: ventaglio con `scaleEffect`, area che riempie il resto dello schermo.
    private var demoCardArea: some View {
        ZStack(alignment: .top) {
            if !tutorialVM.demoVisibleCards.isEmpty {
                ForEach(Array(tutorialVM.demoVisibleCards.enumerated()), id: \.offset) { i, entry in
                    let slot = i % 3
                    CardView(
                        card: Card(value: entry.value),
                        isPlayerCard: entry.isPlayer,
                        isLastPlayed: i == tutorialVM.demoVisibleCards.count - 1,
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
            } else if let whoStarts = tutorialVM.demoWhoStartsWhenEmpty {
                VStack(spacing: metrics.scaled(15)) {
                    Text(whoStarts ? appSettings.text(.game_you_start) : appSettings.text(.game_cpu_start))
                        .font(.custom("PressStart2P-Regular", size: metrics.scaledText(12)))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(height: metrics.scaled(100))
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.top, metrics.scaled(-12))
        .padding(.bottom, metrics.scaled(8))
    }

    /// Allineato a `GameView`: il banner con testo ridimensionato tende a sembrare più in alto.
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

#Preview("Tutorial") {
    GeometryReader { geo in
        TutorialView(tutorialVM: TutorialViewModel(), onFinish: {})
            .environment(\.watchLayoutMetrics, WatchLayoutMetrics.from(proxy: geo))
            .environmentObject(AppSettings.preview)
    }
    .previewDevice("Apple Watch Series 10 (41mm)")
}
