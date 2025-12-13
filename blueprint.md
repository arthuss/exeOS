# Blueprint: Live Wallpaper App (iOS & Web)

## Overview

This document outlines the plan and progress for creating the iOS and web versions of the live wallpaper application using Flutter. The goal is to build a robust, visually appealing, and multi-platform app that mirrors the functionality of the existing Android application.

## Current Plan: Navigation & Web Setup

1.  **Add Navigation:** Implement a clear and scalable navigation structure using the `go_router` package.
2.  **Create Pages:** Set up the basic page structure for the app:
    *   Home Screen
    *   Wallpaper List Screen
    *   Settings Screen
3.  **Web Deployment:** Prepare the app for web deployment to establish a live URL.
4.  **Next Steps:**
    *   Populate the pages with placeholder content.
    *   Hand over the project for local content integration.

## Implemented Features & Style

*   **Project Structure:** Standard Flutter project.
*   **Theme:**
    *   Material 3 enabled (`useMaterial3: true`).
    *   Color scheme generated from a seed color (`Colors.deepPurple`).
    *   Typography managed with `google_fonts` (`Oswald`, `Roboto`, `Open Sans`).
    *   Dark/Light mode support implemented with `provider`.
*   **UI:**
    *   A main screen with a theme toggle.
