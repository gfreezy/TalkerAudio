import NaturalLanguage
//
//  Tokenizor.swift
//  iOS
//
//  Created by feichao on 2023/3/30.
//
import SwiftUI

public final class Tokenizor: Sendable {
    public init() {
        
    }

    public func naiveTokenize(_ inputString: String, returnPartial: Bool) -> ([String], String) {
        let separators = returnPartial ? [", ", ". ", "! ", "? ", "; ", ": "] : [". ", "! ", "? "]
        let separatorRanges: [Range<String.Index>] = separators.reduce([]) { result, separator in
            var tempResult = result
            var nextRange: Range<String.Index>? = inputString.range(of: separator)
            while let range = nextRange {
                tempResult.append(range)
                nextRange = inputString.range(
                    of: separator, range: range.upperBound..<inputString.endIndex)
            }
            return tempResult
        }
        var bounds = separatorRanges.map { range in
            range.upperBound
        }
        bounds.sort()
        var tokens: [String] = []
        var prevBound = inputString.startIndex
        for bound in bounds {
            tokens.append(String(inputString[prevBound..<bound]))
            prevBound = bound
        }
        let leftText = String(inputString[prevBound..<inputString.endIndex])
        let fullText = tokens.joined(separator: "")
        return (fullText.isEmpty ? [] : [fullText], leftText)
    }

    public func splitToSentences(_ inputString: String, maxChars: Int) -> [String] {
        var (sentences, last) = naiveTokenize(inputString, returnPartial: false)
        sentences.append(last)

        var paras: [String] = []
        var current_para = ""
        for s in sentences {
            if current_para.count + s.count >= maxChars {
                paras.append(current_para)
                current_para = s
            } else {
                current_para.append(s)
            }
        }
        if current_para != "" {
            paras.append(current_para)
        }
        return paras.filter { !$0.isEmpty }
    }
}
