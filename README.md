# FWT Orbit Mobile Application

## Overview
FWT Trace is a mobile application developed by Freewave Technologies to support commodity trading companies in registering farmers, farms, and supply chains to meet sustainability and regulatory requirements such as the European Union Deforestation Regulation (EUDR).  

Designed for field teams working in coffee, cocoa, and other agricultural value chains, FWT Trace enables organizations to collect and manage farmer data, farm polygons, and precise GPS coordinates even in remote areas with limited connectivity.  

### Key Features

- **Site Management**: Create, edit, and manage collection sites
- **Farm Management**: Create, edit, and manage Farm data  with precise GPS coordinates and polygons with area measurements
- **Offline Capability**: Full functionality in areas with limited or no connectivity
- **Data Export/Share**: Export collected data in various (CSV/GeoJson) and share with other users
- **Location Services**: Integrated GPS functionality for precise location tracking
- **Synchronization**: Seamless data sync with remote servers when online
- **Data Restore**: Restore the Data stored on the server

## Getting Started

### Prerequisites

- Android Studio Arctic Fox or later 
- JDK 11 or higher 
- Android SDK API Level 21+ (Android 5.0 or higher)
- Google Play Services for location features 
- Android device or emulator running Android 5.0+

### Installation
1. Clone the repository:
```bash
git https://github.com/agstack/TerraTrac-field-app.git
cd TerraTrac-field-app
```
2. Open the project in Android Studio
3. Sync Gradle files
4. Configure your local.properties file with required API keys
5. Build and run the application

### Environment Setup

Configure development environment:

Set up Android Studio
Install required SDK tools
Configure Android Virtual Device (AVD)


Add required environment variables:
```
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
BASE_URL=your_server_url
```

## Architecture

The application follows Clean Architecture pattern with the following key components::

### Presentation Layer (UI)
- User Interface components
- Key Screens:
    - Site Management
    - Farm Management
    - Export/Share Module

### Business Layer
- Core Business Logic:
    - Site Handler
    - Farm Handler
    - Polygon Calculator
    - Import/Export Logic
    - Share Logic
- Validation Layer:
    - Size Validator
    - Data Validator
    - Duplicate Checker

### Data Layer
- Local Storage:
    - ROOM Database
    - Data Entities (Farms, Collection Sites)
- Core Services:
    - Location Service
    - Sync Service

## Contributing

We welcome contributions to TerraTrac! Please follow these steps:

1. Fork the repository 
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature' `)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please read our CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Acknowledgments

- Google Maps Platform for location services 
- Room Persistence Library 
- Kotlin Coroutines for asynchronous programming 
- Android Architecture Components 
- All contributors who have helped shape TerraTrac

## Support

For support, please:
   - Open an issue in the GitHub repository 
   - Contact our support team at support@tnslabs.atlassian.net
   - Check our documentation

## Project Status

Current Version on Production : 2.36 (2024-10-16)

The project is under active development.

---
*TerraTrac is committed to improving agricultural management through technology.*
