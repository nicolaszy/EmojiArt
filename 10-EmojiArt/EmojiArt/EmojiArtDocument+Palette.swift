import Foundation
import SwiftUI
import CoreData

extension EmojiArtDocument {
    private static let palettesPersistenceKey = "EmojiArtDocument.PalettesKey"
    private static let defaultPalettes = [
        "🤯🤓😁🥳🤩😍😅😖🤣🤡🤔🤗😪🤢🤧🤮😇😂🤪🧐": "Faces",
        "🐶🐱🐹🐰🦊🐼🐨🐯🐸🐵🐧🐦🐤🦆🦅🦇🐺": "Animals",
        "🍎🍇🍌🧄🌶🥦🍆🥥🥝🍍🥭🍉🍓": "Food",
        "🏹🪁⚽️🛹🎱🥅🏓🤹‍♀️🩰🎨🎯🎮🎲♟🎸": "Activities"
    ]

    private(set) var paletteNames: [String: String] {
        get {
            var palettes: [String: String] = [:]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do{
                let fetchRequest : NSFetchRequest<Palette_> = Palette_.fetchRequest()
                let items = try context.fetch(fetchRequest)
                if(items.count==0){
                    print("no items so far")
                    //TODO: Standarditems anlegen
                    for item in EmojiArtDocument.defaultPalettes{
                        print(item.value) //name
                        print(item.key) //emojis
                        
                        let palette = Palette_(context: context)
                        palette.name = item.value
                        palette.content = item.key
                        
                        palettes[item.key] = item.value
                    }
                    //save data
                    do{try context.save()}
                    catch{
                        print("failed to save")
                    }
                }
                else{
                    
                    print("items found")
                    for item in items{
                        print(item.name!)
                        print(item.content!)
                        palettes[item.content!] = item.name!
                    }
                }
            }
            catch{
                
                
            }
            return palettes
        }
        set {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do{
                let fetchRequest : NSFetchRequest<Palette_> = Palette_.fetchRequest()
                let items = try context.fetch(fetchRequest)
                    print("no items so far")
                    //TODO: Standarditems anlegen
                    for item in newValue{
                        print(item.value) //name
                        print(item.key) //emojis
                        
                        //only create new palette if name doesn't exist...
                        let fetchRequestDetailed : NSFetchRequest<Palette_> = Palette_.fetchRequest()
                        fetchRequestDetailed.predicate = NSPredicate(format: "name == %@", String(item.value))
                        let items_ = try context.fetch(fetchRequestDetailed)
                        
                        if(items_.count==0){
                            let palette = Palette_(context: context)
                            palette.name = item.value
                            palette.content = item.key
                        }
                        else{
                            //update item
                            items_.first?.content = item.key
                        }
                    }
                    //save data
                    do{try context.save()}
                    catch{
                        print("failed to save")
                    }
            }
            catch{}
            objectWillChange.send()
        }
    }

    var sortedPalettesByName: [String] {
        paletteNames.keys.sorted { paletteNames[$0]! < paletteNames[$1]! }
    }

    var defaultPalette: String {
        sortedPalettesByName.first ?? "⚠️"
    }

    func renamePalette(_ palette: String, to name: String) {
        paletteNames[palette] = name
    }

    @discardableResult
    func addEmoji(_ emoji: String, toPalette palette: String) -> String {
        let newPalette = (emoji + palette).uniqued()
        return changePalette(palette, to: newPalette)
    }

    @discardableResult
    func removeEmojis(_ emojisToRemove: String, fromPalette palette: String) -> String {
        let newPalette = palette.filter { !emojisToRemove.contains($0) }
        return changePalette(palette, to: newPalette)
    }

    private func changePalette(_ palette: String, to newPalette: String) -> String {
        let name = paletteNames[palette] ?? ""
        paletteNames[palette] = nil
        paletteNames[newPalette] = name
        return newPalette
    }

    func palette(after referencePalette: String) -> String {
        palette(offsetBy: +1, from: referencePalette)
    }

    func palette(before referencePalette: String) -> String {
        palette(offsetBy: -1, from: referencePalette)
    }

    private func palette(offsetBy offset: Int, from referencePalette: String) -> String {
        if let currentIndex = sortedPalettesByName.firstIndex(of: referencePalette) {
            let newIndex = (currentIndex + (offset >= 0 ? offset : paletteNames.keys.count - abs(offset) % paletteNames.keys.count)) % paletteNames.keys.count
            return sortedPalettesByName[newIndex]
        } else {
            return defaultPalette
        }
    }
}

extension String {
    // Removes duplicate characters from a String
    func uniqued() -> String {
        var uniqued = ""
        for ch in self {
            if !uniqued.contains(ch) {
                uniqued.append(ch)
            }
        }
        return uniqued
    }
}
