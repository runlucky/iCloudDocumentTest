//
//  Document.swift
//  iCloudDocumentTest
//
//  Created by H5266 on 2020/03/17.
//  Copyright © 2020 kakeru. All rights reserved.
//

import Foundation
import UIKit

class Document: UIDocument {
    var text: String? = "empty" {
        didSet {
            save(to: fileURL, for: .forOverwriting) { success in
                print(success ? "上書き完了" : "上書き失敗")
            }
        }
    }

    override func contents(forType typeName: String) throws -> Any {
        guard let text = text else {
            return Data()
        }
        
        let length = text.lengthOfBytes(using: .utf8)
        return Data(bytes: UnsafePointer<UInt8>(text), count: length)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let contents = contents as? Data else { return }
        text = NSString(bytes: (contents as AnyObject).bytes, length: contents.count, encoding: String.Encoding.utf8.rawValue) as String?
    }
}


