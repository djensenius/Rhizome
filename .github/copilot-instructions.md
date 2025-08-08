# Rhizome Multi-Platform Streaming App

Rhizome is a SwiftUI-based streaming/media app distributed on the App Store for iOS, macOS, tvOS, watchOS, and visionOS. The app connects to api.fluxhaus.io to stream video content, display photo galleries, and show scheduled programming.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Prerequisites and Environment Setup
- **CRITICAL**: Development requires macOS with Xcode 15+ installed
- **DO NOT attempt to build this project on Linux** - it uses Apple platform-specific frameworks (SwiftUI, AVKit, RealityKit)
- Install Xcode from the Mac App Store or Apple Developer portal
- Ensure Command Line Tools are installed: `xcode-select --install`

### Repository Setup and Dependencies
- Clone repository: `git clone https://github.com/djensenius/Rhizome.git`
- Dependencies are managed via Swift Package Manager (SPM) and automatically resolved by Xcode
- Key dependency: AZVideoPlayer (https://github.com/adamzarn/AZVideoPlayer v1.4.0)
- **No manual dependency installation required** - Xcode handles SPM dependencies automatically

### Building the Project
- Open `Rhizome.xcodeproj` in Xcode
- **NEVER CANCEL builds** - Xcode builds can take 5-15 minutes depending on target and clean builds
- **Set build timeout to 30+ minutes** for CI/automated builds
- Build times by target:
  - iOS app: ~3-5 minutes (incremental), ~8-12 minutes (clean)
  - macOS app: ~2-4 minutes (incremental), ~6-10 minutes (clean) 
  - tvOS app: ~3-5 minutes (incremental), ~8-12 minutes (clean)
  - watchOS app: ~2-3 minutes (incremental), ~5-8 minutes (clean)
  - visionOS app: ~4-6 minutes (incremental), ~10-15 minutes (clean)

### Running Tests
- **Unit tests**: Select test target in Xcode and press Cmd+U
- **UI tests**: Available for all platforms (RhizomeUITests, RhizomeMacUITests, RhizomeTVUITests)
- **Test execution time**: 2-5 minutes per platform, **NEVER CANCEL**
- **Set test timeout to 15+ minutes** for complete test suites

### Code Quality and Linting
- **ALWAYS run SwiftLint before committing**: 
  ```bash
  swiftlint lint
  ```
- SwiftLint execution time: ~0.2 seconds (very fast)
- Install SwiftLint via Homebrew: `brew install swiftlint`
- Current lint violations: 2 warnings about string/data conversion (non-critical)
- SwiftLint configuration in `.swiftlint.yml` excludes Packages directory

## Validation Scenarios

### ALWAYS manually validate changes by testing these core user flows:

#### Authentication Flow
1. Launch app on any platform
2. If no stored credentials, login screen should appear
3. Enter valid credentials for api.fluxhaus.io
4. App should store credentials in keychain and proceed to main interface

#### Video Streaming Flow  
1. Navigate to "Watch" tab
2. Video stream from api.fluxhaus.io should load and play
3. Test video controls (play/pause, seeking if available)
4. Verify video continues playing without interruption

#### Gallery Flow
1. Navigate to "Gallery" tab  
2. Photo gallery should load images from api.fluxhaus.io
3. Test image browsing and viewing

#### Schedule Flow
1. Navigate to "Schedule" tab
2. Programming schedule should load from api.fluxhaus.io
3. Verify schedule data displays correctly with times and descriptions

#### Settings Flow
1. Navigate to "Settings" tab
2. Test logout functionality
3. Verify logout clears keychain and returns to login screen

### Platform-Specific Testing
- **iOS**: Test on iPhone and iPad simulators, verify tab navigation
- **macOS**: Test window resizing, sidebar adaptable tabs
- **tvOS**: Test focus navigation, remote control interaction
- **watchOS**: Test basic functionality, limited interface
- **visionOS**: Test immersive interface elements

## Common Tasks and Commands

### Development Workflow
1. Open Xcode project: `open Rhizome.xcodeproj`
2. Select target and simulator/device
3. Build: Cmd+B (WAIT 5-15 minutes, do not cancel)
4. Run: Cmd+R
5. Test: Cmd+U (WAIT up to 15 minutes for full suite)

### Before Committing Changes
1. **ALWAYS run linting**: `swiftlint lint`
2. Fix any SwiftLint violations
3. Build all affected targets to ensure compilation
4. Run relevant tests for modified functionality
5. Test core user scenarios listed above

### CI/CD Pipeline
- GitHub Actions workflow runs SwiftLint on all Swift files
- Linting must pass for pull requests to be merged
- **Do not disable or bypass linting checks**

## Key Project Structure

### Main Targets
- `Rhizome` - iOS app with tab-based interface
- `RhizomeMac` - macOS app with sidebar adaptable tabs  
- `RhizomeTV` - tvOS app with focus-based navigation
- `RhizomeWatch Watch App` - watchOS companion app
- `RhizomeVision` - visionOS immersive app

### Shared Components
- `WhereWeAre.swift` - Authentication and keychain management
- `QueryFlux.swift` - API communication with api.fluxhaus.io
- `ContentView.swift` - Video streaming interface (platform-specific)
- `Gallery.swift` - Photo gallery functionality
- `Schedule.swift` - Programming schedule display
- `SettingsView.swift` - User settings and logout

### Test Suites
- Unit tests: `*Tests.swift` files (basic XCTest structure)
- UI tests: `*UITests.swift` files (launch and performance tests)

### Dependencies
- `AZVideoPlayer` - Video playback functionality
- `RealityKitContent` - visionOS 3D content package

## Important Implementation Details

### Authentication
- Uses keychain storage for api.fluxhaus.io credentials
- Keychain access group: `org.davidjensenius.Rhizome`
- Credentials validated against api.fluxhaus.io on app launch

### Network Requirements  
- App requires internet connection to api.fluxhaus.io
- Uses HTTPS with basic authentication
- Associated domains configured for webcredentials

### Platform Capabilities
- **All platforms**: Video streaming, photo gallery, scheduling
- **iOS/macOS/visionOS**: Full feature set with tab navigation
- **tvOS**: Focus-based navigation optimized for remote control
- **watchOS**: Simplified interface with core functionality

### Known Limitations
- **Cannot build on non-macOS platforms** due to Apple framework dependencies
- RealityKit components only functional on Apple platforms  
- Some features may require App Store distribution for full functionality
- Linux/CI environments can only run SwiftLint validation, not builds or tests

### Validated Commands
The following commands have been tested and verified to work:
- `swiftlint lint` - executes in ~0.15 seconds, shows 2 current warnings
- `swiftlint --version` - shows installed version
- Project structure verification - all documented files and targets exist
- Swift Package Manager dependency resolution via Package.resolved

## Common Reference Information

### Directory Structure
```
Rhizome/
├── .github/
│   ├── workflows/lint.yml    # SwiftLint CI pipeline
│   └── copilot-instructions.md
├── .swiftlint.yml           # SwiftLint configuration
├── Rhizome.xcodeproj/       # Main Xcode project
├── Packages/RealityKitContent/  # visionOS 3D content
├── Rhizome/                 # iOS app source
├── RhizomeMac/             # macOS app source  
├── RhizomeTV/              # tvOS app source
├── RhizomeWatch Watch App/ # watchOS app source
├── RhizomeVision/          # visionOS app source
├── *Tests/                 # Unit test targets
├── *UITests/               # UI test targets
├── README.md               # Basic project info
└── PRIVACY.md              # Privacy policy
```

### App Store Information
- Bundle ID: org.davidjensenius.Rhizome
- Available on App Store: https://apps.apple.com/app/id6504539170
- Supports iOS, macOS, tvOS, watchOS, visionOS

### API Integration
- Backend: api.fluxhaus.io
- Authentication: Basic auth with keychain storage
- Endpoints: Configuration, video streams, photo gallery, schedule data
- Network requirement: HTTPS connection required for all functionality

## Troubleshooting

### Build Failures
- Clean build folder: Product → Clean Build Folder in Xcode
- Reset package caches: File → Packages → Reset Package Caches
- Restart Xcode if dependency resolution fails
- Verify Xcode version compatibility (15+)

### Runtime Issues
- Check network connectivity to api.fluxhaus.io
- Verify keychain access permissions
- Test on different simulators/devices if issues are device-specific
- Check Console.app for detailed logging information

### Test Failures
- Ensure simulators are properly configured
- Reset simulator if UI tests fail: Device → Erase All Content and Settings
- Run tests individually to isolate failures
- Check for timing issues in UI tests (may need longer waits)