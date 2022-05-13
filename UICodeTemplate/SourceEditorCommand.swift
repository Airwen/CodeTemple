//
//  SourceEditorCommand.swift
//  UICodeTemplate
//
//  Created by 张艾文 on 2022/5/7.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    private var codeContext = CTCodeContext()
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        if let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange , let selPostion = selection.start as? XCSourceTextPosition , let languageType = invocation.buffer.contentUTI.components(separatedBy: ".").last{
            
            // 当前文件每行显示的内容
            let lines = invocation.buffer.lines
            
            let lineNum = selPostion.line
            
            if let selText = lines[lineNum] as? String {
                if selText.contains(" ") {
                    if let variabel = selText.components(separatedBy: " ").last {
                        if variabel.contains("\n") {
                            let v = variabel.replacingOccurrences(of: "\n", with: "")
                            lines.replaceObject(at: lineNum, with: "")
                            lines.insert(codeContext.insert(code: v, fileType: languageType), at: lineNum)
                            
                            let appendCodeInfo = codeContext.appendCodeLines(codeLines: lines.copy() as! NSArray, selectedLineNum: lineNum, fileType: languageType)
                            
                            if appendCodeInfo.0.count > 0,
                               let appendlocationInfo = appendCodeInfo.1, let startIndex = appendlocationInfo.startIndex {
                                switch appendlocationInfo.codeAppendType {
                                case .insert:
                                    let indexSet = IndexSet(integersIn: startIndex..<(startIndex + appendCodeInfo.0.count))
                                    lines.insert(appendCodeInfo.0, at: indexSet)
                                case .append:
                                    lines.addObjects(from: appendCodeInfo.0)
                                case .none: break
                                    
                                }
                            }
                        }else {
                            lines.replaceObject(at: lineNum, with: "")
                            lines.insert(codeContext.insert(code: variabel, fileType: languageType), at: lineNum)
                        }
                    }
                }else {
                    lines.replaceObject(at: lineNum, with: "")
                    lines.insert(codeContext.insert(code: selText, fileType: languageType), at: lineNum)
                }
            }
        }
        completionHandler(nil)
    }
}
