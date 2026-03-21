# Android Control

Control your Android phone from anywhere using AI. Chat with your device to manage files, check storage, battery, and more.

## Features

- **Natural Language Control** - Just ask the AI to list files, read documents, create folders, or anything else
- **File Management** - Create, read, edit, delete, rename, copy, and search files
- **Document Support** - Work with PDF, DOCX, PPTX, TXT, and MD files
- **Device Info** - Check storage, battery status, and full device specifications
- **Smart Commands** - Type `/` to see available commands
- **Offline Support** - App works even when disconnected
- **Session History** - Chat history persists across sessions
- **Dark/Light Theme** - Choose your preferred look

## How It Works

```
[Flutter App] → [PC Server] → [Ollama AI] → [ADB] → [Android Phone]
       ↑                                              ↑
       └────────────── Tailscale VPN ────────────────┘
```

Your phone and PC must be on the same Tailscale network.

## Setup

### 1. Android Phone
- Install **ADB Over Network** app from Play Store
- Open the app and keep it running
- Note the IP address shown (e.g., `100.101.120.96`)

### 2. PC - ADB Connection
```bash
adb connect 100.101.120.96:5555
```
Replace with your phone's IP.

### 3. PC - Ollama
Make sure Ollama is running:
```bash
ollama serve
```

### 4. PC - Server
```bash
cd D:\StudyMaterial\Notes\10th Semester\Project
node server.js
```

### 5. Flutter App
```bash
cd D:\StudyMaterial\Flutter\android_control
flutter run
```

## Usage

### Chat Commands
Type `/` in the chat to see all available commands:

| Command | What it does |
|---------|---------------|
| `/read` | Read a file |
| `/write` | Create or write to a file |
| `/list` | List files in a folder |
| `/search` | Search for files |
| `/rename` | Rename or move a file |
| `/copy` | Copy a file |
| `/delete` | Delete a file or folder |
| `/mkdir` | Create a directory |
| `/storage` | Check device storage |
| `/battery` | Check battery status |
| `/specs` | View device specifications |
| `/info` | Get file details |
| `/train` | Teach the AI your knowledge |
| `/forget` | Clear learned knowledge |

### Examples
- "List files in Downloads"
- "Read my notes.txt"
- "How much storage do I have?"
- "Show me battery status"
- "What's my phone's specs?"

## Configuration

### Server IP
If your PC's IP changes, update:
- Server: `D:\StudyMaterial\Notes\10th Semester\Project\src\config\index.js`
- Flutter: `D:\StudyMaterial\Flutter\android_control\lib\core\constants\app_constants.dart`

### Port
Default port is `3000`. Change in both server config and Flutter app constants.

## Troubleshooting

**Can't connect?**
1. Make sure both devices are on Tailscale
2. Open ADB Over Network app on phone
3. Run `adb connect` command again
4. Restart the server

**Server offline?**
- Tap the retry button
- Check that the server is running on PC
- Verify Tailscale connection

## Architecture

- **Flutter** - Mobile app with Clean Architecture
- **Express.js** - REST API server
- **Socket.IO** - Real-time communication
- **Ollama** - Local AI model (qwen2.5-coder:7b)
- **ADB** - Android Debug Bridge for device control
- **Tailscale** - VPN for secure connectivity
