# Project

## What This Is

ThingCost — a minimal iOS app that tracks the daily cost of things you own. Add an item (name, price, purchase date), and the app shows how the cost-per-day decreases over time. Designed for viral sharing: users generate beautiful cards showing "my iPhone costs me ₺3.8/day" and share them on Instagram/TikTok stories.

## Core Value

Show the real daily cost of any purchase and make it effortlessly shareable. If scope must shrink, the daily cost calculation + share card must survive.

## Current State

Greenfield — nothing built yet. Project directory created at `/Users/ufuk/Desktop/IOS/ThingCost`.

## Architecture / Key Patterns

- **Platform:** iOS 17+ (SwiftUI, @Observable, SwiftData)
- **Architecture:** MVVM with @Observable (medium complexity, good testability)
- **Persistence:** SwiftData (local, no cloud sync for v1)
- **Notifications:** Local notifications for daily cost milestones
- **Monetization:** Freemium — 3 items free, unlimited via one-time IAP ($2.99)
- **Sharing:** Custom rendered share cards (UIGraphicsImageRenderer)
- **Widgets:** Home screen widget showing top items + daily costs

## Milestone Sequence

- [ ] M001: MVP Launch — Core app with add/view items, daily cost, share cards, widget, IAP
