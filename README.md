# VoiceCoder

🎤 Voice to code using OpenAI Whisper. Speak naturally, get working code.

## Features

- 🗣️ **Natural Speech** - No need to learn syntax
- 💻 **Multi-Language** - Swift, Python, JavaScript, Dart, Rust, Go, Kotlin
- ⚡ **Real-time** - Convert speech to code instantly
- 🧠 **Context Aware** - Remembers your project context
- 📋 **Smart Clipboard** - Auto-copies generated code
- 🎯 **Template Mode** - Common patterns (functions, classes, API calls)
- 📚 **History** - Save and reuse previous conversions
- 🔧 **Custom Prompts** - Define your own code generation rules

## Installation

```bash
git clone https://github.com/LennardVW/VoiceCoder.git
cd VoiceCoder
swift build -c release
cp .build/release/voicecoder /usr/local/bin/

# Set your OpenAI API key
export OPENAI_API_KEY=your_key_here
```

## Usage

```bash
# Start recording
voicecoder record

# Quick capture from clipboard
voicecoder quick

# Set language
voicecoder lang swift

# View history
voicecoder history
```

## Example Commands

| Speech | Generated Code |
|--------|---------------|
| "Create a function to filter even numbers" | Swift/Python/JS filter function |
| "Make a todo list view model" | Complete ViewModel class |
| "API call to fetch user data" | URLSession/Axios/Fetch code |
| "Sort array by date descending" | Sorted closure implementation |

## Supported Languages

- Swift 🍎
- Python 🐍
- JavaScript 📜
- TypeScript ⌨️
- Dart 🎯
- Rust 🦀
- Go 🐹
- Kotlin 🟣

## Voice Commands

While recording, say:
- "Use Swift" - Change language
- "Make it shorter" - Refactor to be concise
- "Add error handling" - Include try/catch
- "Create test" - Generate unit test

## Requirements
- macOS 15.0+ (Tahoe)
- Swift 6.0+
- OpenAI API key
- Microphone access

## License
MIT
