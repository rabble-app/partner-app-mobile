# Rabble Hub - iOS App

Welcome to Rabble Hub, an iOS app designed to enhance your experience with a variety of features. This document serves as the README for the project, providing essential information about the app, setup instructions, and details about the dependencies used.

## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Dependencies](#dependencies)

## Features

- Onboarding
- Registration
- Getting Started
- Collections
- Deliveries
- QR Scan
- My Teams
- Profile

## Requirements

- iOS 13.0 or later
- Xcode 11.0 or later
- Swift 5.0 or later

## Installation

### CocoaPods

Rabble Hub uses CocoaPods for dependency management. If you do not have CocoaPods installed, you can install it by running:

```bash
sudo gem install cocoapods
```

To install the dependencies, navigate to the project directory and run:
```bash
pod install
```
Open the .xcworkspace file in Xcode to start working on the project.

Ensure your Podfile contains the following pods:
```bash
platform :ios, '13.0'
use_frameworks!

target 'RabbleHub' do
  pod 'DialCountries'
  pod 'EliteOTPField'
  pod 'IQKeyboardManagerSwift'
  pod 'QRCodeReader.swift'
  pod 'Moya'
  pod 'SDWebImage'
  pod 'Toast-Swift'
  pod 'JTAppleCalendar'
  pod 'Branch'
end
```

## Usage
### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/rabble-app/partner-app-mobile
   ```
3. Install the dependencies:
  ```bash
   pod install
  ```
5. Open the project in Xcode:
 ```bash
  open Rabble Hub.xcworkspace
  ```
### Running the App
Select your target device or simulator.
Press Cmd + R or click the Run button in Xcode to build and run the app.

## Dependencies

### DialCountries

* Provides a picker for country dial codes.
* [GitHub Repository](https://github.com/ahmedAlmasri/DialCountries)

### EliteOTPField

* Customizable OTP field for handling one-time passwords.
* [GitHub Repository](https://github.com/Mahmoud3allam/EliteOTPField)

### IQKeyboardManagerSwift

* Manages the keyboard interaction without needing additional code.
* [GitHub Repository](https://github.com/hackiftekhar/IQKeyboardManager)

### QRCodeReader.swift

* A QR code reader component for Swift.
* [GitHub Repository](https://github.com/yannickl/QRCodeReader.swift)

### Moya

* Network abstraction layer for handling API requests.
* [GitHub Repository](https://github.com/Moya/Moya)

### SDWebImage

* Asynchronous image downloader with cache support.
* [GitHub Repository](https://github.com/SDWebImage/SDWebImage)

### Toast-Swift

* Swift extension for displaying toast notifications.
* [GitHub Repository](https://github.com/scalessec/Toast-Swift)

### JTAppleCalendar

* A calendar view for managing dates and events.
* [GitHub Repository](https://github.com/patchthecode/JTAppleCalendar)

### Branch

* Deep linking and attribution SDK for managing links.
* [GitHub Repository](https://github.com/BranchMetrics/ios-branch-deep-linking-attribution)
