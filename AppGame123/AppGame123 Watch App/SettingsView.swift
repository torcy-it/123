//
//  SettingsView.swift
//  AppGame123
//

import SwiftUI

struct SettingsView: View {
    let onBack: () -> Void
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.watchLayoutMetrics) private var metrics

    var body: some View {
        ZStack {
            BackgroundTexture()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .center, spacing: metrics.scaled(12)) {
                    sectionLabel(appSettings.text(.settings_language_section))
                        .padding(.bottom, metrics.scaled(4))

                    GeometryReader { g in
                        let gap = metrics.scaled(10)
                        let half = max(metrics.scaled(72), (g.size.width - gap) / 2)
                        HStack(spacing: gap) {
                            ForEach(AppLanguage.allCases) { lang in
                                PixelButton(
                                    text: langDisplayName(lang),
                                    action: { appSettings.language = lang },
                                    width: half,
                                    height: metrics.scaled(32),
                                    primaryColor: appSettings.language == lang
                                        ? Color(red: 0/255, green: 200/255, blue: 120/255)
                                        : Color(red: 0/255, green: 120/255, blue: 70/255),
                                    secondaryColor: Color(red: 0/255, green: 80/255, blue: 50/255),
                                    highlightedColor: Color(red: 100/255, green: 255/255, blue: 180/255),
                                    textColor: .black,
                                    textPointSize: 9
                                )
                            }
                        }
                    }
                    .frame(height: metrics.scaled(50))

                    sectionLabel(appSettings.text(.settings_difficulty_section))
                        .padding(.top, metrics.scaled(6))
                        .padding(.bottom, metrics.scaled(4))

                    // Tre livelli in una riga (scroll se serve sui Watch piccoli)
                    GeometryReader { g in
                        let gap = metrics.scaled(8)
                        let cell = max(metrics.scaled(48), (g.size.width - gap * 2) / 3)
                        HStack(spacing: gap) {
                            ForEach(GameDifficulty.allCases) { diff in
                                PixelButton(
                                    text: difficultyLabel(diff),
                                    action: { appSettings.difficulty = diff },
                                    width: cell,
                                    height: metrics.scaled(32),
                                    primaryColor: appSettings.difficulty == diff
                                        ? Color(red: 209/255, green: 211/255, blue: 38/255)
                                        : Color(red: 160/255, green: 150/255, blue: 30/255),
                                    secondaryColor: Color(red: 120/255, green: 110/255, blue: 20/255),
                                    highlightedColor: Color(red: 230/255, green: 232/255, blue: 90/255),
                                    textColor: .black,
                                    textPointSize: 8
                                )
                            }
                        }
                    }
                    .frame(height: metrics.scaled(34))

       
                    Color.clear.frame(height: metrics.scaled(2))
                    PixelButton(
                        text: appSettings.text(.settings_back),
                        action: { onBack() },
                        width: metrics.scaled(130),
                        height: metrics.scaled(34),
                        primaryColor: .gray,
                        secondaryColor: .black,
                        highlightedColor: .white,
                        textColor: .white,
                        textPointSize: 10
                    )
                    .padding(.top, metrics.scaled(14))
                }
                .padding(.horizontal, metrics.scaled(6))
            }
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.custom("PressStart2P-Regular", size: metrics.scaledText(8)))
            .foregroundColor(.white.opacity(0.65))
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }

    private func langDisplayName(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return L10n.string(.settings_lang_english, language: appSettings.language)
        case .italian: return L10n.string(.settings_lang_italian, language: appSettings.language)
        }
    }

    private func difficultyLabel(_ diff: GameDifficulty) -> String {
        switch diff {
        case .easy: return appSettings.text(.settings_diff_easy)
        case .normal: return appSettings.text(.settings_diff_normal)
        case .hard: return appSettings.text(.settings_diff_hard)
        }
    }
}



#Preview("Settings") {
    SettingsView(onBack: {})
        .environmentObject(AppSettings.preview)
}
