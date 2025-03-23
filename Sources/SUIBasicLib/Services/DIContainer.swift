//
//  DIContainer.swift
//  SUIBasicLib
//
//  Created by admin on 21.03.2025.
//

import Foundation

public protocol DIContainerProtocol {
    func resolve<T>() -> T
}

public class DIContainer: ObservableObject, DIContainerProtocol {
    @MainActor public static let shared = DIContainer()
    
    private var dependencies: [String: Any] = [:]
    
    private init() {}
    
    public func register<T>(_ dependency: T) {
        let key = "\(type(of: T.self))"
        dependencies[key] = dependency
    }
    
    public func resolve<T>() -> T {
        let key = "\(type(of: T.self))"
        guard let dependency = dependencies[key] as? T else {
            fatalError("Dependency \(key) not found! Make sure to register it before resolving.")
        }
        return dependency
    }
}
