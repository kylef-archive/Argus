//
//  Document.swift
//  Argus
//
//  Created by Kyle Fuller on 17/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Cocoa


class Document: NSDocument, NSTextStorageDelegate {
  var content:String?
  @IBOutlet var textView:NSTextView?

  override init() {
    super.init()
  }

  override func windowControllerDidLoadNib(aController: NSWindowController) {
    super.windowControllerDidLoadNib(aController)

    textView?.string = content
    textView?.textStorage?.delegate = self
    textView?.textStorage?.font = NSFont(name: "Menlo", size: 15)
  }

  override class func autosavesInPlace() -> Bool {
    return true
  }

  override var windowNibName: String? {
    return "Document"
  }

  override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
    return content?.dataUsingEncoding(NSUTF8StringEncoding)
  }

  override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
    if let content = NSString(data:data, encoding: NSUTF8StringEncoding) {
      self.content = content as String
      return true
    }

    outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    return false
  }

  // MARK: NSTextStorageDelegate

  func textStorageDidProcessEditing(notification: NSNotification) {
    content = textView?.string
    let storage = textView!.textStorage!
    var index = 0

    for character in content! {
      let range = NSMakeRange(index, 1)

      if contains(["[", "]", "{", "}", ",", ":"], character) {
        storage.addAttribute(NSForegroundColorAttributeName, value: NSColor.grayColor(), range: range)
      }

      ++index
    }
  }
}
