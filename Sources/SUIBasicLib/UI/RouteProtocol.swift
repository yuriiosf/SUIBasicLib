//
//  RouteProtocol.swift
//  SUIBasicLib
//
//  Created by admin on 23.03.2025.
//

import Foundation

public protocol RouteProtocol: Equatable, Hashable, CaseIterable {
    var icon: String { get }
    var iconSF: Bool { get }
    var name: String { get }
    var isDebug: Bool { get }
}
