//
//  AppSettings.swift
//  Stato globale: lingua, difficoltà. Persistenza UserDefaults.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    private enum Keys {
        static let language = "app_settings_language"
        static let difficulty = "app_settings_difficulty"
    }

    private let defaults: UserDefaults

    @Published var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Keys.language) }
    }

    @Published var difficulty: GameDifficulty {
        didSet { defaults.set(difficulty.rawValue, forKey: Keys.difficulty) }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        if let raw = defaults.string(forKey: Keys.language),
           let lang = AppLanguage(rawValue: raw) {
            self.language = lang
        } else {
            let prefersItalian = Locale.preferredLanguages.first?
                .lowercased().hasPrefix("it") == true
            self.language = prefersItalian ? .italian : .english
        }
        if let raw = defaults.string(forKey: Keys.difficulty),
           let diff = GameDifficulty(rawValue: raw) {
            self.difficulty = diff
        } else {
            self.difficulty = .normal
        }
    }

    func text(_ key: L10nKey) -> String {
        L10n.string(key, language: language)
    }

    func format(_ key: L10nKey, _ args: CVarArg...) -> String {
        switch args.count {
        case 0: return L10n.string(key, language: language)
        case 1: return L10n.format(key, language: language, args[0])
        case 2: return L10n.format(key, language: language, args[0], args[1])
        default: return L10n.string(key, language: language)
        }
    }

#if DEBUG
    static var preview: AppSettings { AppSettings() }
#endif
}
