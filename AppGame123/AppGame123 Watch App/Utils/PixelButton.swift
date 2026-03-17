//
//  PixelButton.swift
//  AppGame123
//
//  Created by Adolfo Torcicollo on 12/12/25.
//
import SwiftUI

struct PixelButton: View {
    var icon: String? = nil
    var text: String? = nil
    var action: () -> Void
    var width: CGFloat
    var height: CGFloat? = nil
    var primaryColor: Color
    var secondaryColor: Color
    var highlightedColor: Color
    var textColor: Color
    @Environment(\.watchLayoutMetrics) private var metrics

    var body: some View {
        let viewHeight: CGFloat = height ?? metrics.scaled(45)
        
        Button(action: action) {
            ZStack {
                // Corpo del bottone (con bordo)
                RoundedRectangle(cornerRadius: 6)
                //.fill(Color(red: 134/255, green: 0/255, blue: 126/255))
                    .fill(secondaryColor)
                    .frame(height: viewHeight)
                    .offset(y: metrics.scaled(8))
                    .overlay(
                        // Bordo nero pixel
                        RoundedRectangle(cornerRadius: 6)
                            .offset(y: metrics.scaled(8))
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                
                // Corpo del bottone
                RoundedRectangle(cornerRadius: 6)
                //.fill(Color(red: 218/255, green: 0/255, blue: 206/255)) // DA00CE
                    .fill(primaryColor)
                    .frame(height: viewHeight)
                    .overlay(
                        // Bordo nero pixel
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .overlay(
                        // Highlight superiore
                        VStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(highlightedColor)
                                .frame(height: metrics.scaled(3))
                                .padding(.horizontal, metrics.scaled(6))
                                .padding(.top, metrics.scaled(4))
                            
                            Spacer()
                        }
                    )
                
                
                
                if(text != nil) {
                    Text(text!)
                        .font(.custom("PressStart2P-Regular", size: metrics.scaled(14)))
                        .foregroundColor(textColor)
                        .padding(.horizontal, metrics.scaled(8))
                        .frame(height: viewHeight)
                        .frame(width: width)
                        .padding(.top, metrics.scaled(4))
                }else{
            
                    Image(icon!)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: metrics.scaled(30), height: metrics.scaled(30))
                        .padding(.top, metrics.scaled(8))
                }
            }

        }
        .buttonStyle(.plain)
    }
}
