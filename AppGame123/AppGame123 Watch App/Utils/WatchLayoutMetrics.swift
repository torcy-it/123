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

    /// Scala con limiti per evitare valori estremi.
    /// Usa `from(proxy:)` per considerare la safe area.
    static func from(size: CGSize) -> WatchLayoutMetrics {
        let ref: CGFloat = 197  // 40mm watch
        let minDim = min(size.width, size.height)
        let raw = minDim / ref
        let clamped = max(0.75, min(1.25, raw))
        return WatchLayoutMetrics(scale: clamped)
    }

    /// Calcola le metriche dall'area effettivamente utilizzabile (esclude safe area).
    static func from(proxy: GeometryProxy) -> WatchLayoutMetrics {
        let insets = proxy.safeAreaInsets
        let usableWidth = proxy.size.width - insets.leading - insets.trailing
        let usableHeight = proxy.size.height - insets.top - insets.bottom
        let usableSize = CGSize(
            width: max(1, usableWidth),
            height: max(1, usableHeight)
        )
        return from(size: usableSize)
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
