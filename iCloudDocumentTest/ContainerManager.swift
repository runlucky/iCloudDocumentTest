//
//  ContainerManager.swift
//  iCloudDocumentTest
//
//  Created by H5266 on 2020/03/17.
//  Copyright © 2020 kakeru. All rights reserved.
//

import Foundation

class ContainerManager {
    private let metadata = NSMetadataQuery()
    
    init() {
        metadata.predicate = NSPredicate(format: "%K like '*test.txt'", NSMetadataItemFSNameKey)
        metadata.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        
        NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: metadata, queue: nil) { notification in
            let query = notification.object as! NSMetadataQuery
            query.disableUpdates()
            NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: query)
            query.stop()
            
            if query.resultCount == 0 {
                print("ファイルが見つからなかった")
                let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)!
                    .appendingPathComponent("Documents")
                    .appendingPathComponent("test.txt")
                
                Document(fileURL: url).save(to: url, for: .forCreating) { success in
                    print(success ? "test.txt 作成" : "test.txt 作成失敗")
                }
                return
            }
            
            query.documents.forEach { document in
                document.open { success in
                    if success {
                        print(document.fileURL.absoluteString)
                        print(document.text ?? "nil")
                        
                        document.text = "上書きの値です"
                    } else {
                        print("ファイルオープンに失敗")
                    }
                }
            }
        }
       
        metadata.start()
    }
}

extension NSMetadataQuery {
    var documents: [Document] {
        self.results.compactMap { result in
            if let url = (result as AnyObject).value(forAttribute: NSMetadataItemURLKey) as? URL {
                return Document(fileURL: url)
            }
            return nil
        }
    }
}
