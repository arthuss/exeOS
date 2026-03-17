# Blueprint: exeOS

## Purpose

`exeOS` is the single Flutter codebase for:

- the hosted web app
- the future iOS client

It is not responsible for Android. Existing Android functionality stays in the native Android repo.

## Phase A

1. Productize the repo and remove starter branding
2. Add stable navigation and screen structure
3. Integrate Firebase and Google sign-in on web
4. Consume public catalog feeds from the existing hub
5. Deploy the web app through Firebase App Hosting (`exeos`)

## Later phases

- favorites / owned / entitlements
- web payments
- Apple sign-in
- iOS-specific media flow for Live Photo or wallpaper export
