---
name: nativephp-mobile
description: Develops native iOS and Android applications using Laravel and NativePHP. Use when asked to build mobile apps, access device hardware (camera, biometrics, location), or package Laravel apps for app stores.
license: MIT
compatibility: Requires Laravel 11+ and PHP 8.3+.
metadata:
  author: nativephp
  version: "3.0"
---

# NativePHP Mobile Development

Use this skill to build cross-platform mobile applications using PHP and Laravel.

## Quick Start Workflow

Follow these steps to initialize a new mobile project:

1. **Install Package**
   Run: `composer require nativephp/mobile`

2. **Install Scaffold**
   Run: `php artisan native:install`
   This creates configuration files and platform-specific directories.

3. **Run Development Server**
   Run: `php artisan native:run <ios,android>`
   Use the **Jump** companion app to test on devices instantly via QR code without recompiling.

## Requirements

- **Laravel**: 11+
- **PHP**: 8.3+
- **iOS**: Mac with Apple Silicon (M1+), Xcode 16+, CocoaPods.
- **Android**: Android Studio 2024.2.1+, Android SDK API 33+.

## Native API Usage

Access device features using the provided facades.

### Biometrics
```php
use Native\Mobile\Facades\Biometric;

// Check availability
if (Biometric::isAvailable()) {
    Biometric::prompt('Authenticate to continue');
}
```

### Locations
```php
use Native\Mobile\Facades\Geolocation;

$position = Geolocation::getCurrentPosition();
// Returns latitude, longitude, accuracy
```


### Native UI (EDGET)
```php
<x-native::tab-bar>
    <x-native::tab label="Home" icon="home">
        <x-slot:content>
            <!-- Home Content -->
        </x-slot:content>
    </x-native::tab>
    <x-native::tab label="Settings" icon="cog">
        <x-slot:content>
            <!-- Settings Content -->
        </x-slot:content>
    </x-native::tab>
</x-native::tab-bar>
```

## Common Workflows

### Adding a New Feature
1. Create a standard Laravel Controller/View.
2. If device access is needed, inject the Native facade.
3. Test on simulator using `php artisan native:run <androdi,ios>`.
