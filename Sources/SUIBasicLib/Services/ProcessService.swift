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

public func runThrowingProcess(executableURL: URL, arguments: [String]) async throws -> String? {
    let process = Process()
    process.executableURL = executableURL
    process.arguments = arguments
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    
    try process.run()
    
    return try await withCheckedThrowingContinuation { continuation in
        process.terminationHandler = { _ in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            continuation.resume(returning: output)
        }
    }
}

public func runProcessClear(executableURL: URL, arguments: [String]) async -> String? {
    return await withCheckedContinuation { continuation in
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        process.terminationHandler = { _ in
            let outputData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let errorOutput = String(data: stderrData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

            if let errorOutput, !errorOutput.isEmpty {
                print("⚠️ stderr: \(errorOutput)")
            }
            
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
