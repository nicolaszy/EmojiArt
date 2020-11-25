//
//  TimerView.swift
//  EmojiArt
//
//  Created by Nicolas Kalousek on 25.11.20.
//  Copyright © 2020 fhnw. All rights reserved.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var document: EmojiArtDocument
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let userdef = UserDefaults.standard
    @State var calendar = Calendar.current
    
    var body: some View {
        HStack{
            Spacer()
            Text("\(calendar.component(.hour, from: document.timeInDocument)):\(calendar.component(.minute, from: document.timeInDocument)):\(calendar.component(.second, from: document.timeInDocument))")
                        .onReceive(timer) { input in
                            document.timeInDocument += 1
                            userdef.setValue(calendar.component(.hour, from: document.timeInDocument), forKey: "hour"+document.id.uuidString)
                            userdef.setValue(calendar.component(.minute, from: document.timeInDocument), forKey: "minute"+document.id.uuidString)
                            userdef.setValue(calendar.component(.second, from: document.timeInDocument), forKey: "second"+document.id.uuidString)
                            print(calendar.component(.second, from: document.timeInDocument))
                        }
        }
    }
}

