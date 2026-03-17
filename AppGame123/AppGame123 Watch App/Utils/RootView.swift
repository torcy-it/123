//
//  RootView.swift
//  AppGame123
//
//  Created by Adolfo Torcicollo on 12/12/25.
//

import SwiftUI

enum AppRoute: Hashable {
    case game
    case tutorial
    case settings
}

enum Screen {
    case menu
    case game
    case tutorial
    case settings
}

struct RootView: View {

    @State private var screen: Screen = .menu

    var body: some View {
        ZStack {
            switch screen {
            case .menu:
                ContentView(onNavigate: navigate)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .game:
                GameView(
                    onBack: { navigateBack() }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))

            case .tutorial:
                TutorialView(
                    tutorialVM: TutorialViewModel(),
                    onFinish: { navigateBack() }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))

            case .settings:
                SettingsView(
                    onBack: { navigateBack() }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: screen)
    }

    private func navigateBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            screen = .menu
        }
    }

    private func navigate(_ route: AppRoute) {
        withAnimation(.easeInOut(duration: 0.3)) {
            screen = map(route)
        }
    }

    private func map(_ route: AppRoute) -> Screen {
        switch route {
        case .game: return .game
        case .tutorial: return .tutorial
        case .settings: return .settings
        }
    }
}



extension Animation {
    static let retro = Animation.linear(duration: 0.25)
}

extension AnyTransition {

    static func retroSlide(from edge: Edge) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: edge)
                .combined(with: AnyTransition.opacity),
            removal: .move(edge: edge.opposite)
                .combined(with: AnyTransition.opacity)
        )
    }

    static let retroFade =
        AnyTransition.opacity
            .combined(with: .scale(scale: 1.02))

    static let retroZoom =
        AnyTransition.scale(scale: 0.85)
            .combined(with: AnyTransition.opacity)
}

extension Edge {
    var opposite: Edge {
        switch self {
        case .leading: return .trailing
        case .trailing: return .leading
        case .top: return .bottom
        case .bottom: return .top
        }
    }
}
