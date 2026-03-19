//
//  ContentView.swift
//  AppGame123 Watch App
//
//  Created by Adolfo Torcicollo on 12/12/25.
//
//  
import SwiftUI

struct ContentView: View {
    let onNavigate: (AppRoute) -> Void
    @Environment(\.watchLayoutMetrics) private var metrics

    private let menuCardColor = Color(red: 0/255, green: 255/255, blue: 120/255)

    private let mainMenuFanHalfWidth: CGFloat = 45
    /// Sposta tutto il menu **verso l’alto** (padding top negativo). Aumenta se vuoi più su.
    private let mainMenuPullUp: CGFloat = 45

    var body: some View {
        ZStack {
            BackgroundTexture()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            GeometryReader { geo in
                let h = geo.size.height
                let w = geo.size.width
            
                let fanButtonOverlap = max(metrics.scaled(52), h * 0.24)

                VStack(spacing: 0) {

                    VStack(spacing: -fanButtonOverlap) {
                        mainMenuCardFan()
                            .allowsHitTesting(false)
                            .frame(height: metrics.scaled(120))
                            .zIndex(0)

                        PixelButton(
                            text: "PLAY",
                            action: {
                                onNavigate(.game)
                            },
                            width: min(metrics.scaled(190), w - metrics.scaled(16)),
                            height: metrics.scaled(50),
                            primaryColor: Color(red: 218/255, green: 0/255, blue: 206/255),
                            secondaryColor: Color(red: 134/255, green: 0/255, blue: 126/255),
                            highlightedColor: Color(red: 250/255, green: 115/255, blue: 251/255),
                            textColor: Color.white
                        )
                        .zIndex(1)
                    }

                    Spacer(minLength: h * 0.1)

                    HStack(spacing: metrics.scaled(8)) {
                        PixelButton(
                            text: "TUTORIAL",
                            action: {
                                onNavigate(.tutorial)
                            },
                            width: min(metrics.scaled(136), (w - metrics.scaled(16)) * 0.74),
                            height: metrics.scaled(43),
                            primaryColor: Color(red: 0/255, green: 255/255, blue: 120/255),
                            secondaryColor: Color(red: 0/255, green: 140/255, blue: 70/255),
                            highlightedColor: Color(red: 180/255, green: 255/255, blue: 210/255),
                            textColor: Color.black,
                            textPointSize: 10
                        )

                        PixelButton(
                            icon: "IconSettings",
                            action: {
                                onNavigate(.settings)
                            },
                            width: metrics.scaled(58),
                            height: metrics.scaled(43),
                            primaryColor: Color(red: 209/255, green: 211/255, blue: 38/255),
                            secondaryColor: Color(red: 179/255, green: 181/255, blue: 31/255),
                            highlightedColor: Color(red: 230/255, green: 232/255, blue: 90/255),
                            textColor: Color.black
                        )
                    }
                    .padding(.horizontal, metrics.scaled(2))

                    Spacer(minLength: h * 0.06)
                }
                .padding(.top, -metrics.scaled(mainMenuPullUp))
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }

    /// Ventaglio: stessi angoli/offset di GameView; **impilamento 1 → 2 → 3** (la 3 è davanti).
    @ViewBuilder
    private func mainMenuCardFan() -> some View {
        let cardNumbers = ["1", "2", "3"]
        ZStack(alignment: .top) {
            ForEach(cardNumbers.indices, id: \.self) { i in
                GameCard(number: cardNumbers[i], cardColor: menuCardColor)
                    .rotationEffect(.degrees(rotationForSlot(i)))
                    .offset(
                        x: offsetXForSlot(i) * metrics.scale,
                        y: offsetYForSlot(i) * metrics.scale
                    )
                    .zIndex(Double(i))
            }
        }
    }

    // Angoli come GameView; puoi ridurli leggermente (es. ±20) se stringi molto `mainMenuFanHalfWidth`.
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
        case 0: return -mainMenuFanHalfWidth
        case 1: return 0
        case 2: return mainMenuFanHalfWidth
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

// COMPONENTE CARTA - Design dal GameView
struct GameCard: View {
    let number: String
    let cardColor: Color
    @Environment(\.watchLayoutMetrics) private var metrics
    
    private var cardWidth: CGFloat { 55 * metrics.scale }
    private var cardHeight: CGFloat { 75 * metrics.scale }
    private var inset: CGFloat { 5 * metrics.scale }
    
    var body: some View {
        ZStack {
            // Ombra
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.black)
                .frame(width: cardWidth, height: cardHeight)
                .offset(x: 2 * metrics.scale, y: 3 * metrics.scale)
            
            // Carta
            RoundedRectangle(cornerRadius: 5)
                .fill(cardColor)
                .frame(width: cardWidth, height: cardHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black, lineWidth: max(2, 2 * metrics.scale))
                )
            
            // Numero centrale con font pixel
            Text(number)
                .font(.custom("PressStart2P-Regular", size: metrics.scaledText(24)))
                .foregroundColor(.black)
        }
        // Angoli — overlay separati come nel GameView
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
        Text(number)
            .font(.custom("PressStart2P-Regular", size: metrics.scaledText(6)))
            .foregroundColor(.black)
    }
}

#Preview {
    RootView()
}
