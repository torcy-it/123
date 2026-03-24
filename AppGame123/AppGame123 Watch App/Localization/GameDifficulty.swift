//
//  GameDifficulty.swift
//  Velocità auto-play CPU / turni.
//

import Foundation

enum GameDifficulty: String, CaseIterable, Codable, Identifiable {
    case easy
    case normal
    case hard

    var id: String { rawValue }

    /// Secondi tra una carta e l’altra in partita automatica.
    var autoPlayIntervalSeconds: Double {
        switch self {
        case .easy: return 1.8
        case .normal: return 1.35
        case .hard: return 1
        }
    }

    /// Attesa dopo un pattern (dieci / coppia / panino) prima che la CPU possa battire la pila.
    /// Più alto = CPU **più lenta** a reagire (più tempo per te). Valore storico unico: **0,8 s**.
    var cpuSlapReactionSeconds: Double {
        switch self {
        case .easy: return 1.35
        case .normal: return 0.80
        case .hard: return 0.52
        }
    }
}
