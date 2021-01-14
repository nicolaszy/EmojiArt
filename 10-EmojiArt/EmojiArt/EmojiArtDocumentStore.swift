import Foundation
import Combine
import CoreData
import SwiftUI

class EmojiArtDocumentStore: ObservableObject {
    private static let persistenceKeyPrefix = "EmojiArtDocumentStore"

    let name: String

    func name(for document: EmojiArtDocument) -> String {
        if documentNames[document] == nil {
            documentNames[document] = "Untitled"
        }
        return documentNames[document]!
    }

    func setName(_ name: String, for document: EmojiArtDocument) {
        documentNames[document] = name
    }

    @Published private var documentNames = [EmojiArtDocument: String]()

    var documents: [EmojiArtDocument] {
        documentNames.keys.sorted { documentNames[$0]! < documentNames[$1]! }
    }

    func addDocument(named name: String = "Untitled") {
        let newDoc = EmojiArtDocument()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            let fetchRequest : NSFetchRequest<EmojiArtDocument_> = EmojiArtDocument_.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", newDoc.id.uuidString)
            let items = try context.fetch(fetchRequest)
            let newDocumentCoreData = items.first
            let documentName = EmojiArtDocumentNames_(context: context)
            documentName.name = name
            documentName.emojiArtDocument = newDocumentCoreData
            //save data
            do{try context.save()}
            catch{
                print("failed to save")
            }
            
        }
        catch{
            
        }
        documentNames[newDoc] = name
    }

    func removeDocument(_ document: EmojiArtDocument) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //delete document name
        do{
            let fetchRequest : NSFetchRequest<EmojiArtDocumentNames_> = EmojiArtDocumentNames_.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", documentNames[document] as! CVarArg)
            let items = try context.fetch(fetchRequest)
            context.delete(items.first!)
            do{try context.save()}
            catch{
                print("failed to save")
            }
        }
        catch{}
        documentNames[document] = nil
        
        //delete actual document
        do{
            let fetchRequest : NSFetchRequest<EmojiArtDocument_> = EmojiArtDocument_.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", document.id.uuidString)
            let items = try context.fetch(fetchRequest)
            context.delete(items.first!)
            do{try context.save()}
            catch{
                print("failed to save")
            }
        }
        catch{
            print("crash")
        }
        
    }

    private var autosave: AnyCancellable?

    init(named name: String = "Emoji Art") {
        self.name = name
        let defaultsKey = "\(EmojiArtDocumentStore.persistenceKeyPrefix).\(name)"
        
        //load document names with core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            let fetchRequest : NSFetchRequest<EmojiArtDocumentNames_> = EmojiArtDocumentNames_.fetchRequest()
            let items = try context.fetch(fetchRequest)
            for item in items{
                documentNames[EmojiArtDocument(id: UUID(uuidString: String(item.emojiArtDocument!.id!)) ?? UUID())] = item.name
            }
        }
        catch{}
        
        
        //autosave documents in core data
        autosave = $documentNames.sink { names in
            for name in names{
                do{
                    let fetchRequest : NSFetchRequest<EmojiArtDocumentNames_> = EmojiArtDocumentNames_.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "name == %@", name.value)
                    let items = try context.fetch(fetchRequest)
                    let documentName = items.first
                    documentName?.name = name.value
                    
                    //get the EmojiArtDocument_ for name.key
                    let fetchRequest2 : NSFetchRequest<EmojiArtDocument_> = EmojiArtDocument_.fetchRequest()
                    fetchRequest2.predicate = NSPredicate(format: "id == %@", name.key.id.uuidString)
                    let itemsEmojiArtDocument = try context.fetch(fetchRequest2)
                    
                    //set the value
                    documentName?.emojiArtDocument = itemsEmojiArtDocument.first
                    //save data
                    do{try context.save()}
                    catch{
                        print("failed to save")
                    }
                }
                catch{}
                
            }
        }

    }
}

extension Dictionary where Key == EmojiArtDocument, Value == String {
    init(fromPropertyList plist: Any?) {
        self.init()
        let uuidToName = plist as? [String:String] ?? [:]
        for uuid in uuidToName.keys {
            self[EmojiArtDocument(id: UUID(uuidString: uuid)!)] = uuidToName[uuid]
        }
    }

    var asPropertyList: [String:String] {
        var uuidToName = [String:String]()
        for (key, value) in self {
            uuidToName[key.id.uuidString] = value
        }
        return uuidToName
    }
}
