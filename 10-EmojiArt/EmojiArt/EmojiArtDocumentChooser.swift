import SwiftUI

struct EmojiArtDocumentChooser: View {
    @ObservedObject var store: EmojiArtDocumentStore
    @State private var editMode = EditMode.inactive
    @State private var gridMode = false

    var body: some View {
        print(self.editMode)
        
        return NavigationView {
            
            List {
                ForEach(self.store.documents) { document in
                    if(gridMode){}
                    else{
                    NavigationLink(destination: EmojiArtDocumentView(document: document).navigationBarTitle(self.store.name(for: document))) {
                        EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                            self.store.setName(name, for: document)
                        }
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
    
    var listView: some View{
        return NavigationView {
            List {
                ForEach(self.store.documents) { document in
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
                        self.store.addDocument()
                    }, label: {
                        Image(systemName: "square.grid.2x2").imageScale(.large)
                })},
                trailing: EditButton()
            )
            
            .environment(\.editMode, $editMode)
        }
    }
    
    var gridView: some View{
        return NavigationView {
            List {
                ForEach(self.store.documents) { document in
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
                        self.store.addDocument()
                    }, label: {
                        Image(systemName: "square.grid.2x2").imageScale(.large)
                })},
                trailing: EditButton()
            )
            
            .environment(\.editMode, $editMode)
        }
    }
}
