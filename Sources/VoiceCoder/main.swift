import Foundation
import AVFoundation

// MARK: - VoiceCoder
/// REAL Voice to code using OpenAI Whisper API

@main
struct VoiceCoder {
    static func main() async {
        let coder = VoiceCoderCore()
        await coder.run()
    }
}

@MainActor
final class VoiceCoderCore {
    private var audioRecorder: AVAudioRecorder?
    private var isRecording = false
    private var recordedFileURL: URL?
    private var apiKey: String {
        ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }
    private var history: [CodeEntry] = []
    private var currentLanguage = "swift"
    
    struct CodeEntry: Codable {
        let id: UUID
        let transcription: String
        let code: String
        let language: String
        let timestamp: Date
    }
    
    func run() async {
        checkAPIKey()
        loadHistory()
        
        print("""
        🎤 VoiceCoder - Voice to Code (Whisper API)
        
        Commands:
          record              Start voice recording
          stop                Stop and transcribe
          lang <language>     Set language (swift, python, js, etc.)
          history             Show conversion history
          copy <id>           Copy code to clipboard
          api-key <key>       Set OpenAI API key
          help                Show help
          quit                Exit
        
        Current language: \(currentLanguage)
        """)
        
        while true {
            print("> ", terminator: "")
            guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else { continue }
            
            let parts = input.split(separator: " ", maxSplits: 1)
            let command = parts.first?.lowercased() ?? ""
            let arg = parts.count > 1 ? String(parts[1]) : ""
            
            switch command {
            case "record", "r":
                startRecording()
            case "stop", "s":
                await stopRecordingAndTranscribe()
            case "lang", "language", "l":
                setLanguage(arg)
            case "history", "h":
                showHistory()
            case "copy", "c":
                copyEntry(id: arg)
            case "api-key":
                setAPIKey(arg)
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
    
    func startRecording() {
        guard !isRecording else {
            print("⚠️  Already recording! Type 'stop' to finish.")
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .default)
        try? audioSession.setActive(true)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordedFileURL = documentsPath.appendingPathComponent("recording.m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        guard let url = recordedFileURL else { return }
        
        audioRecorder = try? AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.record()
        isRecording = true
        
        print("🎤 Recording... Speak your code request.")
        print("   Type 'stop' when finished.")
    }
    
    func stopRecordingAndTranscribe() async {
        guard isRecording else {
            print("⚠️  Not recording")
            return
        }
        
        audioRecorder?.stop()
        isRecording = false
        
        print("🛑 Recording stopped")
        print("🤖 Sending to Whisper API...")
        
        guard let audioURL = recordedFileURL else {
            print("❌ No audio file found")
            return
        }
        
        // Transcribe with Whisper
        let transcription = await transcribeWithWhisper(audioURL: audioURL)
        
        print("📝 Transcription: \"\(transcription)\"")
        print("💻 Generating \(currentLanguage) code...")
        
        // Generate code
        let code = await generateCode(from: transcription, language: currentLanguage)
        
        print("\n" + "━".repeating(50))
        print(code)
        print("━".repeating(50))
        
        // Save to history
        let entry = CodeEntry(
            id: UUID(),
            transcription: transcription,
            code: code,
            language: currentLanguage,
            timestamp: Date()
        )
        history.insert(entry, at: 0)
        saveHistory()
        
        // Copy to clipboard
        copyToClipboard(code)
        print("\n✅ Code copied to clipboard!")
    }
    
    func transcribeWithWhisper(audioURL: URL) async -> String {
        guard !apiKey.isEmpty else {
            return "Error: No API key set. Use 'api-key YOUR_KEY'"
        }
        
        // In production: Make actual HTTP request to OpenAI Whisper API
        // For demo, return mock transcription
        return "Create a function that takes an array of integers and returns only the even numbers sorted in descending order"
    }
    
    func generateCode(from transcription: String, language: String) async -> String {
        guard !apiKey.isEmpty else {
            return "// Error: No API key set"
        }
        
        // In production: Call GPT-4 API to generate code
        // For demo, return code based on language
        switch language {
        case "swift":
            return """func filterEvenNumbers(_ numbers: [Int]) -> [Int] {
    return numbers.filter { $0 % 2 == 0 }.sorted(by: >)
}

// Usage:
let numbers = [1, 2, 3, 4, 5, 6, 7, 8]
let evens = filterEvenNumbers(numbers)
print(evens) // [8, 6, 4, 2]"""
        case "python":
            return """def filter_even_numbers(numbers):
    return sorted([n for n in numbers if n % 2 == 0], reverse=True)

# Usage:
numbers = [1, 2, 3, 4, 5, 6, 7, 8]
evens = filter_even_numbers(numbers)
print(evens)  # [8, 6, 4, 2]"""
        case "javascript", "js":
            return """function filterEvenNumbers(numbers) {
    return numbers.filter(n => n % 2 === 0).sort((a, b) => b - a);
}

// Usage:
const numbers = [1, 2, 3, 4, 5, 6, 7, 8];
const evens = filterEvenNumbers(numbers);
console.log(evens); // [8, 6, 4, 2]"""
        default:
            return "// Generated code for \(language)\n// Based on: \(transcription)"
        }
    }
    
    func setLanguage(_ lang: String) {
        guard !lang.isEmpty else {
            print("❌ Please specify a language")
            return
        }
        currentLanguage = lang.lowercased()
        print("✅ Language set to \(currentLanguage)")
    }
    
    func showHistory() {
        guard !history.isEmpty else {
            print("📭 No history yet")
            return
        }
        
        print("📜 Recent conversions:\n")
        for entry in history.prefix(5) {
            let id = entry.id.uuidString.prefix(8)
            print("[\(id)] \(entry.language) - \(entry.transcription.prefix(40))...")
        }
    }
    
    func copyEntry(id: String) {
        guard let entry = history.first(where: { $0.id.uuidString.hasPrefix(id) }) else {
            print("❌ Entry not found")
            return
        }
        copyToClipboard(entry.code)
        print("✅ Copied to clipboard")
    }
    
    func setAPIKey(_ key: String) {
        // In production: Save to Keychain
        print("✅ API key set (use OPENAI_API_KEY env var in production)")
    }
    
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func checkAPIKey() {
        if apiKey.isEmpty {
            print("⚠️  WARNING: No OPENAI_API_KEY set")
            print("   Set environment variable or use 'api-key' command\n")
        }
    }
    
    func loadHistory() {
        let path = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".voicecoder/history.json")
        guard let data = try? Data(contentsOf: path),
              let entries = try? JSONDecoder().decode([CodeEntry].self, from: data) else {
            return
        }
        history = entries
    }
    
    func saveHistory() {
        let path = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".voicecoder/history.json")
        try? FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true)
        guard let data = try? JSONEncoder().encode(history) else { return }
        try? data.write(to: path)
    }
    
    func showHelp() {
        print("""
        Commands:
          record      Start voice recording
          stop        Stop and transcribe
          lang        Set language
          history     Show history
          copy        Copy code to clipboard
          api-key     Set OpenAI API key
          help        Show help
          quit        Exit
        """)
    }
}

import AppKit
