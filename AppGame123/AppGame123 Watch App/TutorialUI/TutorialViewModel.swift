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
            darkOverlayText = "GOAL\nTake all opponent cards\nto WIN.\nNo cards = LOSE."
            showDarkOverlay = true
            waitingForTap = true

        case .deck1:
            darkOverlayText = "DECK\n20 cards each,\nauto-shuffled."
            showDarkOverlay = true
            waitingForTap = true

        case .deck2:
            darkOverlayText = "Cards play automatically.\nSpeed = difficulty."
            showDarkOverlay = true
            waitingForTap = true

        case .pause:
            darkOverlayText = "PAUSE\nTap the yellow button\nto pause."
            showDarkOverlay = true
            waitingForTap = true

        case .collecting:
            darkOverlayText = "COLLECTING\nCards go to the bottom\nof your deck."
            showDarkOverlay = true
            waitingForTap = true

        case .specialCards:
            darkOverlayText = "SPECIAL 1-2-3\nForce opponent to\nflip 1, 2 or 3 cards."
            showDarkOverlay = true
            waitingForTap = true

        case .demoFirstRound:
            demoYouCount = 20
            demoCpuCount = 20
            demoActionText = "FIRST ROUND: YOU START"
            demoDisplayColor = "green"
            demoWhoStartsWhenEmpty = true
            scheduleAdvance(1_200_000_000)

        case .demoYouThrow2:
            demoYouCount = 19
            demoCpuCount = 20
            demoActionText = "YOU THREW 2"
            demoDisplayColor = "green"
            demoVisibleCards = [(2, true)]
            scheduleAdvance(1_200_000_000)

        case .demoCpuThrow7:
            demoYouCount = 19
            demoCpuCount = 18
            demoActionText = "CPU THREW 7"
            demoDisplayColor = "yellow"
            demoVisibleCards = [(2, true), (7, false)]
            scheduleAdvance(1_200_000_000)

        case .explainCollecting:
            darkOverlayText = "You took the cards!\n(No 1-2-3 was played)"
            showDarkOverlay = true
            waitingForTap = true

        case .explainTurnPass:
            darkOverlayText = "If opponent plays 1, 2 or 3\nthe turn passes to you."
            showDarkOverlay = true
            waitingForTap = true

        case .introSpecial:
            darkOverlayText = "What if opponent\nthrows a special card?"
            showDarkOverlay = true
            demoYouCount = 22
            demoCpuCount = 17
            waitingForTap = true

        case .demoYouThrow2b:
            demoYouCount = 22
            demoCpuCount = 17
            demoActionText = "YOU THREW 2"
            demoDisplayColor = "green"
            demoVisibleCards = [(2, true)]
            scheduleAdvance(1_200_000_000)

        case .demoCpuThrow1:
            demoYouCount = 22
            demoCpuCount = 16
            demoActionText = "CPU THREW 1"
            demoDisplayColor = "yellow"
            demoVisibleCards = [(2, true), (1, false)]
            scheduleAdvance(1_200_000_000)

        case .demoYourTurn:
            demoActionText = "YOUR TURN\nPlay 1 card"
            demoDisplayColor = "green"
            scheduleAdvance(1_200_000_000)

        case .theTwinIntro:
            darkOverlayText = "Another way to collect:"
            showDarkOverlay = true
            waitingForTap = true

        case .theTwin:
            darkOverlayText = "THE TWIN\nSame number twice?\nTAP to take all!"
            showDarkOverlay = true
            waitingForTap = true

        case .demoCpuStart:
            demoYouCount = 20
            demoCpuCount = 20
            demoActionText = "FIRST ROUND: CPU START"
            demoDisplayColor = "yellow"
            demoVisibleCards = []
            demoWhoStartsWhenEmpty = false
            scheduleAdvance(1_200_000_000)

        case .demoCpu4:
            demoYouCount = 20
            demoCpuCount = 19
            demoActionText = "CPU THREW 4"
            demoDisplayColor = "yellow"
            demoVisibleCards = [(4, false)]
            scheduleAdvance(1_200_000_000)

        case .demoYou3:
            demoYouCount = 19
            demoCpuCount = 19
            demoActionText = "YOU THREW 3"
            demoDisplayColor = "green"
            demoVisibleCards = [(4, false), (3, true)]
            scheduleAdvance(1_200_000_000)

        case .demoCpu5:
            demoYouCount = 19
            demoCpuCount = 18
            demoActionText = "CPU THREW 5"
            demoDisplayColor = "yellow"
            demoVisibleCards = [(4, false), (3, true), (5, false)]
            scheduleAdvance(1_200_000_000)

        case .demoCpu5Twin:
            demoYouCount = 19
            demoCpuCount = 17
            demoActionText = "CPU THREW 5"
            demoDisplayColor = "yellow"
            demoVisibleCards = [(4, false), (3, true), (5, false), (5, false)]
            scheduleAdvance(1_200_000_000)

        case .twinPopup:
            darkOverlayText = "TWIN!\nSame card twice.\nTAP to collect!"
            showDarkOverlay = true
            waitingForTap = true

        case .youCaughtTwin:
            showStarburst = true
            starburstMessage = "YOU CAUGHT\nA TWIN"
            demoYouCount = 23
            demoCpuCount = 17
            demoActionText = "YOUR TURN"
            demoDisplayColor = "green"
            demoVisibleCards = []
            demoWhoStartsWhenEmpty = true
            scheduleAdvance(1_200_000_000)

        case .tipQuicker:
            darkOverlayText = "TIP\nBe quicker than CPU!"
            showDarkOverlay = true
            waitingForTap = true

        case .tipBreakTurn:
            darkOverlayText = "TIP\nTap breaks forced turn."
            showDarkOverlay = true
            waitingForTap = true

        case .theTen:
            darkOverlayText = "THE TEN\nCards add to 10?\nTAP to collect!"
            showDarkOverlay = true
            waitingForTap = true

        case .demoSecondRound:
            demoYouCount = 20
            demoCpuCount = 20
            demoActionText = "SECOND ROUND: CPU START"
            demoDisplayColor = "yellow"
            demoVisibleCards = []
            demoWhoStartsWhenEmpty = false
            scheduleAdvance(1_200_000_000)

        case .demoCpu3:
            demoYouCount = 20
            demoCpuCount = 19
            demoActionText = "CPU THREW 3"
            demoDisplayColor = "yellow"
            demoVisibleCards = [(3, false)]
            scheduleAdvance(1_200_000_000)

        case .demoYou7:
            demoYouCount = 19
            demoCpuCount = 19
            demoActionText = "YOU THREW 7"
            demoDisplayColor = "green"
            demoVisibleCards = [(3, false), (7, true)]
            scheduleAdvance(800_000_000)

        case .cpuCaughtTen:
            showStarburst = true
            starburstMessage = "CPU CAUGHT\nA TEN"
            demoYouCount = 19
            demoCpuCount = 21
            demoActionText = ""
            demoVisibleCards = []
            demoWhoStartsWhenEmpty = false
            scheduleAdvance(1_200_000_000)

        case .theTenFormula:
            darkOverlayText = "THE TEN\n7 + 3 = 10!"
            showDarkOverlay = true
            demoYouCount = 19
            demoCpuCount = 21
            waitingForTap = true

        case .theSandwichIntro:
            darkOverlayText = "THE SANDWICH\nA bit harder..."
            showDarkOverlay = true
            waitingForTap = true

        case .sandwichBread:
            darkOverlayText = "Like a sandwich:\nbread - cheese - bread"
            showDarkOverlay = true
            waitingForTap = true

        case .sandwichNumbers:
            darkOverlayText = "With numbers:\n2  -  7  -  2"
            showDarkOverlay = true
            waitingForTap = true

        case .demoYou2:
            demoYouCount = 19
            demoCpuCount = 21
            demoActionText = "YOU THREW 2"
            demoDisplayColor = "green"
            demoVisibleCards = [(2, true)]
            scheduleAdvance(1_200_000_000)

        case .demoCpu7:
            demoYouCount = 19
            demoCpuCount = 20
            demoActionText = "CPU THREW 7"
            demoDisplayColor = "yellow"
            demoVisibleCards = [(2, true), (7, false)]
            scheduleAdvance(1_200_000_000)

        case .sandwichCatch:
            demoYouCount = 19
            demoCpuCount = 20
            demoActionText = "CPU THREW 2"
            demoDisplayColor = "yellow"
            demoVisibleCards = [(2, true), (7, false), (2, false)]
            scheduleAdvance(1_200_000_000)

        case .youCaughtSandwich:
            showStarburst = true
            starburstMessage = "YOU CAUGHT\nA SANDWICH"
            demoYouCount = 22
            demoCpuCount = 18
            demoActionText = ""
            demoVisibleCards = []
            demoWhoStartsWhenEmpty = true
            scheduleAdvance(1_200_000_000)

        case .sandwichExplain:
            darkOverlayText = "SANDWICH\nWorks with any numbers!"
            showDarkOverlay = true
            waitingForTap = true

        case .penalties:
            darkOverlayText = "PENALTY\nWrong tap?\nYou pay!"
            showDarkOverlay = true
            waitingForTap = true

        case .penaltyEffect:
            darkOverlayText = "PENALTY\nLose your top card."
            showDarkOverlay = true
            waitingForTap = true

        case .tipsFinal:
            darkOverlayText = "TIP\nTrack cards.\nAvoid wrong taps!"
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
