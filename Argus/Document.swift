//
//  Document.swift
//  Argus
//
//  Created by Kyle Fuller on 17/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Cocoa

class Document: NSDocument {
  var content:String?
  @IBOutlet var textView:NSTextView?

  override init() {
    super.init()
  }

  override func windowControllerDidLoadNib(aController: NSWindowController) {
    super.windowControllerDidLoadNib(aController)

    textView?.string = content
  }

  override class func autosavesInPlace() -> Bool {
    return true
  }

  override var windowNibName: String? {
    return "Document"
  }

  override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
    // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    return nil
  }

  override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
    if let content = NSString(data:data, encoding: NSUTF8StringEncoding) {
      self.content = content as String
      return true
    }

    outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    return false
  }
}
