import SwiftUI
import Combine
import CoreData

class EmojiArtDocument: ObservableObject, Hashable, Equatable, Identifiable {
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }

    let id: UUID

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static let palette: String =  "🐶🐱🐹🐰🦊🐼🐨🐯🐸🐵🐧🐦🐤🦆🦅🦇🐺"

    @Published private var emojiArt: EmojiArt
    @Published var timeInDocument: Date
    @Published var color: Color
    @Published var alpha: Double
    private var emojiArtCancellable: AnyCancellable?
    let userdef = UserDefaults.standard
    
    init(id: UUID = UUID()) {
        
        //Core Data Test -> seems to be working so far; TODO: save the data that needs to actually be saved! 
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            let fetchRequest : NSFetchRequest<EmojiArtDocument_> = EmojiArtDocument_.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
            var items = try context.fetch(fetchRequest)
            
            print("number of items found: "+String(items.count))
                if items.count==0 {
                let newEmojiArtDocument = EmojiArtDocument_(context: context)
                newEmojiArtDocument.alpha = 1
                newEmojiArtDocument.colorR = 1
                newEmojiArtDocument.colorG = 1
                newEmojiArtDocument.colorB = 1
                newEmojiArtDocument.timeInDocument =  Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                newEmojiArtDocument.id = id.uuidString
                    
                //save data
                do{try context.save()}
                catch{
                    print("failed to save")
                }
            }
            items = try context.fetch(fetchRequest)
            
            let item = items.first ?? EmojiArtDocument_(context: context)
            
            self.id = id
            self.alpha = item.alpha
            self.color = Color(red: item.colorR, green: item.colorG, blue: item.colorB)
            self.timeInDocument = item.timeInDocument ?? Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                    
            let defaultsKey = "EmojiArtDocument.\(id.uuidString)"
            emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArt()
                
            emojiArtCancellable = $emojiArt.sink { emojiArt in
                    print("json = \(emojiArt.json?.utf8 ?? "nil")")
                    UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
            }
            fetchBackgroundImageData()
            
            
        }
        catch{
            
            print("error!!!")
            self.id = id
            self.alpha = 1
            self.color = Color(red: 1, green: 1, blue: 1)
            self.timeInDocument = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                    
            let defaultsKey = "EmojiArtDocument.\(id.uuidString)"
            emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArt()
                
            emojiArtCancellable = $emojiArt.sink { emojiArt in
                    print("json = \(emojiArt.json?.utf8 ?? "nil")")
                    UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
            }
            fetchBackgroundImageData()
            
        }
        
        //self.id = id
        
    }
    
    @Published private(set) var backgroundImage: UIImage?
    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero

    var emojis: [EmojiArt.Emoji] {emojiArt.emojis}
    
    // MARK: - Intents
    func changeColor(_ c: Color){
        color = c
        let colorString = "\(color)"
                let colorArray: [String] = colorString.components(separatedBy: " ")

                if colorArray.count > 1 {
                    let r: Double = Double((Double(colorArray[1]) ?? 1))
                    let g: Double = Double((Double(colorArray[2]) ?? 1))
                    let b: Double = Double((Double(colorArray[3]) ?? 1))
                    //let alpha: CGFloat = CGFloat((Float(colorArray[4]) ?? 1))
                    
                    //save data with core data
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    do{
                        let fetchRequest : NSFetchRequest<EmojiArtDocument_> = EmojiArtDocument_.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", self.id.uuidString)
                        let items = try context.fetch(fetchRequest)
                                                
                        if let currentItem = items.first{
                            currentItem.colorR = r
                            currentItem.colorG = g
                            currentItem.colorB = b
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
    
    func changeAlpha(_ a: Double){
        alpha = a
        
        //save data with core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            let fetchRequest : NSFetchRequest<EmojiArtDocument_> = EmojiArtDocument_.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", self.id.uuidString)
            let items = try context.fetch(fetchRequest) 
                                    
            if let currentItem = items.first{
                currentItem.alpha = a
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
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    var backgroundURL: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }

    private var fetchImageCancellable: AnyCancellable?
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
            let publisher = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, response in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
            fetchImageCancellable = publisher.assign(to: \.backgroundImage, on: self)
        }
    }  
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
