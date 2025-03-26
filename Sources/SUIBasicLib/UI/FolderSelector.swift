//
//  FolderSelector.swift
//  SUIBasicLib
//
//  Created by admin on 26.03.2025.
//

import Foundation
import SwiftUI

#if os(macOS)
public struct FolderSelector: View {
    @Binding public var src: String
    public var newDestination: Bool
    public var chooseFiles: Bool
    public var onlyFolderName: Bool
    
    public init(src: Binding<String>, newDestination: Bool = false, chooseFiles: Bool = true, onlyFolderName: Bool = false) {
        self._src = src
        self.newDestination = newDestination
        self.chooseFiles = chooseFiles
        self.onlyFolderName = onlyFolderName
    }
    
    public var body: some View {
        Button(action: {
            self.selectFolder()
        }, label: {
            Image(systemName: "folder")
        })
    }
    
    public func selectFolder() {
        
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
        
        folderPicker.canChooseDirectories = true
        folderPicker.canChooseFiles = chooseFiles
        folderPicker.allowsMultipleSelection = false
        folderPicker.canDownloadUbiquitousContents = true
        folderPicker.canResolveUbiquitousConflicts = true
        if newDestination {
            folderPicker.canCreateDirectories = true
        }
        
        folderPicker.begin { response in
            
            if response == .OK {
                let pickedFolders = folderPicker.url
                let filePath = pickedFolders?.path().replacing("%20", with: " ").replacing("%5B", with: "[").replacing("%5D", with: "]")
                if onlyFolderName {
                    self.src = getLastFolderName(from: filePath ?? "")
                } else {
                    self.src = filePath ?? ""
                }
                DispatchQueue.main.async {
                    NSApp.keyWindow?.makeFirstResponder(nil)
                }
            }
        }
    }
    
    public func getLastFolderName(from directoryPath: String) -> String {
        let url = URL(fileURLWithPath: directoryPath)
        return url.lastPathComponent
    }
}

public struct FolderSelectorOptionalView: View {
    public let title: String
    @Binding public var text: String?
    
    public init(title: String, text: Binding<String?>) {
        self.title = title
        self._text = text
    }
    
    public var body: some View {
        HStack {
            TextField(title, text: .optional($text, ""))
            if let text = text, !text.isEmpty {
                Button(action: {
                    self.text = ""
                    DispatchQueue.main.async {
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    }
                }, label: {
                    Image(systemName: "xmark.circle")
                })
                .buttonStyle(.plain)
            }
            FolderSelector(src: .optional($text, ""), newDestination: true)
        }
    }
}

public struct FolderSelectorView: View {
    public let title: String
    public var onlyFolderName: Bool
    @Binding public var text: String
    public var extraAction: () -> Void = { }
    
    public init(title: String, onlyFolderName: Bool, text: Binding<String>, extraAction: @escaping () -> Void) {
        self.title = title
        self.onlyFolderName = onlyFolderName
        self._text = text
        self.extraAction = extraAction
    }
    
    public var body: some View {
        HStack {
            TextField(title, text: $text)
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                    DispatchQueue.main.async {
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    }
                    extraAction()
                }, label: {
                    Image(systemName: "xmark.circle")
                })
                .buttonStyle(.plain)
            }
            FolderSelector(src: $text, newDestination: true, onlyFolderName: onlyFolderName)
        }
    }
}
#endif
