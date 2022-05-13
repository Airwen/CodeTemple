//
//  CTCodeContext.swift
//  UICodeTemplate
//
//  Created by 张艾文 on 2022/5/10.
//

import Foundation
import SwiftUI

struct UINamePrefix {
    static var label: String { "lbl" }
    static var button : String { "btn" }
    static var view : String { "v" }
    static var imageView : String { "imgv" }
    static var gradientLayer : String { "gradient" }
    static var TextField : String { "edtxt" }
    static var textView : String { "txt" }
    static var scroll : String { "sr" }
    static var tableview : String { "tv" }
    static var collectionview : String { "cv" }
}

enum LanguageType : String {
    case swift = "swift-source"
    case oc = "objective-c-source"
    case none = ""
}

struct CTCodeContext {
    var inserter: CTCodeInserter = CTNoneInserter(with: "")
    
    mutating func insert(code command: String, fileType: String) -> String {
        if let language = LanguageType(rawValue: fileType) {
            
            if command.hasPrefix(UINamePrefix.label) {
                inserter = CTLabelInser(with: command)
            } else if command.hasPrefix(UINamePrefix.button) {
                inserter = CTButtonInser(with: command)
            } else if command.hasPrefix(UINamePrefix.view) {
                inserter = CTViewInser(with: command)
            } else if command.hasPrefix(UINamePrefix.imageView) {
                inserter = CTImageViewInser(with: command)
            } else if command.hasPrefix(UINamePrefix.gradientLayer) {
                inserter = CTGradientLayerInser(with: command)
            } else if command.hasPrefix(UINamePrefix.gradientLayer) {
                inserter = CTGradientLayerInser(with: command)
            } else if command.hasPrefix(UINamePrefix.TextField) {
                inserter = CTTextFieldInser(with: command)
            } else if command.hasPrefix(UINamePrefix.textView) {
                inserter = CTTextViewInser(with: command)
            } else if command.hasPrefix(UINamePrefix.scroll) {
                inserter = CTScrollViewInser(with: command)
            } else if command.hasPrefix(UINamePrefix.tableview) {
                inserter = CTTableViewInser(with: command)
            } else if command.hasPrefix(UINamePrefix.collectionview) {
                inserter = CTCollectionInser(with: command)
            } else {
                inserter = CTNoneInserter(with: "")
            }
            return inserter.insetCode(language: language)
        }else {
            inserter = CTNoneInserter(with: "")
            return inserter.insetCode(language: LanguageType.none)
        }
    }
    
    func appendCodeLines(codeLines: NSArray, selectedLineNum: Int, fileType: String) ->([String], CTCodeAppendLocation?) {
        if let language = LanguageType(rawValue: fileType) {
            if let className = inserter.getClassName(language: language)(codeLines, selectedLineNum) {
                let appendLocation = inserter.appendLinesLocation(language: language)(codeLines, selectedLineNum)
                return (inserter.appendLines(language: language, withinClass: className), appendLocation)
            }else {
                return ([], nil)
            }
        }else {
            return ([], nil)
        }
    }
    
    func appendLocation(codeLines: NSArray, selectedLineNum: Int, fileType: String) -> CTCodeAppendLocation {
        if let language = LanguageType(rawValue: fileType) {
            return inserter.appendLinesLocation(language: language)(codeLines, selectedLineNum)
        }else {
            return CTCodeAppendLocation(startIndex: nil, codeAppendType: .none)
        }
    }
}
