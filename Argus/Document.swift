//
//  Document.swift
//  Argus
//
//  Created by Kyle Fuller on 17/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Cocoa


class Document: NSDocument, NSTextStorageDelegate {
  var content:String = "" {
    didSet {
      if let textView = textView {
        textView.string = content
      }
    }
  }

  @IBOutlet var textView:NSTextView?

  override func windowControllerDidLoadNib(aController: NSWindowController) {
    super.windowControllerDidLoadNib(aController)

    textView?.string = content
    textView?.textStorage?.delegate = self
    textView?.textStorage?.font = NSFont(name: "Menlo", size: 15)
    textView?.automaticDashSubstitutionEnabled = false
    textView?.automaticQuoteSubstitutionEnabled = false
    textView?.automaticSpellingCorrectionEnabled = false
    textView?.continuousSpellCheckingEnabled = false

    textView?.textContainerInset = NSSize(width: 10, height: 15)
  }

  override class func autosavesInPlace() -> Bool {
    return true
  }

  override var windowNibName: String? {
    return "Document"
  }

  override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
    return content.dataUsingEncoding(NSUTF8StringEncoding)
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
    let storage = textView!.textStorage!
    var index = 0
    var insideString = false
    var escaped = false
    content = textView?.string ?? ""

    storage.enumerateAttribute(NSForegroundColorAttributeName, inRange: NSMakeRange(0, content.utf16Count), options: NSAttributedStringEnumerationOptions(0)) { (attribute, range, stop) in
      if let attribute = attribute as? String {
        storage.removeAttribute(attribute, range: range)
      }
    }

    for character in content {
      let range = NSMakeRange(index, 1)

      if character == "\"" && !escaped {
        insideString = !insideString
        storage.addAttribute(NSForegroundColorAttributeName, value: NSColor.redColor(), range: range)

        if !insideString {
          escaped = false
        }
      } else if insideString {
        if character == "\\" && !escaped {
          escaped = true
        } else {
          escaped = false
        }
        storage.addAttribute(NSForegroundColorAttributeName, value: NSColor.blueColor(), range: range)
      } else if contains(["n", "u", "l", "t", "r", "e", "f", "a", "s"], character) {
        storage.addAttribute(NSForegroundColorAttributeName, value: NSColor.purpleColor(), range: range)
      } else if contains([".", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], character) {
        storage.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: range)
      } else if contains(["[", "]", "{", "}", ",", ":"], character) {
        storage.addAttribute(NSForegroundColorAttributeName, value: NSColor.grayColor(), range: range)
      }

      ++index
    }
  }

  // MARK:

  func encodeJSON(options:NSJSONWritingOptions) {
    if let data = dataOfType("", error: nil) {
      var error:NSError?

      if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) {
        if let data = NSJSONSerialization.dataWithJSONObject(object, options: options, error: nil) {
          readFromData(data, ofType: "", error: nil)
        }
      } else {
        println("Failed to re-encode \(error)")
      }
    }
  }

  @IBAction func prettifyJSON(sender:AnyObject) {
    encodeJSON(.PrettyPrinted)
  }

  @IBAction func uglifyJSON(sender:AnyObject) {
    encodeJSON(NSJSONWritingOptions(0))
  }
}
