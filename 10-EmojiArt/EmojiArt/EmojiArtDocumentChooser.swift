import SwiftUI

struct EmojiArtDocumentChooser: View {
    @ObservedObject var store: EmojiArtDocumentStore
    @State private var editMode = EditMode.inactive
    @State private var gridMode = false

    var body: some View {
        print(self.editMode)
        
        return NavigationView {
            
            if(gridMode){
                GeometryReader { geometry in
                Grid(store.documents) { document in
                    GeometryReader { geometry_ in
                            ZStack {
                                Color.white.overlay(
                                    OptionalImage(uiImage: document.backgroundImage)
                                        .scaleEffect(document.steadyStateZoomScale * gestureZoomScale)
                                        .offset((document.steadyStatePanOffset + gesturePanOffset) * (document.steadyStateZoomScale * gestureZoomScale))
                                )
                                
                                    ForEach(document.emojis) { emoji in
                                        Text(emoji.text)
                                            .font(animatableWithSize: emoji.fontSize * document.steadyStateZoomScale * gestureZoomScale)
                                            .position(self.position(for: emoji, in: geometry.size, document: document))
                                }
                        }
                    }
                }
                .navigationBarTitle(self.store.name)
                .navigationBarItems(
                    leading:
                    HStack{
                        Button(action: {
                            self.store.addDocument()
                        }, label: {
                            Image(systemName: "plus").imageScale(.large)
                        })
                        Button(action: {
                            gridMode = !gridMode
                        }, label: {
                            if(gridMode){
                                Image(systemName: "square.grid.2x2.fill").imageScale(.large)
                            }
                            else{
                                Image(systemName: "square.grid.2x2").imageScale(.large)
                            }
                    })},
                    trailing: EditButton()
                )
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
            .navigationBarItems(
                leading:
                HStack{
                    Button(action: {
                        self.store.addDocument()
                    }, label: {
                        Image(systemName: "plus").imageScale(.large)
                    })
                    Button(action: {
                        gridMode = !gridMode
                    }, label: {
                        if(gridMode){
                            Image(systemName: "square.grid.2x2.fill").imageScale(.large)
                        }
                        else{
                            Image(systemName: "square.grid.2x2").imageScale(.large)
                        }
                })},
                trailing: EditButton()
            )
            
            .environment(\.editMode, $editMode)
        }
        }
    }
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize, document: EmojiArtDocument) -> CGPoint {
        var location = emoji.location
        let zoomScale = document.steadyStateZoomScale * gestureZoomScale
        let panOffset = (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gesturePanOffset: CGSize = .zero
}
