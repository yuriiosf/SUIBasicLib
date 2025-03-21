//
//  File.swift
//  SUIBasicLib
//
//  Created by admin on 21.03.2025.
//

import SwiftUI

public protocol RouteProtocol: Equatable, Hashable {
    var icon: String { get }
    var name: String { get }
    var isDebug: Bool { get }
}

public struct RouteStack<T: Equatable> {
    var routes: [T]
    
    public init(initial: T) {
        self.routes = [initial]
    }
    
    mutating func set(_ route: T) {
        self.routes = [route]
    }
    
    mutating func push(_ route: T) {
        self.routes.append(route)
    }
    
    mutating func pop() {
        if self.routes.count > 1 {
            _ = self.routes.popLast()
        }
    }
    
    mutating func popToRoot() {
        let first = self.routes.first!
        self.routes = [first]
    }
    
    func top() -> T? { return self.routes.last }
}

public final class AppCoordinator<Route: Equatable & Hashable>: ObservableObject {
    @Published var routerStack: RouteStack<Route>
    
    public init(initialRoute: Route) {
        self.routerStack = RouteStack(initial: initialRoute)
    }
    
    public func set(_ route: Route) {
        withAnimation {
            routerStack.set(route)
        }
    }
    
    public func push(_ route: Route) {
        withAnimation {
            routerStack.push(route)
        }
    }
    
    public func pop() {
        withAnimation {
            routerStack.pop()
        }
    }
    
    public func popToRoot() {
        withAnimation {
            routerStack.popToRoot()
        }
    }
    
    public func top() -> Route? {
        return routerStack.top()
    }
}

public struct NavigationContainer<Routes: Hashable, Content: View>: View {
    @ObservedObject var coordinator: AppCoordinator<Routes>
    var content: (Routes) -> Content
    @State private var dragOffset: CGFloat = 0
    
    public var body: some View {
        ZStack {
            ForEach(Array(coordinator.routerStack.routes.enumerated()), id: \.element) { index, route in
                content(route)
                    .offset(x: index == coordinator.routerStack.routes.count - 1 ? dragOffset : 0)
                    .transition(.move(edge: .trailing))
                    .zIndex(Double(index))
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if coordinator.routerStack.routes.count > 1 {
                        dragOffset = max(value.translation.width, 0)
                    }
                }
                .onEnded { value in
                    if dragOffset > 100 {
                        coordinator.pop()
                    }
                    withAnimation {
                        dragOffset = 0
                    }
                }
        )
        .environmentObject(coordinator)
    }
}
