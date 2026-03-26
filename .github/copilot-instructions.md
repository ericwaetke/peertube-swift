# GitHub Copilot Instructions

## Issue Tracking with bd

This project uses **bd (beads)** for issue tracking - a Git-backed tracker designed for AI-supervised coding workflows.

**Key Features:**
- Dependency-aware issue tracking
- Auto-sync with Git via JSONL
- AI-optimized CLI with JSON output
- Built-in daemon for background operations
- MCP server integration for Claude and other AI assistants

**CRITICAL**: Use bd for ALL task tracking. Do NOT create markdown TODO lists.

### Essential Commands

```bash
# Find work
bd ready --json                    # Unblocked issues
bd stale --days 30 --json          # Forgotten issues

# Create and manage
bd create "Title" -t bug|feature|task -p 0-4 --json
bd create "Subtask" --parent <epic-id> --json  # Hierarchical subtask
bd update <id> --status in_progress --json
bd close <id> --reason "Done" --json

# Search
bd list --status open --priority 1 --json
bd show <id> --json

# Sync (CRITICAL at end of session!)
bd sync  # Force immediate export/commit/push
```

### Workflow

1. **Check ready work**: `bd ready --json`
2. **Claim task**: `bd update <id> --status in_progress`
3. **Work on it**: Implement, test, document
4. **Discover new work?** `bd create "Found bug" -p 1 --deps discovered-from:<parent-id> --json`
5. **Complete**: `bd close <id> --reason "Done" --json`
6. **Sync**: `bd sync` (flushes changes to git immediately)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Git Workflow

- Always commit `.beads/issues.jsonl` with code changes
- Run `bd sync` at end of work sessions
- Install git hooks: `bd hooks install` (ensures DB ↔ JSONL consistency)

### MCP Server (Recommended)

For MCP-compatible clients (Claude Desktop, etc.), install the beads MCP server:
- Install: `pip install beads-mcp`
- Functions: `mcp__beads__ready()`, `mcp__beads__create()`, etc.

## CLI Help

Run `bd <command> --help` to see all available flags for any command.
For example: `bd create --help` shows `--parent`, `--deps`, `--assignee`, etc.

## Project Context

### Architecture Overview

This is a **PeerTube Swift** project consisting of:

1. **Swift Package** (`/PeerTubeSwift/`): Core SDK with API client, models, and shared components
2. **iOS App** (`/App/PeerTube Swift/`): Native SwiftUI application consuming the SDK
3. **Documentation** (`*.md` files): Architecture, models, setup guides, and API documentation

### Key Project Structure

```
peertube-swift/
├── PeerTubeSwift/                    # Swift Package (SDK)
│   ├── Sources/PeerTubeSwift/        # Core library code
│   │   ├── Models/                   # Data models (Video, Channel, etc.)
│   │   ├── Services/                 # API services
│   │   └── UI/                       # Shared UI components
│   └── Package.swift                 # Package manifest
├── App/PeerTube Swift/               # iOS Application
│   ├── PeerTube Swift/               # App source code
│   │   ├── Services/                 # App-level services
│   │   ├── Views/                    # SwiftUI views
│   │   ├── ViewModels/               # App state & view models
│   │   └── Extensions/               # Model extensions
│   └── PeerTube Swift.xcodeproj      # Xcode project
└── .beads/                           # Issue tracking database
```

### Development Environment

**Xcode Setup:**
- Main project: `/App/PeerTube Swift/PeerTube Swift.xcodeproj`
- Two build schemes:
  - `"PeerTube Swift"`: Full iOS app (currently has build issues)
  - `"PeerTubeSwift"`: Swift package only (builds successfully)
- Target iOS 17.0+, uses SwiftUI + Combine

**Current Status:**
- ⚠️ **App has compilation errors** (tracked in bd issue `peertube-swift-a0l`)
- ✅ Swift package builds and tests pass
- ✅ Core API models and services are functional

### Common Development Patterns

**Data Flow:**
1. `PeerTubeServices` → API calls via SDK
2. `AppState` → Global app state management
3. View Models → Local state for specific views
4. SwiftUI Views → UI presentation

**Key Types to Know:**
- `Video`, `VideoChannel`, `Account` → Core content models
- `Instance` → PeerTube server configuration
- `PeerTubeServices` → Main API service container
- `AppState` → Root application state

**Code Style:**
- Use `@Published` properties with `ObservableObject` for reactive state
- Async/await for API calls
- SwiftUI for all UI (no UIKit)
- Proper error handling with `Result` types

### Quick Start for AI Assistants

1. **Check current issues**: `bd ready --json`
2. **For build problems**: Focus on `/App/PeerTube Swift/` compilation errors
3. **For API work**: Work in `/PeerTubeSwift/Sources/PeerTubeSwift/`
4. **Always import**: `Combine` for `@Published`, `PeerTubeSwift` for models
5. **Test builds**: Use Xcode MCP server with "PeerTube Swift" scheme

## Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Run `bd sync` at end of sessions
- ✅ Run `bd <cmd> --help` to discover available flags
- ✅ Import `Combine` when using `@Published` or `ObservableObject`
- ✅ Use `ActorImage.url` not `.path` for image URLs
- ✅ Check both Swift package and app compilation separately
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT commit `.beads/beads.db` (JSONL only)
- ❌ Do NOT mix async contexts without proper `await` annotations

## TubeSDK

The TubeSDK is located in . If you need to make API changes, you will need to modify this SDK.

## TubeSDK Location
The TubeSDK is located in /Users/ericwatke/Documents/GitHub/peertube-swift-sdk. Future agents should modify this repository when making API changes.
