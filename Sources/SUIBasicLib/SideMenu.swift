//
//  File.swift
//  SUIBasicLib
//
//  Created by admin on 21.03.2025.
//

import SwiftUI

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
    
    var angle: CGFloat {
        let clampedValue = min(max(offset, menuStart), menuWidth)
        let normalized = (clampedValue - menuStart) / (menuWidth - menuStart)
        return normalized * 90
    }
}

public struct SideMenuContentView<Content: View, Routes: Hashable>: View {
    @ObservedObject var appRouter: AppCoordinator<Routes>
    @ViewBuilder var content: Content
    @StateObject private var viewModel = SideMenuViewModel()
    @State var backgroundColor: Color
//    @State var 
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                content
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
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                viewModel.isMenuOpen ? viewModel.closeMenu() : viewModel.openMenu()
                            }
                            HapticService.shared.selection()
                        }, label: {
                            Image(systemName: "line.3.horizontal")
//                                .foregroundStyle(Color.primaryReverse)
                                .font(.system(size: 40))
                                .rotationEffect(.degrees(Double(max(-180, min(viewModel.angle, 180)))))
                                .animation(.easeInOut, value: viewModel.angle)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        })
                        Spacer()
                    }
                    Spacer()
                }
//                SideMenuView(appRouter: appRouter, viewModel: viewModel)
//                    .background(Color.secondaryBackground)
//                    .frame(width: viewModel.menuWidth)
//                    .offset(x: viewModel.offset - viewModel.menuWidth)
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
    }
}
