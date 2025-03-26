//
//  Dinding+Ext.swift
//  SUIBasicLib
//
//  Created by admin on 27.03.2025.
//

import SwiftUI

#if os(iOS) || os(macOS)
public extension Binding {
    static func optional<T: Equatable & Sendable>(_ value: Binding<T?>, _ defaultValue: T) -> Binding<T> {
        return .init(
            get: { value.wrappedValue ?? defaultValue },
            set: { value.wrappedValue = $0  }
        )
    }
}
#endif
