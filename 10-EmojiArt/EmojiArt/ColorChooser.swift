//
//  ColorChooser.swift
//  EmojiArt
//
//  Created by Nicolas Kalousek on 21.12.20.
//  Copyright © 2020 fhnw. All rights reserved.
//

import SwiftUI

struct ColorChooser: View {
    @ObservedObject var document: EmojiArtDocument
    @Binding var chosenColor: Color
    @Binding var chosenAlpha: Double
    @State private var isColorEditorPresented = false
    var body: some View {
        Image(systemName: "circles.hexagongrid").imageScale(.large)
        .onTapGesture {
            self.isColorEditorPresented = true
        }
        .sheet(isPresented: $isColorEditorPresented) {
            ColorEditor(chosenColor: self.$chosenColor, chosenAlpha: self.$chosenAlpha, document: self.document, isPresented: self.$isColorEditorPresented)
        }
    .fixedSize(horizontal: true, vertical: false)
    .onAppear { self.chosenColor = self.document.color }
}

}
