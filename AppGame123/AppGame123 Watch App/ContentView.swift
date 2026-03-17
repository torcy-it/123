//
//  ContentView.swift
//  AppGame123 Watch App
//
//  Created by Adolfo Torcicollo on 12/12/25.
//

import SwiftUI

struct ContentView: View {
    let onNavigate: (AppRoute) -> Void
    @Environment(\.watchLayoutMetrics) private var metrics

    var body: some View {
        ZStack {
            BackgroundTexture()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            VStack{
                Spacer()
                    .frame(height: metrics.scaled(15))
                PixelButton(
                    text: "START GAME",
                    action: {
                        onNavigate(.game)
                    },
                    width: metrics.scaled(190),
                    primaryColor: Color(red: 218/255, green: 0/255, blue: 206/255),
                    secondaryColor: Color(red: 134/255, green: 0/255, blue: 126/255),
                    highlightedColor: Color(red: 250/255, green: 115/255, blue: 251/255),
                    textColor: Color.white

                )
                Spacer()
                    .frame(height: metrics.scaled(10))
                
                HStack{
                    PixelButton(
                        text: "TUTORIAL",
                        action: {
                            onNavigate(.tutorial)
                        },
                        width: metrics.scaled(130),
                        height: metrics.scaled(43),
                        primaryColor: Color(red: 0/255, green: 255/255, blue: 120/255),
                        secondaryColor: Color(red: 0/255, green: 140/255, blue: 70/255),
                        highlightedColor: Color(red: 180/255, green: 255/255, blue: 210/255),
                        textColor: Color.black

                    )
                    
                    PixelButton(
                        icon : "IconSettings",
                        action: {
                            onNavigate(.settings)
                        },
                        width: metrics.scaled(58),
                        height: metrics.scaled(43),
                        primaryColor: Color(red: 209/255,green: 211/255,blue: 38/255),
                        secondaryColor: Color(red: 179/255,green: 181/255,blue: 31/255),
                        highlightedColor: Color(red: 230/255,green: 232/255,blue: 90/255),
                        textColor: Color.black
                    )

                }

                Spacer().frame(height: metrics.scaled(25))
            
            }
        }
    }
}

#Preview {
    RootView()
}
