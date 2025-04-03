//
//  ProcessService.swift
//  SUIBasicLib
//
//  Created by admin on 03.04.2025.
//

import Foundation

#if os(macOS)
public func runProcess(executableURL: URL, arguments: [String]) -> String? {
    let process = Process()
    process.executableURL = executableURL
    process.arguments = arguments

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    process.launch()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
}

public func runProcess(executableURL: URL, arguments: [String]) async -> String? {
    return await withCheckedContinuation { continuation in
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        process.terminationHandler = { _ in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            continuation.resume(returning: output)
        }
        
        do {
            try process.run()
        } catch {
            continuation.resume(returning: "Error: \(error.localizedDescription)")
        }
    }
}
#endif
