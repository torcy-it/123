//
//  WatchLayoutMetrics.swift
//  AppGame123
//
//  Layout adattivo per tutti i modelli di Apple Watch (38mm–49mm).
//

import SwiftUI

/// Metriche scalate in base alle dimensioni dello schermo.
/// Riferimento: 40mm watch ≈ 197pt (lato minore).
struct WatchLayoutMetrics {
    /// Fattore di scala: 1.0 = 40mm, <1 = più piccolo, >1 = più grande
    let scale: CGFloat

    /// Scala un valore (font, padding, dimensioni)
    func scaled(_ value: CGFloat) -> CGFloat {
        value * scale
    }

    /// Scala **solo i font / testi**: su Watch con `scale &lt; 1` (schermo più stretto del
    /// reference ~40mm) riduce **più** di `scaled`, così il salto tra modelli si nota.
    /// Da `scale == 1` in su (Ultra / grandi) coincide con `scaled` → niente doppia penalità.
    func scaledText(_ base: CGFloat) -> CGFloat {
        let s = scale
        if s >= 1.0 {
            return base * s
        }
        // Tra scale 0.75 e 1.0: fattore extra da ~0.85 (max taglio sui più piccoli) a 1.0.
        let t = max(0, min(1, (s - 0.75) / (1.0 - 0.75)))
        let textBoost = 0.85 + 0.15 * t
        return base * s * textBoost
    }

    /// Scala con limiti per evitare valori estremi.
    /// Usa `from(proxy:)` per la taglia finestra reale.
    static func from(size: CGSize) -> WatchLayoutMetrics {
        let ref: CGFloat = 197  // 40mm watch
        let minDim = min(size.width, size.height)
        let raw = minDim / ref
        let clamped = max(0.75, min(1.25, raw))
        return WatchLayoutMetrics(scale: clamped)
    }

    /// Calcola le metriche dalla finestra usando **`proxy.size` intero** (non solo l’area dentro la safe area), così `min(width,height)` differisce tra modelli; altrimenti `scale` risultava troppo simile ovunque.
    static func from(proxy: GeometryProxy) -> WatchLayoutMetrics {
        let w = max(1, proxy.size.width)
        let h = max(1, proxy.size.height)
        return from(size: CGSize(width: w, height: h))
    }
}

private struct WatchLayoutMetricsKey: EnvironmentKey {
    static let defaultValue = WatchLayoutMetrics(scale: 1.0)
}

extension EnvironmentValues {
    var watchLayoutMetrics: WatchLayoutMetrics {
        get { self[WatchLayoutMetricsKey.self] }
        set { self[WatchLayoutMetricsKey.self] = newValue }
    }
}
