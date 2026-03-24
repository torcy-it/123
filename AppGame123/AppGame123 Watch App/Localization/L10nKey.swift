//
//  L10nKey.swift
//  Chiavi stabili per tutte le stringhe UI (EN/IT in L10n.swift).
//

import Foundation

enum L10nKey: String, CaseIterable {
    // MARK: Menu
    case menu_play
    case menu_tutorial

    // MARK: Settings
    case settings_title
    case settings_back
    case settings_language_section
    case settings_difficulty_section
    case settings_lang_english
    case settings_lang_italian
    case settings_diff_easy
    case settings_diff_normal
    case settings_diff_hard

    // MARK: Game — chrome
    case game_cards_title
    case game_you
    case game_cpu
    case game_you_start
    case game_cpu_start
    case game_paused
    case game_resume
    case game_main_menu
    case game_over
    case game_you_win
    case game_house_wins

    case game_you_took_all_table
    case game_cpu_took_all_table

    // MARK: Game — formato
    case game_you_threw_fmt
    case game_cpu_threw_fmt
    case game_you_take_cards
    case game_cpu_takes_cards
    case game_you_caught_fmt
    case game_cpu_caught_fmt
    case game_penalty_banner

    // MARK: Regole (sotto-messaggio notifica)
    case game_rule_ten_short
    case game_rule_twin_short
    case game_rule_sandwich_short

    // MARK: Tutorial — overlay / demo
    case tutorial_tap_to_continue
    case tutorial_goal
    case tutorial_deck_shuffle
    case tutorial_speed_difficulty
    case tutorial_pause_yellow
    case tutorial_collecting_bottom
    case tutorial_special_123
    case tutorial_first_round_you_start
    case tutorial_you_took_cards_note
    case tutorial_turn_pass_123
    case tutorial_what_if_special
    case tutorial_your_turn_play_one
    case tutorial_another_way
    case tutorial_the_twin_explain
    case tutorial_first_round_cpu_start
    case tutorial_twin_popup
    case tutorial_you_caught_twin_banner
    case tutorial_your_turn
    case tutorial_tip_quicker
    case tutorial_tip_tap_break
    case tutorial_the_ten_explain
    case tutorial_second_round_cpu_start
    case tutorial_cpu_caught_ten_banner
    case tutorial_ten_formula
    case tutorial_sandwich_harder
    case tutorial_sandwich_bread
    case tutorial_sandwich_numbers
    case tutorial_you_caught_sandwich_banner
    case tutorial_sandwich_works_any
    case tutorial_penalty_wrong
    case tutorial_penalty_lose_top
    case tutorial_tip_track_cards

    // Tutorial — formati (numeri carta)
    case tutorial_you_threw_fmt
    case tutorial_cpu_threw_fmt
}
