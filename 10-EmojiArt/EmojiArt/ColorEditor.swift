//
//  ColorEditor.swift
//  EmojiArt
//
//  Created by Nicolas Kalousek on 21.12.20.
//  Copyright © 2020 fhnw. All rights reserved.
//

import SwiftUI

struct ColorEditor: View {
    @Binding var chosenColor: Color
    @Binding var chosenAlpha: Float
    @ObservedObject var document: EmojiArtDocument
    @Binding var isPresented: Bool
    var body: some View {
        VStack {
            ZStack {
                Text("Edit Color")
                    .font(.headline)
                    .padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isPresented = false
                    }, label: { Text("Done").padding() })
                }
            }
            //add rest of content
            Form {
                Section {
                    ColorPicker("Background Color", selection: $chosenColor)
                    Slider(
                        value: $chosenAlpha,
                        in: 0.0...1.0
                        )
                }
            }
        }
    }
}

