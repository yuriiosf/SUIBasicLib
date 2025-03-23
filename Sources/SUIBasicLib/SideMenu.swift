//
//  File.swift
//  SUIBasicLib
//
//  Created by admin on 21.03.2025.
//

import SwiftUI

struct SideMenuView<Routes: RouteProtocol>: View {
    @ObservedObject var coordinator: AppCoordinator<Routes>
    @ObservedObject var viewModel: SideMenuViewModel
    
    let routes: [Routes]
    let title: String
    var titleFont: Font
    let icon: String?
    let iconSF: Bool?
    let iconScale: CGFloat?
    var backgroundColor: Color
    var titleForegroundColor: Color
    var elementFont: Font
    var elementForegroundColor: Color
    var elementSelectedForegroundColor: Color
    var elementBackgroundColor: Color
    var elementSelectedBackgroundColor: Color
    var isRounded: Bool
    var roundedPadding: CGFloat?
    var roundedCornerRadius: CGFloat?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                if let icon = icon {
                    if let iconScale = iconScale {
                        titleIcon(icon: icon, iconScale: iconScale)
                    } else {
                        titleIcon(icon: icon, iconScale: 0.2)
                    }
                }
                Text(title)
                    .font(titleFont)
                    .foregroundStyle(titleForegroundColor)
            }
            
            .padding()
            ScrollView {
                ForEach(routes, id: \.self) { route in
                    menuButton(route)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
    }
    
    @ViewBuilder private func titleIcon(icon: String, iconScale: CGFloat) -> some View {
        if iconSF == true {
            Image(systemName: icon)
                .resizable()
                .frame(
                    width: UIScreen.main.bounds.width * iconScale,
                    height: UIScreen.main.bounds.width * iconScale
                )
        } else {
            Image(icon)
                .resizable()
                .frame(
                    width: UIScreen.main.bounds.width * iconScale,
                    height: UIScreen.main.bounds.width * iconScale
                )
        }
    }
    
    @ViewBuilder private func menuButton(_ route: Routes) -> some View {
        Button(action: {
            menuSelection(route)
        }) {
            HStack {
                if route.iconSF {
                    Image(systemName: route.icon)
                } else {
                    Image(route.icon)
                }
                
                Text(route.name)
                    .font(elementFont)
            }
            .foregroundStyle(coordinator.top() == route ? elementSelectedForegroundColor : elementForegroundColor)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundShape(isRounded: isRounded, radius: roundedCornerRadius ?? 12, padding: roundedPadding, route: route))
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    func backgroundShape(isRounded: Bool, radius: CGFloat, padding: CGFloat?, route: Routes) -> some View {
        if isRounded {
            RoundedRectangle(cornerRadius: radius)
                .fill(coordinator.top() == route ? elementSelectedBackgroundColor : elementBackgroundColor)
                .padding(.horizontal, padding ?? 6)
        } else {
            Rectangle()
                .fill(coordinator.top() == route ? elementSelectedBackgroundColor : elementBackgroundColor)
        }
    }
    
    private func menuSelection(_ state: Routes) {
        if coordinator.top() != state {
            withAnimation {
                coordinator.set(state)
            }
        }
        HapticService.shared.selection()
        viewModel.closeMenu()
    }
}

@MainActor
final class SideMenuViewModel: ObservableObject {
    @Published var offset: CGFloat = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? (-UIScreen.main.bounds.width * 0.3) : (-UIScreen.main.bounds.height * 0.3)
    @Published var menuWidth: CGFloat = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? (UIScreen.main.bounds.width * 0.7) : (UIScreen.main.bounds.height * 0.7)
    @Published var menuStart: CGFloat = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? (-UIScreen.main.bounds.width * 0.3) : (-UIScreen.main.bounds.height * 0.3)
    @Published var isMenuOpen: Bool = false
    
    func openMenu() {
        isMenuOpen = true
        offset = menuWidth
    }
    
    func closeMenu() {
        isMenuOpen = false
        offset = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? (-UIScreen.main.bounds.width * 0.3) : (-UIScreen.main.bounds.height * 0.3)
    }
}

public struct SideMenuContentView<Content: View, Routes: RouteProtocol>: View {
    @ObservedObject var coordinator: AppCoordinator<Routes>
    @StateObject private var viewModel = SideMenuViewModel()
    let routes: [Routes]
    let title: String
    var titleFont: Font
    var icon: String?
    var iconSF: Bool?
    var iconScale: CGFloat?
    var menuButtonForegroundColor: Color
    var backgroundColor: Color
    var titleForegroundColor: Color
    var elementFont: Font
    var elementForegroundColor: Color
    var elementSelectedForegroundColor: Color
    var elementBackgroundColor: Color
    var elementSelectedBackgroundColor: Color
    var transactionWithAnimation: Bool
    var isRounded: Bool
    var roundedPadding: CGFloat?
    var roundedCornerRadius: CGFloat?
    let content: (Routes) -> Content
    
    public init(
        coordinator: AppCoordinator<Routes>,
        routes: [Routes],
        title: String,
        titleFont: Font = .largeTitle,
        icon: String? = nil,
        iconSF: Bool? = nil,
        iconScale: CGFloat? = nil,
        menuButtonForegroundColor: Color = .black,
        backgroundColor: Color = .gray,
        titleForegroundColor: Color = .black,
        elementFont: Font = .body,
        elementForegroundColor: Color = .black,
        elementSelectedForegroundColor: Color = .white,
        elementBackgroundColor: Color = .gray,
        elementSelectedBackgroundColor: Color = .accentColor,
        transactionWithAnimation: Bool = true,
        isRounded: Bool = false,
        roundedPadding: CGFloat? = nil,
        roundedCornerRadius: CGFloat? = nil,
        @ViewBuilder content: @escaping (Routes) -> Content
    ) {
        self.coordinator = coordinator
        self.routes = routes
        self.title = title
        self.titleFont = titleFont
        self.icon = icon
        self.iconSF = iconSF
        self.iconScale = iconScale
        self.menuButtonForegroundColor = menuButtonForegroundColor
        self.backgroundColor = backgroundColor
        self.titleForegroundColor = titleForegroundColor
        self.elementFont = elementFont
        self.elementForegroundColor = elementForegroundColor
        self.elementSelectedForegroundColor = elementSelectedForegroundColor
        self.elementBackgroundColor = elementBackgroundColor
        self.elementSelectedBackgroundColor = elementSelectedBackgroundColor
        self.transactionWithAnimation = transactionWithAnimation
        self.isRounded = isRounded
        self.roundedPadding = roundedPadding
        self.roundedCornerRadius = roundedCornerRadius
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                ForEach(Array(coordinator.routerStack.routes.enumerated()), id: \.element) { index, route in
                    content(route)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .overlay(content: {
                            if viewModel.isMenuOpen {
                                Color.gray
                                    .opacity(0.3)
                                    .brightness(-0.6)
                                    .ignoresSafeArea(.all)
                            }
                        })
                        .disabled(viewModel.isMenuOpen)
                        .onTapGesture {
                            viewModel.closeMenu()
                        }
                }
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                viewModel.isMenuOpen ? viewModel.closeMenu() : viewModel.openMenu()
                            }
                            HapticService.shared.selection()
                        }, label: {
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(menuButtonForegroundColor)
                                .font(.system(size: 40))
                                .padding(.horizontal)
                                .padding(.top, 8)
                        })
                        Spacer()
                    }
                    Spacer()
                }
                SideMenuView(
                    coordinator: coordinator,
                    viewModel: viewModel,
                    routes: routes,
                    title: title,
                    titleFont: titleFont,
                    icon: icon,
                    iconSF: iconSF,
                    iconScale: iconScale,
                    backgroundColor: backgroundColor,
                    titleForegroundColor: titleForegroundColor,
                    elementFont: elementFont,
                    elementForegroundColor: elementForegroundColor,
                    elementSelectedForegroundColor: elementSelectedForegroundColor,
                    elementBackgroundColor: elementBackgroundColor,
                    elementSelectedBackgroundColor: elementSelectedBackgroundColor,
                    isRounded: isRounded,
                    roundedPadding: roundedPadding,
                    roundedCornerRadius: roundedCornerRadius
                )
                .frame(width: viewModel.menuWidth)
                .offset(x: viewModel.offset - viewModel.menuWidth)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if viewModel.isMenuOpen {
                            viewModel.offset = max(0, min(value.translation.width + (viewModel.isMenuOpen ? viewModel.menuWidth : 0), viewModel.menuWidth))
                        } else {
                            if value.startLocation.x < 50 {
                                viewModel.offset = max(0, min(value.translation.width, viewModel.menuWidth))
                            }
                        }
                    }
                    .onEnded { value in
                        if viewModel.isMenuOpen {
                            if value.translation.width < -100 {
                                viewModel.closeMenu()
                            } else {
                                viewModel.openMenu()
                            }
                        } else {
                            if value.translation.width > 100 {
                                viewModel.openMenu()
                            } else {
                                viewModel.closeMenu()
                            }
                        }
                    }
            )
            .animation(.easeInOut, value: viewModel.isMenuOpen)
            .onChange(of: viewModel.isMenuOpen) { event in
                event ? viewModel.openMenu() : viewModel.closeMenu()
            }
        }
        .transaction {
            if !transactionWithAnimation {
                $0.animation = nil
            }
        }
    }
}
