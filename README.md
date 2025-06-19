# 🎣 NAIS Fishing Game

Proyek ini adalah game memancing 2D sederhana untuk platform **iOS**, dikembangkan menggunakan teknologi berikut:

- SpriteKit
- GameplayKit
- Core Haptics
- UIKit
- GameKit

---

## 🌿 Branch Aktif

Semua pengembangan dilakukan melalui branch **fitur terpisah**, dengan basis awal dari cabang `main`:

- `feature/casting-rod`
- `feature/hook-fish`
- `feature/reeling-rod`
- `feature/fish-popup`

🛑 **Jangan coding langsung di `main`.** Gunakan pull request dari branch fitur masing-masing ke `main`.

---

## 📁 Struktur Folder Proyek

```bash
Nais-Fishing/
├── FSM/                      # Game state system (GameplayKit)
├── Logic/                    # Gameplay utama (casting, hook, reeling)
├── Managers/                 # Haptic, audio, dan sistem koordinatif
├── UI/                       # Komponen visual non-scene
├── Scenes/                   # FishingScene.sks + Swift-nya
├── Resources/                # Assets, sound, plist (jika ada)
├── Core/                     # GameKit, Save manager (opsional)
├── GameViewController.swift
└── Assets.xcassets

