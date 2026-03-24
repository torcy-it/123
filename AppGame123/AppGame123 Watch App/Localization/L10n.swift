//
//  L10n.swift
//  Lookup modulare: aggiungi chiavi in L10nKey + tabelle qui (EN / IT).
//

import Foundation

enum L10n {
    static func string(_ key: L10nKey, language: AppLanguage) -> String {
        switch language {
        case .english:
            return english[key] ?? missing(key)
        case .italian:
            return italian[key] ?? english[key] ?? missing(key)
        }
    }

    /// Solo argomenti `%d` / `%@` (in pratica un solo placeholder per stringa nel progetto).
    static func format(_ key: L10nKey, language: AppLanguage, _ args: CVarArg...) -> String {
        let formatString = string(key, language: language)
        let locale = language.locale
        switch args.count {
        case 0: return formatString
        case 1: return String(format: formatString, locale: locale, args[0])
        case 2: return String(format: formatString, locale: locale, args[0], args[1])
        default:
            return formatString
        }
    }

    private static func missing(_ key: L10nKey) -> String {
        "⚠\(key.rawValue)"
    }

    // MARK: English
    private static let english: [L10nKey: String] = [
        .menu_play: "PLAY",
        .menu_tutorial: "TUTORIAL",

        .settings_title: "SETTINGS",
        .settings_back: "BACK",
        .settings_language_section: "LANGUAGE",
        .settings_difficulty_section: "DIFFICULTY",
        .settings_lang_english: "English",
        .settings_lang_italian: "Italiano",
        .settings_diff_easy: "Easy",
        .settings_diff_normal: "Normal",
        .settings_diff_hard: "Hard",

        .game_cards_title: "CARDS",
        .game_you: "YOU",
        .game_cpu: "CPU",
        .game_you_start: "YOU START",
        .game_cpu_start: "CPU START",
        .game_paused: "PAUSED",
        .game_resume: "RESUME",
        .game_main_menu: "MAIN MENU",
        .game_over: "GAME OVER",
        .game_you_win: "YOU WIN!",
        .game_house_wins: "THE HOUSE WINS!",

        .game_you_took_all_table: "YOU TOOK ALL\nCARDS ON THE\nTABLE !!",
        .game_cpu_took_all_table: "CPU TOOK ALL\nCARDS ON THE\nTABLE !!",

        .game_you_threw_fmt: "YOU THREW %d",
        .game_cpu_threw_fmt: "CPU THREW %d",
        .game_you_take_cards: "YOU TAKE THE CARDS",
        .game_cpu_takes_cards: "CPU TAKES THE CARDS",
        .game_you_caught_fmt: "YOU CAUGHT\n%@",
        .game_cpu_caught_fmt: "CPU CAUGHT\n%@",
        .game_penalty_banner: "PENALTY\nPENALTY!",

        .game_rule_ten_short: "A TEN",
        .game_rule_twin_short: "A TWIN",
        .game_rule_sandwich_short: "A SANDWICH",

        .tutorial_tap_to_continue: "TAP TO CONTINUE",
        .tutorial_goal: "GOAL\nTake all opponent cards\nto WIN.\nNo cards = LOSE.",
        .tutorial_deck_shuffle: "DECK\n20 cards each,\nauto-shuffled.",
        .tutorial_speed_difficulty: "Cards play automatically.\nSpeed = difficulty.",
        .tutorial_pause_yellow: "PAUSE\nTap the yellow button\nto pause.",
        .tutorial_collecting_bottom: "COLLECTING\nCards go to the bottom\nof your deck.",
        .tutorial_special_123: "SPECIAL 1-2-3\nForce opponent to\nflip 1, 2 or 3 cards.",
        .tutorial_first_round_you_start: "FIRST ROUND: YOU START",
        .tutorial_you_took_cards_note: "You took the cards!\n(No 1-2-3 was played)",
        .tutorial_turn_pass_123: "If opponent plays 1, 2 or 3\nthe turn passes to you.",
        .tutorial_what_if_special: "What if opponent\nthrows a special card?",
        .tutorial_your_turn_play_one: "YOUR TURN\nPlay 1 card",
        .tutorial_another_way: "Another way to collect:",
        .tutorial_the_twin_explain: "THE TWIN\nSame number twice?\nTAP to take all!",
        .tutorial_first_round_cpu_start: "FIRST ROUND: CPU START",
        .tutorial_twin_popup: "TWIN!\nSame card twice.\nTAP to collect!",
        .tutorial_you_caught_twin_banner: "YOU CAUGHT\nA TWIN",
        .tutorial_your_turn: "YOUR TURN",
        .tutorial_tip_quicker: "TIP\nBe quicker than CPU!",
        .tutorial_tip_tap_break: "TIP\nTap breaks forced turn.",
        .tutorial_the_ten_explain: "THE TEN\nCards add to 10?\nTAP to collect!",
        .tutorial_second_round_cpu_start: "SECOND ROUND: CPU START",
        .tutorial_cpu_caught_ten_banner: "CPU CAUGHT\nA TEN",
        .tutorial_ten_formula: "THE TEN\n7 + 3 = 10!",
        .tutorial_sandwich_harder: "THE SANDWICH\nA bit harder...",
        .tutorial_sandwich_bread: "Like a sandwich:\nbread - cheese - bread",
        .tutorial_sandwich_numbers: "With numbers:\n2  -  7  -  2",
        .tutorial_you_caught_sandwich_banner: "YOU CAUGHT\nA SANDWICH",
        .tutorial_sandwich_works_any: "SANDWICH\nWorks with any numbers!",
        .tutorial_penalty_wrong: "PENALTY\nWrong tap?\nYou pay!",
        .tutorial_penalty_lose_top: "PENALTY\nLose your top card.",
        .tutorial_tip_track_cards: "TIP\nTrack cards.\nAvoid wrong taps!",

        .tutorial_you_threw_fmt: "YOU THREW %d",
        .tutorial_cpu_threw_fmt: "CPU THREW %d",
    ]

    // MARK: Italian
    private static let italian: [L10nKey: String] = [
        .menu_play: "GIOCA",
        .menu_tutorial: "TUTORIAL",

        .settings_title: "IMPOSTAZIONI",
        .settings_back: "INDIETRO",
        .settings_language_section: "LINGUA",
        .settings_difficulty_section: "DIFFICOLTÀ",
        .settings_lang_english: "English",
        .settings_lang_italian: "Italiano",
        .settings_diff_easy: "Facile",
        .settings_diff_normal: "Normale",
        .settings_diff_hard: "Difficile",

        .game_cards_title: "CARTE",
        .game_you: "TU",
        .game_cpu: "CPU",
        .game_you_start: "INIZI TU",
        .game_cpu_start: "INIZIA LA CPU",
        .game_paused: "PAUSA",
        .game_resume: "RIPRENDI",
        .game_main_menu: "MENU PRINCIPALE",
        .game_over: "FINE PARTITA",
        .game_you_win: "HAI VINTO!",
        .game_house_wins: "VINCE LA CASA!",

        .game_you_took_all_table: "HAI PRESO TUTTE\nLE CARTE SUL\nTAVOLO !!",
        .game_cpu_took_all_table: "LA CPU HA PRESO\nTUTTE LE CARTE SUL\nTAVOLO !!",

        .game_you_threw_fmt: "HAI GIOCATO %d",
        .game_cpu_threw_fmt: "CPU GIOCA %d",
        .game_you_take_cards: "PRENDI LE CARTE",
        .game_cpu_takes_cards: "LA CPU PRENDE LE CARTE",
        .game_you_caught_fmt: "HAI CATTURATO\n%@",
        .game_cpu_caught_fmt: "LA CPU CATTURA\n%@",
        .game_penalty_banner: "PENALITÀ!\nPENALITÀ!",

        .game_rule_ten_short: "IL DIECI",
        .game_rule_twin_short: "LA COPPIA",
        .game_rule_sandwich_short: "IL PANINO",

        .tutorial_tap_to_continue: "TOCCA PER CONTINUARE",
        .tutorial_goal: "OBIETTIVO\nPrendi tutte le carte\navversarie per VINCERE.\nSenza carte = PERSO.",
        .tutorial_deck_shuffle: "MAZZO\n20 carte ciascuno,\nmischiate automaticamente.",
        .tutorial_speed_difficulty: "Le carte si giocano da sole.\nVelocità = difficoltà.",
        .tutorial_pause_yellow: "PAUSA\nTocca il bottone giallo\nper mettere in pausa.",
        .tutorial_collecting_bottom: "RACCOLTA\nLe carte vanno in fondo\nal tuo mazzo.",
        .tutorial_special_123: "SPECIALI 1-2-3\nObblighi l’avversario a\nvoltare 1, 2 o 3 carte.",
        .tutorial_first_round_you_start: "PRIMO TURNO: INIZI TU",
        .tutorial_you_took_cards_note: "Hai preso le carte!\n(Nessun 1-2-3 giocato)",
        .tutorial_turn_pass_123: "Se l’avversario gioca 1, 2 o 3\nil turno passa a te.",
        .tutorial_what_if_special: "E se l’avversario\ngioca una carta speciale?",
        .tutorial_your_turn_play_one: "IL TUO TURNO\nGioca 1 carta",
        .tutorial_another_way: "Un altro modo per raccogliere:",
        .tutorial_the_twin_explain: "LA COPPIA\nStesso numero due volte?\nTOCCA per prenderle tutte!",
        .tutorial_first_round_cpu_start: "PRIMO TURNO: INIZIA LA CPU",
        .tutorial_twin_popup: "COPPIA!\nStessa carta due volte.\nTOCCA per raccogliere!",
        .tutorial_you_caught_twin_banner: "HAI CATTURATO\nLA COPPIA",
        .tutorial_your_turn: "IL TUO TURNO",
        .tutorial_tip_quicker: "SUGGERIMENTO\nSii più veloce della CPU!",
        .tutorial_tip_tap_break: "SUGGERIMENTO\nIl tap interrompe il turno forzato.",
        .tutorial_the_ten_explain: "IL DIECI\nLe carte sommano a 10?\nTOCCA per raccogliere!",
        .tutorial_second_round_cpu_start: "SECONDO TURNO: INIZIA LA CPU",
        .tutorial_cpu_caught_ten_banner: "LA CPU CATTURA\nIL DIECI",
        .tutorial_ten_formula: "IL DIECI\n7 + 3 = 10!",
        .tutorial_sandwich_harder: "IL PANINO\nUn po’ più difficile...",
        .tutorial_sandwich_bread: "Come un panino:\npane - formaggio - pane",
        .tutorial_sandwich_numbers: "Con i numeri:\n2  -  7  -  2",
        .tutorial_you_caught_sandwich_banner: "HAI CATTURATO\nIL PANINO",
        .tutorial_sandwich_works_any: "PANINO\nFunziona con qualsiasi numero!",
        .tutorial_penalty_wrong: "PENALITÀ\nTap sbagliato?\nLa paghi!",
        .tutorial_penalty_lose_top: "PENALITÀ\nPerdi la carta in cima.",
        .tutorial_tip_track_cards: "SUGGERIMENTO\nSegui le carte.\nEvita tap sbagliati!",

        .tutorial_you_threw_fmt: "HAI GIOCATO %d",
        .tutorial_cpu_threw_fmt: "CPU GIOCA %d",
    ]
}
