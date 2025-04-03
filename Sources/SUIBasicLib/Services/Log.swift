//
//  File.swift
//  SUIBasicLib
//
//  Created by admin on 24.03.2025.
//

import Foundation

#if os(iOS) || os(macOS)
public func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    print(items, separator: separator, terminator: terminator)
#endif
}
#endif
