import SwiftUI
import Combine

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
    private var emojiArtCancellable: AnyCancellable?
    let userdef = UserDefaults.standard
    
    init(id: UUID = UUID()) {
        self.id = id
        let defaultsKey = "EmojiArtDocument.\(id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArt()
        timeInDocument = Calendar.current.date(bySettingHour: userdef.integer(forKey: "hour"+self.id.uuidString), minute: userdef.integer(forKey: "minute"+self.id.uuidString), second: userdef.integer(forKey: "second"+self.id.uuidString), of: Date())!
        if userdef.object(forKey: "colorR"+self.id.uuidString)==nil {
            userdef.set(1, forKey: "colorR"+self.id.uuidString)
            userdef.set(1, forKey: "colorG"+self.id.uuidString)
            userdef.set(1, forKey: "colorB"+self.id.uuidString)
        }
        color = Color(red: userdef.double(forKey: "colorR"+self.id.uuidString), green: userdef.double(forKey: "colorG"+self.id.uuidString), blue: userdef.double(forKey: "colorB"+self.id.uuidString))
        emojiArtCancellable = $emojiArt.sink { emojiArt in
            print("json = \(emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
        }
        fetchBackgroundImageData()
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
                    userdef.set(r, forKey: "colorR"+self.id.uuidString)
                    userdef.set(g, forKey: "colorG"+self.id.uuidString)
                    userdef.set(b, forKey: "colorB"+self.id.uuidString)
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
