import SwiftUI

struct EmojiArtDocumentChooser: View {
    @ObservedObject var store: EmojiArtDocumentStore
    @State private var editMode = EditMode.inactive
    @State private var gridMode = false
    @State private var didChangeZoomFactor = false

    var body: some View {
        return NavigationView {
            if(gridMode){
                Grid(store.documents) { document in
                    GeometryReader { geometry in
                        NavigationLink(destination: EmojiArtDocumentView(document: document)){
                            ZStack {
                                Text(didChangeZoomFactor.description).font(.system(size: 0.000000000001))
                                document.color.opacity(document.alpha).overlay(
                                    OptionalImage(uiImage: document.backgroundImage)
                                        .scaleEffect(document.steadyStateZoomScale)
                                        //.offset((document.steadyStatePanOffset) * (document.steadyStateZoomScale))
                                )
                                .onAppear{
                                    self.zoomToFit(document, document.backgroundImage, in: geometry.size)
                                }
                                    ForEach(document.emojis) { emoji in
                                        Text(emoji.text)
                                            .font(animatableWithSize: emoji.fontSize * document.steadyStateZoomScale)
                                            .position(self.position(for: emoji, in: geometry.size, document: document))
                                }
                        }
                        }
                    }.onAppear{
                        self.didChangeZoomFactor = true
                        self.didChangeZoomFactor = false
                    }
                }
                .navigationBarTitle(self.store.name)
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack{
                            Button(action: {
                                self.store.addDocument()
                            }, label: {
                                Image(systemName: "plus").imageScale(.large)
                            })
                            Button(action: {
                                gridMode = !gridMode
                            }, label: {
                                Image(systemName: "square.grid.2x2.fill").imageScale(.large)
                        })}
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
            else{
            List {
                ForEach(store.documents) { document in
                        NavigationLink(destination: EmojiArtDocumentView(document: document).navigationBarTitle(self.store.name(for: document))) {
                            EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                                self.store.setName(name, for: document)
                            }
                        }
                }
                .onDelete(perform: { indexSet in
                    indexSet
                        .map { self.store.documents[$0] }
                        .forEach { document in
                            self.store.removeDocument(document)
                        }
                })
            }
            .navigationBarTitle(self.store.name)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        Button(action: {
                            self.store.addDocument()
                        }, label: {
                            Image(systemName: "plus").imageScale(.large)
                        })
                        Button(action: {
                            gridMode = !gridMode
                        }, label: {
                            Image(systemName: "square.grid.2x2").imageScale(.large)
                        })}
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)
        }
        }
    }
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize, document: EmojiArtDocument) -> CGPoint {
        var location = emoji.location
        let zoomScale = document.steadyStateZoomScale
        let panOffset = (document.steadyStatePanOffset) * zoomScale
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    private func zoomToFit(_ document: EmojiArtDocument,_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyStatePanOffset = .zero
            document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
}
