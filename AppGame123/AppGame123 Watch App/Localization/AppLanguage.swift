//
//  AppLanguage.swift
//  Lingue supportate (runtime, non solo sistema).
//

import Foundation

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case english = "en"
    case italian = "it"

    var id: String { rawValue }

    var locale: Locale { Locale(identifier: rawValue) }
}
