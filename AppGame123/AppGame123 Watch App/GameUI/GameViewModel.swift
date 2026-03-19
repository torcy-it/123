//
//  GameViewModel.swift
//  AppGame123
//
//  Created by Adolfo Torcicollo on 12/12/25.
//
import SwiftUI
import Combine
import WatchKit


// MARK: - Card Model
struct Card: Identifiable, Equatable {
    let id = UUID()
    let value: Int
}

enum TurnState: Equatable {
    case normal(playerTurn: Bool)
    case forced(playerTurn: Bool, flipsRemaining: Int)
    case collecting(collectorIsPlayer: Bool)  // Nuovo stato per la raccolta
    indirect case paused(previous: TurnState)
    case gameOver
}

@MainActor
final class GameViewModel: ObservableObject {

    // Decks
    @Published var playerDeck: [Card] = []
    @Published var cpuDeck: [Card] = []
    @Published var tablePile: [Card] = []
    @Published var visiblePile: [(card: Card, isPlayer: Bool)] = []
    @Published var lastForcingCard: Card? = nil
    
    // UI state
    @Published var gameMessage = ""
    @Published var showMessage = false
    @Published var gameOver = false
    @Published var winner = ""
    @Published var lastPlayedByPlayer: Bool = true
    
    // Display state - separato dalla logica per forzare aggiornamenti UI
    @Published var displayMessage = ""  // Cosa mostrare sullo schermo (YOUR TURN, CPU TURN, etc)
    @Published var displayColor: String = "green"  // "green", "pink", "yellow"
    @Published var notificationMessage: String? = nil
    

    // Game state
    @Published var turnState: TurnState = .normal(playerTurn: true)
    
    var isPlayerTurn: Bool {
        switch turnState {
        case .normal(let p), .forced(let p, _):
            return p
        default:
            return false
        }
    }

    private var autoPlayTask: Task<Void, Never>?

    init() {
        setupGame()
    }

    
    // MARK: - Setup
    func setupGame() {
        autoPlayTask?.cancel()
        gameOver = false
        winner = ""
        showMessage = false
        gameMessage = ""

        var deck: [Card] = []
        for value in 1...10 {
            for _ in 1...4 { deck.append(Card(value: value)) }
        }
        deck.shuffle()

        playerDeck = Array(deck[0..<20])
        cpuDeck = Array(deck[20..<40])
        tablePile = []
        visiblePile = []

        turnState = .normal(playerTurn: true)
        startAutoPlay()
    }

    // MARK: - Auto Play Loop
    func startAutoPlay(intervalSeconds: Double = 1.8) {  // Rallentato da 1.3 a 1.8
        autoPlayTask?.cancel()

        autoPlayTask = Task { [weak self] in
            guard let self else { return }

            let ns = UInt64(intervalSeconds * 1_000_000_000)

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: ns)

                switch self.turnState {
                case .paused, .gameOver, .collecting:  // ← Blocca anche durante la raccolta
                    continue
                default:
                    self.playNextCard()
                }
            }
        }
    }

    func stopAutoPlay() {
        autoPlayTask?.cancel()
        autoPlayTask = nil
    }

    // MARK: - Core Game
    func playNextCard() {
        switch turnState {
        case .gameOver, .paused:
            return
        default:
            break
        }

        if checkElimination() { return }

        let playedByPlayer: Bool
        switch turnState {
        case .normal(let p), .forced(let p, _):
            playedByPlayer = p
        default:
            return
        }

        lastPlayedByPlayer = playedByPlayer

        guard let card = drawCard() else { return }

        displayMessage = lastPlayedByPlayer
            ? "YOU THREW \(card.value)"
            : "CPU THREW \(card.value)"
        displayColor = lastPlayedByPlayer ? "green" : "yellow"

        tablePile.append(card)
        visiblePile.append((card: card, isPlayer: lastPlayedByPlayer))

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 50_000_000)

            if case .collecting(let collectorIsPlayer) = self.turnState {
                if collectorIsPlayer {
                    return
                }
                if !self.tablePile.isEmpty, !self.visiblePile.isEmpty {
                    let drawnCard = self.tablePile.removeLast()
                    self.visiblePile.removeLast()
                    if self.lastPlayedByPlayer {
                        self.playerDeck.insert(drawnCard, at: 0)
                    } else {
                        self.cpuDeck.insert(drawnCard, at: 0)
                    }
                }
                return
            }

            // Pattern valido: finestra per CPU slap (300ms di reazione)
            if self.collectionRule() != nil {
                self.scheduleCpuSlapCheck(card: card)
                return
            }

            self.handleCard(card)
        }
    }

    /// CPU può slapare se rileva un pattern dopo 300ms (tempo di reazione)
    private func scheduleCpuSlapCheck(card: Card) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)

            if case .collecting = self.turnState { return }
            if self.gameOver { return }
            guard let msg = self.collectionRule() else {
                self.handleCard(card)
                return
            }

            self.handleCpuCollect(message: msg)
        }
    }


    private func drawCard() -> Card? {
        if playerDeck.isEmpty {
            endGame(winner: "CPU")
            return nil
        }
        if cpuDeck.isEmpty {
            endGame(winner: "Player")
            return nil
        }

        switch turnState {
        case .normal(let playerTurn), .forced(let playerTurn, _):
            return playerTurn ? playerDeck.removeFirst() : cpuDeck.removeFirst()
        default:
            return nil
        }
    }

    private func handleCard(_ card: Card) {
        switch turnState {

        case .normal(let playerTurn):

            if card.value <= 3 {
                lastForcingCard = card
                turnState = .forced(
                    playerTurn: !playerTurn,
                    flipsRemaining: card.value
                )
            } else {
                turnState = .normal(playerTurn: !playerTurn)
            }


        case .forced(let playerTurn, let flipsRemaining):

            let collector = !playerTurn

            if card.value <= 3 {
                lastForcingCard = card
                turnState = .forced(
                    playerTurn: !playerTurn,
                    flipsRemaining: card.value
                )
            } else {

                let newRemaining = flipsRemaining - 1

                if newRemaining <= 0 {

                    turnState = .collecting(collectorIsPlayer: collector)
                    lastForcingCard = nil

                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 600_000_000)  // attesa prima del banner
                        self.notificationMessage = collector
                            ? "YOU TAKE THE CARDS"
                            : "CPU TAKES THE CARDS"

                        try? await Task.sleep(nanoseconds: 1_200_000_000)  // banner visibile

                        self.collectCenter(byPlayer: collector)
                        self.notificationMessage = nil

                        try? await Task.sleep(nanoseconds: 600_000_000)  // attesa dopo aver preso le carte
                        self.turnState = .normal(playerTurn: collector)
                    }

                } else {

                    turnState = .forced(
                        playerTurn: playerTurn,
                        flipsRemaining: newRemaining
                    )
                }
            }


        default:
            break
        }
    }
    
 

    private func collectCenter(byPlayer isPlayer: Bool) {
        if isPlayer {
            playerDeck.append(contentsOf: tablePile)
        } else {
            cpuDeck.append(contentsOf: tablePile)
        }
        tablePile.removeAll()
        visiblePile.removeAll()
        displayMessage = ""
    }

    private func checkElimination() -> Bool {
        if playerDeck.isEmpty { endGame(winner: "CPU"); return true }
        if cpuDeck.isEmpty { endGame(winner: "Player"); return true }
        return false
    }

    // MARK: - Tap / Slap Rules
    private func tapRuleDisplay(_ rule: String) -> String {
        switch rule {
        case "THE TEN!": return "A TEN"
        case "THE TWIN!": return "A TWIN"
        case "THE SANDWICH!": return "A SANDWICH"
        default: return rule
        }
    }

    private func collectionRule() -> String? {
        guard tablePile.count >= 2 else { return nil }

        let last = tablePile[tablePile.count - 1].value
        let prev = tablePile[tablePile.count - 2].value

        if last + prev == 10 { return "THE TEN!" }
        if last == prev { return "THE TWIN!" }

        if tablePile.count >= 3 {
            let third = tablePile[tablePile.count - 3].value
            if third == last { return "THE SANDWICH!" }
        }

        return nil
    }

    func playerTap() {
        // Permetti tap durante .normal e .forced, blocca solo durante stati critici
        switch turnState {
        case .gameOver, .paused, .collecting:
            return  // Non permettere tap durante questi stati
        default:
            break  // Continua per .normal e .forced
        }
        
        // Controlla se c'è una regola valida
        if let msg = collectionRule() {
            handlePlayerCollect(message: msg)
        } else {
            // PENALTY: tap senza regola valida
            handlePenalty()
        }
    }

    private func handlePlayerCollect(message: String) {
        WKInterfaceDevice.current().play(.success)
        autoPlayTask?.cancel()
        notificationMessage = "YOU CAUGHT\n\(tapRuleDisplay(message))"
        turnState = .collecting(collectorIsPlayer: true)
        collectCenter(byPlayer: true)

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            self?.notificationMessage = nil
            self?.turnState = .normal(playerTurn: true)
            self?.startAutoPlay()
        }
    }

    private func handleCpuCollect(message: String) {
        autoPlayTask?.cancel()
        notificationMessage = "CPU CAUGHT\n\(tapRuleDisplay(message))"
        turnState = .collecting(collectorIsPlayer: false)
        collectCenter(byPlayer: false)

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            self?.notificationMessage = nil
            self?.turnState = .normal(playerTurn: false)
            self?.startAutoPlay()
        }
    }

    private func handlePenalty() {
        // Controlla se il giocatore ha carte da dare
        guard !playerDeck.isEmpty else { return }
        
        // Ferma l'auto-play
        autoPlayTask?.cancel()
        
        // Mostra messaggio penalty
        notificationMessage = "PENALTY\nPENALTY!"
        
        // Passa in stato collecting per bloccare il gioco
        let previousState = turnState
        turnState = .collecting(collectorIsPlayer: false)
        
        Task { [weak self] in
            guard let self else { return }
            
            // Aspetta un momento per mostrare il messaggio
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            // Trasferisci una carta dal giocatore alla CPU
            if !self.playerDeck.isEmpty {
                let penaltyCard = self.playerDeck.removeFirst()
                self.cpuDeck.append(penaltyCard)
            }
            
            // Nascondi il messaggio
            self.notificationMessage = nil
            
            // Ripristina lo stato precedente
            self.turnState = previousState
            
            // Riavvia l'auto-play
            self.startAutoPlay()
        }
    }

    // MARK: - Pause / Resume
    func pause() {
        guard case .paused = turnState else {
            turnState = .paused(previous: turnState)
            return
        }
    }

    func resume() {
        if case .paused(let previous) = turnState {
            turnState = previous
        }
    }

    // MARK: - End Game
    private func endGame(winner: String) {
        self.winner = winner
        self.gameOver = true
        self.turnState = .gameOver
        stopAutoPlay()
    }

    deinit {
        autoPlayTask?.cancel()
    }
}
