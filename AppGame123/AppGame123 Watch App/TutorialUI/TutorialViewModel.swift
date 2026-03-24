//
//  TutorialViewModel.swift
//  AppGame123
//
//  Created by Adolfo Torcicollo on 14/12/25.
//

import SwiftUI
import Combine

@MainActor
final class TutorialViewModel: ObservableObject {

    var appSettings: AppSettings?

    private var Llang: AppLanguage {
        appSettings?.language ?? .english
    }

    private func T(_ key: L10nKey) -> String {
        L10n.string(key, language: Llang)
    }

    private func TF(_ key: L10nKey, _ value: Int) -> String {
        L10n.format(key, language: Llang, value)
    }

    /// Richiama dopo cambio lingua dalle impostazioni.
    func bind(settings: AppSettings) {
        appSettings = settings
        applyStep(step)
    }

    enum Step: Equatable {
        // Info screens (text + button)
        case goal
        case deck1
        case deck2
        case pause
        case collecting
        case specialCards
        // Demo: first round YOU START
        case demoFirstRound
        case demoYouThrow2
        case demoCpuThrow7
        case explainCollecting
        case explainTurnPass
        case introSpecial
        case demoYouThrow2b
        case demoCpuThrow1
        case demoYourTurn
        // THE TWIN
        case theTwinIntro
        case theTwin
        case demoCpuStart
        case demoCpu4
        case demoYou3
        case demoCpu5
        case demoCpu5Twin
        case twinPopup
        case youCaughtTwin
        // TIPS + THE TEN
        case tipQuicker
        case tipBreakTurn
        case theTen
        case demoSecondRound
        case demoCpu3
        case demoYou7
        case cpuCaughtTen
        // THE SANDWICH
        case theTenFormula
        case theSandwichIntro
        case sandwichBread
        case sandwichNumbers
        case demoYou2
        case demoCpu7
        case sandwichCatch
        case youCaughtSandwich
        case sandwichExplain
        // PENALTIES + END
        case penalties
        case penaltyEffect
        case tipsFinal
    }

    @Published var step: Step = .goal
    @Published var waitingForTap = false
    @Published var demoYouCount = 20
    @Published var demoCpuCount = 20
    @Published var demoActionText = ""
    @Published var demoDisplayColor = "green"  // "green" | "yellow" | "pink"
    /// Chi inizia quando la pila è vuota (true = YOU, false = CPU). nil = non mostrare.
    @Published var demoWhoStartsWhenEmpty: Bool? = nil
    @Published var demoVisibleCards: [(value: Int, isPlayer: Bool)] = []
    @Published var showStarburst = false
    @Published var starburstMessage = ""
    @Published var showDarkOverlay = false
    @Published var darkOverlayText = ""

    private var advanceTask: Task<Void, Never>?

    private let stepOrder: [Step] = [
        .goal, .deck1, .deck2, .pause, .collecting, .specialCards,
        .demoFirstRound, .demoYouThrow2, .demoCpuThrow7, .explainCollecting,
        .explainTurnPass, .introSpecial, .demoYouThrow2b, .demoCpuThrow1, .demoYourTurn,
        .theTwinIntro, .theTwin, .demoCpuStart, .demoCpu4, .demoYou3, .demoCpu5,
        .demoCpu5Twin, .youCaughtTwin, .twinPopup,
        .tipQuicker, .tipBreakTurn, .theTen, .demoSecondRound, .demoCpu3, .demoYou7,
        .cpuCaughtTen, .theTenFormula, .theSandwichIntro, .sandwichBread, .sandwichNumbers,
        .demoYou2, .demoCpu7, .sandwichCatch, .youCaughtSandwich, .sandwichExplain,
        .penalties, .penaltyEffect, .tipsFinal
    ]

    func start() {
        step = .goal
        applyStep(.goal)
    }

    func gotIt() {
        advanceTask?.cancel()
        guard let idx = stepOrder.firstIndex(of: step), idx + 1 < stepOrder.count else {
            return
        }
        let next = stepOrder[idx + 1]
        step = next
        applyStep(next)
    }

    func tapScreen() {
        if waitingForTap {
            waitingForTap = false
            gotIt()
        }
    }

    private func applyStep(_ s: Step) {
        waitingForTap = false
        showStarburst = false
        showDarkOverlay = false
        demoVisibleCards = []
        demoActionText = ""
        demoWhoStartsWhenEmpty = nil

        switch s {
        case .goal:
            darkOverlayText = T(.tutorial_goal)
            showDarkOverlay = true
            waitingForTap = true

        case .deck1:
            darkOverlayText = T(.tutorial_deck_shuffle)
            showDarkOverlay = true
            waitingForTap = true

        case .deck2:
            darkOverlayText = T(.tutorial_speed_difficulty)
            showDarkOverlay = true
            waitingForTap = true

        case .pause:
            darkOverlayText = T(.tutorial_pause_yellow)
            showDarkOverlay = true
            waitingForTap = true

        case .collecting:
            darkOverlayText = T(.tutorial_collecting_bottom)
            showDarkOverlay = true
            waitingForTap = true

        case .specialCards:
            darkOverlayText = T(.tutorial_special_123)
            showDarkOverlay = true
            waitingForTap = true

        case .demoFirstRound:
            demoYouCount = 20
            demoCpuCount = 20
            demoActionText = T(.tutorial_first_round_you_start)
            demoDisplayColor = "green"
            demoWhoStartsWhenEmpty = true
            scheduleAdvance(1_200_000_000)

        case .demoYouThrow2:
            demoYouCount = 19
            demoCpuCount = 20
            demoActionText = TF(.tutorial_you_threw_fmt, 2)
            demoDisplayColor = "green"
            demoVisibleCards = [(2, true)]
            scheduleAdvance(1_200_000_000)

        case .demoCpuThrow7:
            demoYouCount = 19
            demoCpuCount = 18
            demoActionText = TF(.tutorial_cpu_threw_fmt, 7)
            demoDisplayColor = "yellow"
            demoVisibleCards = [(2, true), (7, false)]
            scheduleAdvance(1_200_000_000)

        case .explainCollecting:
            darkOverlayText = T(.tutorial_you_took_cards_note)
            showDarkOverlay = true
            waitingForTap = true

        case .explainTurnPass:
            darkOverlayText = T(.tutorial_turn_pass_123)
            showDarkOverlay = true
            waitingForTap = true

        case .introSpecial:
            darkOverlayText = T(.tutorial_what_if_special)
            showDarkOverlay = true
            demoYouCount = 22
            demoCpuCount = 17
            waitingForTap = true

        case .demoYouThrow2b:
            demoYouCount = 22
            demoCpuCount = 17
            demoActionText = TF(.tutorial_you_threw_fmt, 2)
            demoDisplayColor = "green"
            demoVisibleCards = [(2, true)]
            scheduleAdvance(1_200_000_000)

        case .demoCpuThrow1:
            demoYouCount = 22
            demoCpuCount = 16
            demoActionText = TF(.tutorial_cpu_threw_fmt, 1)
            demoDisplayColor = "yellow"
            demoVisibleCards = [(2, true), (1, false)]
            scheduleAdvance(1_200_000_000)

        case .demoYourTurn:
            demoActionText = T(.tutorial_your_turn_play_one)
            demoDisplayColor = "green"
            scheduleAdvance(1_200_000_000)

        case .theTwinIntro:
            darkOverlayText = T(.tutorial_another_way)
            showDarkOverlay = true
            waitingForTap = true

        case .theTwin:
            darkOverlayText = T(.tutorial_the_twin_explain)
            showDarkOverlay = true
            waitingForTap = true

        case .demoCpuStart:
            demoYouCount = 20
            demoCpuCount = 20
            demoActionText = T(.tutorial_first_round_cpu_start)
            demoDisplayColor = "yellow"
            demoVisibleCards = []
            demoWhoStartsWhenEmpty = false
            scheduleAdvance(1_200_000_000)

        case .demoCpu4:
            demoYouCount = 20
            demoCpuCount = 19
            demoActionText = TF(.tutorial_cpu_threw_fmt, 4)
            demoDisplayColor = "yellow"
            demoVisibleCards = [(4, false)]
            scheduleAdvance(1_200_000_000)

        case .demoYou3:
            demoYouCount = 19
            demoCpuCount = 19
            demoActionText = TF(.tutorial_you_threw_fmt, 3)
            demoDisplayColor = "green"
            demoVisibleCards = [(4, false), (3, true)]
            scheduleAdvance(1_200_000_000)

        case .demoCpu5:
            demoYouCount = 19
            demoCpuCount = 18
            demoActionText = TF(.tutorial_cpu_threw_fmt, 5)
            demoDisplayColor = "yellow"
            demoVisibleCards = [(4, false), (3, true), (5, false)]
            scheduleAdvance(1_200_000_000)

        case .demoCpu5Twin:
            demoYouCount = 19
            demoCpuCount = 17
            demoActionText = TF(.tutorial_cpu_threw_fmt, 5)
            demoDisplayColor = "yellow"
            demoVisibleCards = [(4, false), (3, true), (5, false), (5, false)]
            scheduleAdvance(1_200_000_000)

        case .twinPopup:
            darkOverlayText = T(.tutorial_twin_popup)
            showDarkOverlay = true
            waitingForTap = true

        case .youCaughtTwin:
            showStarburst = true
            starburstMessage = T(.tutorial_you_caught_twin_banner)
            demoYouCount = 23
            demoCpuCount = 17
            demoActionText = T(.tutorial_your_turn)
            demoDisplayColor = "green"
            demoVisibleCards = []
            demoWhoStartsWhenEmpty = true
            scheduleAdvance(1_200_000_000)

        case .tipQuicker:
            darkOverlayText = T(.tutorial_tip_quicker)
            showDarkOverlay = true
            waitingForTap = true

        case .tipBreakTurn:
            darkOverlayText = T(.tutorial_tip_tap_break)
            showDarkOverlay = true
            waitingForTap = true

        case .theTen:
            darkOverlayText = T(.tutorial_the_ten_explain)
            showDarkOverlay = true
            waitingForTap = true

        case .demoSecondRound:
            demoYouCount = 20
            demoCpuCount = 20
            demoActionText = T(.tutorial_second_round_cpu_start)
            demoDisplayColor = "yellow"
            demoVisibleCards = []
            demoWhoStartsWhenEmpty = false
            scheduleAdvance(1_200_000_000)

        case .demoCpu3:
            demoYouCount = 20
            demoCpuCount = 19
            demoActionText = TF(.tutorial_cpu_threw_fmt, 3)
            demoDisplayColor = "yellow"
            demoVisibleCards = [(3, false)]
            scheduleAdvance(1_200_000_000)

        case .demoYou7:
            demoYouCount = 19
            demoCpuCount = 19
            demoActionText = TF(.tutorial_you_threw_fmt, 7)
            demoDisplayColor = "green"
            demoVisibleCards = [(3, false), (7, true)]
            scheduleAdvance(800_000_000)

        case .cpuCaughtTen:
            showStarburst = true
            starburstMessage = T(.tutorial_cpu_caught_ten_banner)
            demoYouCount = 19
            demoCpuCount = 21
            demoActionText = ""
            demoVisibleCards = []
            demoWhoStartsWhenEmpty = false
            scheduleAdvance(1_200_000_000)

        case .theTenFormula:
            darkOverlayText = T(.tutorial_ten_formula)
            showDarkOverlay = true
            demoYouCount = 19
            demoCpuCount = 21
            waitingForTap = true

        case .theSandwichIntro:
            darkOverlayText = T(.tutorial_sandwich_harder)
            showDarkOverlay = true
            waitingForTap = true

        case .sandwichBread:
            darkOverlayText = T(.tutorial_sandwich_bread)
            showDarkOverlay = true
            waitingForTap = true

        case .sandwichNumbers:
            darkOverlayText = T(.tutorial_sandwich_numbers)
            showDarkOverlay = true
            waitingForTap = true

        case .demoYou2:
            demoYouCount = 19
            demoCpuCount = 21
            demoActionText = TF(.tutorial_you_threw_fmt, 2)
            demoDisplayColor = "green"
            demoVisibleCards = [(2, true)]
            scheduleAdvance(1_200_000_000)

        case .demoCpu7:
            demoYouCount = 19
            demoCpuCount = 20
            demoActionText = TF(.tutorial_cpu_threw_fmt, 7)
            demoDisplayColor = "yellow"
            demoVisibleCards = [(2, true), (7, false)]
            scheduleAdvance(1_200_000_000)

        case .sandwichCatch:
            demoYouCount = 19
            demoCpuCount = 20
            demoActionText = TF(.tutorial_cpu_threw_fmt, 2)
            demoDisplayColor = "yellow"
            demoVisibleCards = [(2, true), (7, false), (2, false)]
            scheduleAdvance(1_200_000_000)

        case .youCaughtSandwich:
            showStarburst = true
            starburstMessage = T(.tutorial_you_caught_sandwich_banner)
            demoYouCount = 22
            demoCpuCount = 18
            demoActionText = ""
            demoVisibleCards = []
            demoWhoStartsWhenEmpty = true
            scheduleAdvance(1_200_000_000)

        case .sandwichExplain:
            darkOverlayText = T(.tutorial_sandwich_works_any)
            showDarkOverlay = true
            waitingForTap = true

        case .penalties:
            darkOverlayText = T(.tutorial_penalty_wrong)
            showDarkOverlay = true
            waitingForTap = true

        case .penaltyEffect:
            darkOverlayText = T(.tutorial_penalty_lose_top)
            showDarkOverlay = true
            waitingForTap = true

        case .tipsFinal:
            darkOverlayText = T(.tutorial_tip_track_cards)
            showDarkOverlay = true
            waitingForTap = true
        }
    }

    private func scheduleAdvance(_ nanoseconds: UInt64) {
        advanceTask?.cancel()
        advanceTask = Task {
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.gotIt()
            }
        }
    }

    var isLastStep: Bool {
        step == .tipsFinal
    }

    var stepIndex: Int {
        stepOrder.firstIndex(of: step) ?? 0
    }

    var totalSteps: Int {
        stepOrder.count
    }
}
