import Foundation
import AVFoundation

// MARK: - VoiceCoder
/// Voice to code using Whisper API
/// Converts natural speech into code in multiple languages

@main
struct VoiceCoder {
    static func main() async {
        let coder = VoiceCoderCore()
        await coder.run()
    }
}

@MainActor
final class VoiceCoderCore {
    private var isRecording = false
    private var recordedText = ""
    private var selectedLanguage = CodeLanguage.swift
    
    enum CodeLanguage: String, CaseIterable {
        case swift = "Swift"
        case python = "Python"
        case javascript = "JavaScript"
        case typescript = "TypeScript"
        case dart = "Dart"
        case rust = "Rust"
        case go = "Go"
        case kotlin = "Kotlin"
    }
    
    func run() async {
        print("""
        🎤 VoiceCoder - Voice to Code with Whisper
        
        Commands:
          record              Start voice recording
          stop                Stop recording and generate code
          lang <language>     Set output language (swift, python, js, etc.)
          languages           List available languages
          history             Show recent conversions
          copy                Copy last generated code
          clear               Clear history
          help                Show this help
          quit                Exit
        
        Current language: \(selectedLanguage.rawValue)
        """)
        
        while true {
            print("> ", terminator: "")
            guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else { continue }
            
            let parts = input.split(separator: " ", maxSplits: 1)
            let command = parts.first?.lowercased() ?? ""
            let arg = parts.count > 1 ? String(parts[1]) : ""
            
            switch command {
            case "record", "r":
                await startRecording()
            case "stop", "s":
                await stopRecording()
            case "lang", "language", "l":
                setLanguage(arg)
            case "languages", "langs":
                listLanguages()
            case "history", "h":
                showHistory()
            case "copy", "c":
                copyToClipboard()
            case "clear":
                clearHistory()
            case "help", "?":
                showHelp()
            case "quit", "q", "exit":
                print("👋 Goodbye!")
                return
            default:
                print("Unknown command. Type 'help' for options.")
            }
        }
    }
    
    func startRecording() async {
        guard !isRecording else {
            print("⚠️  Already recording! Type 'stop' to finish.")
            return
        }
        
        isRecording = true
        print("🎤 Recording... Speak your code request.")
        print("   Type 'stop' when finished.")
        
        // In production: Start AVAudioRecorder
        // For demo, simulate recording
        recordedText = ""
    }
    
    func stopRecording() async {
        guard isRecording else {
            print("⚠️  Not currently recording")
            return
        }
        
        isRecording = false
        print("🛑 Recording stopped")
        
        // In production: Send audio to Whisper API
        // For demo, simulate transcription
        print("\n🤖 Transcribing with Whisper...")
        
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Mock transcription
        let mockTranscriptions = [
            "Create a function that filters an array of integers and returns only the even numbers",
            "Write a Swift class for a todo item with title, due date, and completion status",
            "Generate a Python script to download a file from a URL",
            "Create a JavaScript function to debounce user input",
        ]
        
        recordedText = mockTranscriptions.randomElement()!
        print("📝 Transcription: \"\(recordedText)\"")
        
        // Generate code
        await generateCode(from: recordedText)
    }
    
    func generateCode(from text: String) async {
        print("\n💻 Generating \(selectedLanguage.rawValue) code...")
        
        // In production: Use GPT-4 or similar to convert description to code
        // For demo, show mock code
        
        let generatedCode = mockGeneratedCode(for: selectedLanguage, description: text)
        
        print("\n" + "━".repeating(50))
        print(generatedCode)
        print("━".repeating(50))
        
        // Store in history
        storeConversion(transcription: text, code: generatedCode)
        
        print("\n✅ Code generated!")
        print("   Use 'copy' to copy to clipboard")
    }
    
    private func mockGeneratedCode(for language: CodeLanguage, description: String) -> String {
        switch language {
        case .swift:
            return """
            func filterEvenNumbers(from numbers: [Int]) -> [Int] {
                return numbers.filter { $0 % 2 == 0 }
            }
            
            // Usage
            let numbers = [1, 2, 3, 4, 5, 6]
            let even = filterEvenNumbers(from: numbers)
            print(even) // [2, 4, 6]
            """
        case .python:
            return """
            def filter_even_numbers(numbers):
                return [n for n in numbers if n % 2 == 0]
            
            # Usage
            numbers = [1, 2, 3, 4, 5, 6]
            even = filter_even_numbers(numbers)
            print(even)  # [2, 4, 6]
            """
        case .javascript:
            return """
            function filterEvenNumbers(numbers) {
                return numbers.filter(n => n % 2 === 0);
            }
            
            // Usage
            const numbers = [1, 2, 3, 4, 5, 6];
            const even = filterEvenNumbers(numbers);
            console.log(even); // [2, 4, 6]
            """
        default:
            return "// Generated code for \(language.rawValue)\n// Based on: \(description)"
        }
    }
    
    func setLanguage(_ lang: String) {
        if let match = CodeLanguage.allCases.first(where: { 
            $0.rawValue.lowercased() == lang.lowercased() ||
            $0.rawValue.prefix(lang.count).lowercased() == lang.lowercased()
        }) {
            selectedLanguage = match
            print("✅ Language set to \(match.rawValue)")
        } else {
            print("❌ Unknown language: \(lang)")
            print("   Available: \(CodeLanguage.allCases.map(\\.rawValue).joined(separator: ", "))")
        }
    }
    
    func listLanguages() {
        print("💻 Available languages:")
        for (index, lang) in CodeLanguage.allCases.enumerated() {
            let marker = lang == selectedLanguage ? "→ " : "  "
            print("\(marker)\(index + 1). \(lang.rawValue)")
        }
    }
    
    func showHistory() {
        print("📜 Recent conversions:")
        print("   (History feature - would show last 10 conversions)")
    }
    
    func copyToClipboard() {
        // In production: Copy generated code to pasteboard
        print("✅ Code copied to clipboard")
    }
    
    func clearHistory() {
        print("🗑️  History cleared")
    }
    
    func showHelp() {
        print("""
        Commands:
          record       Start voice recording
          stop         Stop recording and generate code
          lang         Set output language
          languages    List available languages
          history      Show recent conversions
          copy         Copy last generated code
          clear        Clear history
          help         Show this help
          quit         Exit
        """)
    }
    
    private func storeConversion(transcription: String, code: String) {
        // In production: Save to local database
    }
}

extension String {
    func repeating(_ count: Int) -> String {
        String(repeating: self, count: count)
    }
}
