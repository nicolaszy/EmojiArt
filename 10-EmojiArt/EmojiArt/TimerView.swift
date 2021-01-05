//
//  TimerView.swift
//  EmojiArt
//
//  Created by Nicolas Kalousek on 25.11.20.
//  Copyright © 2020 fhnw. All rights reserved.
//

import SwiftUI
import CoreData

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
                            
                            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                            do{
                                let fetchRequest : NSFetchRequest<EmojiArtDocument_> = EmojiArtDocument_.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "id == %@", document.id.uuidString)
                                let items = try context.fetch(fetchRequest)
                                                        
                                if let currentItem = items.first{
                                    currentItem.timeInDocument = document.timeInDocument
                                }

                                //save data
                                do{try context.save()}
                                catch{
                                    print("failed to save")
                                }
                            }
                            catch{
                                print("error!!!")
                            }
                            
                            
                        }
        }
    }
}

