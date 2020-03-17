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
                    if success {
                        print("test.txt 作成")
                    } else {
                        print("test.txt 作成失敗")
                    }
                }
                return
            }
            
            let url = (query.results[0] as AnyObject).value(forAttribute: NSMetadataItemURLKey) as! URL
            let document = Document(fileURL: url)
            document.open { success in
                if success {
                    print(document.fileURL.absoluteString)
                    print(document.text ?? "nil")
                } else {
                    print("ファイルオープンに失敗")
                }
            }
        }
       
        metadata.start()
    }
}
