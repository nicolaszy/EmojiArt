import Foundation
import SwiftUI
import CoreData

struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    let id: String

    init(id_:String) {
        self.id = id_
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<EmojiArt_> = EmojiArt_.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let emojiArtItems = try! context.fetch(fetchRequest)
        emojiArtItems.first?.emoji?.forEach({
            emoji in
            print("there's an emoji here")
            print((emoji as! Emoji_).text!)
            let emoji_ = (emoji as! Emoji_)
            self.addEmoji(emoji_.text ?? "", x: Int(emoji_.x), y: Int(emoji_.y), size: Int(emoji_.size))
        })
        
    }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        let emoji = Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId)
        emojis.append(emoji)
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<Emoji_> = Emoji_.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", String(emoji.id))
        let items = try! context.fetch(fetchRequest)
        if items.count==1{
            print("emoji successfully added")
            //TODO: append to EmojiArt Emojis
            let fetchRequest : NSFetchRequest<EmojiArt_> = EmojiArt_.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let emojiArtItems = try! context.fetch(fetchRequest)
            emojiArtItems.first?.addToEmoji(items.first ?? Emoji_(context: context))
        }
    }
    
    
    
    struct Emoji: Identifiable, Codable {
        let text: String
        var x: Int //offset from center
        var y: Int //offset from center
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
            
            print("test")
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest : NSFetchRequest<Emoji_> = Emoji_.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", String(id))
            let items = try! context.fetch(fetchRequest)
            
            print("number of items found: "+String(items.count))
                if items.count==0 {
                let emoji = Emoji_(context: context)
                emoji.text = text
                emoji.x = Int64(x)
                emoji.y = Int64(y)
                emoji.id = Int64(id)
                emoji.size = Int64(size)
                    
                //save data
                do{try context.save()}
                catch{
                    print("failed to save")
                }
            }
        }
    }
}
