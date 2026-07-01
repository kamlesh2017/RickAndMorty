# Rick & Morty iOS

Browse every character from the Rick and Morty universe — search by name, filter by status, save favourites, and drill into episode history. Built with **SwiftUI** and **Clean Architecture** as a production-style iOS sample app.

**Platform:** iOS 17+ · **Swift:** 5.9+ · **UI:** SwiftUI · **Architecture:** Clean

**Screenshots:** [`docs/screenshots/`](docs/screenshots/)

---

## What it does

| | |
|---|---|
| 🔍 **Search** | Find characters by name with debounced input so the API isn't hit on every keystroke |
| 🏷️ **Filter** | Narrow the list to Alive, Dead, or Unknown — works together with search |
| ❤️ **Favourites** | Tap the heart on any row or detail screen; saved locally between launches |
| 📄 **Infinite scroll** | Characters load page by page as you scroll toward the bottom |
| 📱 **Detail view** | See species, gender, origin, location, and every episode a character appears in |
| 📶 **Offline mode** | If the network drops, the app shows the last successfully loaded list |
| 🌙 **Dark mode** | Adaptive colours throughout — no hard-coded light-only styling |

---

## Quick start

**You need:** Xcode 15+ and an iOS 17+ simulator or device.

```bash
git clone <your-repo-url>
cd RickAndMorty
open RickAndMorty.xcodeproj
```

Press **⌘R** to run, **⌘U** to test.

Or from the command line:

```bash
xcodebuild -scheme RickAndMorty \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test
```

Data comes from the free, public [Rick and Morty API](https://rickandmortyapi.com).

---

## How it's built

This is a **three-layer Clean Architecture** app — Presentation, Domain, and Data — wired together through a single `DependencyContainer`. ViewModels never talk to the network directly; they call use cases, which call repository protocols.

```
Presentation  →  ViewModels, SwiftUI views, components
Domain        →  Models, use cases, repository protocols (pure Swift)
Data          →  Network layer, DTOs, mappers, cache, concrete repositories
```

```
RickAndMorty/
├── App/DependencyContainer.swift
├── Domain/
│   ├── Models/
│   ├── UseCases/
│   ├── Repositories/        # protocols
│   └── Errors/
├── Data/
│   ├── Network/
│   ├── DTOs/ & Mappers/
│   ├── Cache/
│   └── Repositories/        # implementations
└── Presentation/
    ├── CharacterList/
    ├── CharacterDetail/
    └── Common/
```

**Design choices worth noting:**

- **Use cases hold business logic** — ViewModels only manage UI state and user actions.
- **Testable networking** — `URLSession` is hidden behind `URLSessionProtocol`; tests inject `MockURLSession`.
- **DTOs never leak into Domain** — API responses are mapped to domain models in the Data layer.
- **404 on search = empty list** — the API returns 404 when no character matches; the app treats that as "no results", not a crash.
- **SwiftData + UserDefaults for persistence** — the latest fetched character page is cached in SwiftData (30-minute TTL); favourites stay in UserDefaults.

**Testing:** unit tests cover ViewModels, use cases, and the network service; snapshot-style tests verify character row rendering across all status states.

---

## Trade-offs & next steps

| Decision | Why |
|----------|-----|
| SwiftData for character cache | Persists the latest fetched page with a 30-minute TTL; favourites stay in UserDefaults |
| Parallel episode fetching | Faster detail screen; trades a burst of requests for lower latency |
| Single Xcode target | Layer boundaries enforced by folders, not separate SPM packages |

**If I had more time:** extract Domain/Data into SPM modules, add image caching for smoother scrolling, adopt reference-image snapshot testing, introduce a Coordinator for navigation, and complete a localisation + VoiceOver audit.

---

## Disclaimer

Built for learning and portfolio use. Rick and Morty is © Adult Swim / Warner Bros. Discovery. Character data from [rickandmortyapi.com](https://rickandmortyapi.com).
