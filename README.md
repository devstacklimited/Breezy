# Breezy — iOS Weather App
A beautifully crafted iOS weather experience inspired by Apple’s native Weather app.


## Overview
Breezy is a modern, SwiftUI-based weather application designed to deliver fast, elegant, and accurate weather updates.
This app is built with clean architecture, async/await networking, modular services, and secure API key handling using Keychain.

Breezy automatically detects the user’s current city using Core Location and provides:
* Real-time weather
* Hourly forecast
* 7-day forecast
* Beautiful gradients + SF Symbols
* Multi-city support with swipe-to-switch
* Smooth animations inspired by iOS Weather


## ✨ Features
### 🌍 Location-Based Weather
* Automatic city detection
* Smooth permission screen with modern UI
* Reverse-geocoding for exact city names

## 🌦️ Forecast
* Current temperature + condition
* Hourly forecast
* Weekly forecast with temperature range bars
* Weather icons using SF Symbols
* Dynamic backgrounds based on weather & time


## 🏙️ Multiple Cities
* User can add multiple cities
* Swipe through cities using TabView paging
* 🔒 Secure API Key Storage
* API key stored using Keychain
* Securely loaded at app startup
* No hardcoded secrets


## 🧩 Clean Architecture
* SwiftUI for UI
* ObservableObject / StateObject for MVVM
* Interactor + Service Layer for cleaner networking
* EnvironmentObjects for shared managers


## 📦 Project Structure

```
Breezy/
│
├── Managers/
│   └── LocationManager.swift
│   └── SecretsManager.swift
│
├── Networking/
│   └── WeatherService.swift
│   └── WeatherEndpoints.swift
│
├── Interactors/
│   └── WeatherInteractor.swift
│
├── Presenters/
│   └── HomePresenter.swift
│
├── Views/
│   └── SplashView.swift
│   └── LocationPermissionView.swift
│   └── HomeView.swift
│   └── ManualCityEntryView.swift
│
└── Utils/
    └── Color+Extensions.swift
    └── Keys.swift
```



## 💾 Keychain Setup
Breezy uses a SecretsManager to securely load the API key:

```swift 
_ = SecretsManager.shared
```

API key is stored in JSON form:

```swift
struct Credentials: Codable {
    var appid: String
}
```

Stored with:
* `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
* Unique service identifier: `com.devstack.Breezy.auth`

## ⚙️ Installation
1️⃣ Clone the Repository

```swift
git clone https://github.com/yourusername/Breezy.git
cd Breezy
```

2️⃣ Add Your API Key
Go to:
`SecretsManager.swift` → Replace `appid` with your key (or store it once manually).

3️⃣ Install Dependencies
No external dependencies — native Swift & SwiftUI only.

4️⃣ Run the App
Open `Breezy.xcodeproj` in Xcode → Run on iOS 16+.


## 🔧 Tech Stack
| Technology                      | Purpose                      |
| ------------------------------- | ---------------------------- |
| **Swift 5.9+**                  | Core language                |
| **SwiftUI**                     | UI & layout                  |
| **CoreLocation**                | Real-time GPS + permissions  |
| **Keychain Services**           | Secure API key storage       |
| **URLSession (async/await)**    | Networking                   |
| **MVVM + Service Architecture** | Clean separation of concerns |


## Permission Required
Add to Info.plist:
```obectivec
NSLocationWhenInUseUsageDescription
NSLocationAlwaysAndWhenInUseUsageDescription
```

## Roadmap
🔜 Coming Soon:
* Dark mode enhancements
* Real-time animated backgrounds
* Radar view (rain & cloud layers)
* Widget support
* Alerts & notifications
* Siri shortcuts


## Future Improvements:
* Offline caching
* Multi-language support
* Temperature unit toggle (°C / °F)


## Contributing

Pull requests are welcome!
Please open an issue for new features or bug reports.


## 📄 License
MIT License — free to use and modify.
