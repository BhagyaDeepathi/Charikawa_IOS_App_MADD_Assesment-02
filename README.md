
#  Charikawa – Travel Memory App 
## IOS_App_MADD_Assesment-02
*A modern travel diary built with SwiftUI, MapKit, Core Data & CoreML*

---

## ✨ Overview
Charikawa is an elegant and intuitive iOS travel diary application developed for the **SE4041 – Mobile Application Design & Development** coursework.  
Users can pin locations on a map, save travel memories with photos, and browse them in a dedicated gallery.

The app also uses **CoreML (MobileNetV2)** to automatically analyze photos and generate intelligent tags such as *Beach, Mountain, Food, Architecture,* and more.

---

## Screenshots

### Splash Screen
<img width="250" alt="splashscreen" src="https://github.com/user-attachments/assets/7e5a862b-3c9a-488b-8a21-63109af58689" />

### Home Screen 
<img width="250" alt="homescreen" src="https://github.com/user-attachments/assets/b8664214-f055-489f-aed3-e335fd2bbadf" />

### Map View
<img width="250" alt="map" src="https://github.com/user-attachments/assets/e245a4d7-5a2d-46ad-a60a-44c359d11fd1" />

### Add Memory Popup
<img width="250" alt="add memory card pop up after long pressing" src="https://github.com/user-attachments/assets/a83c85c0-6ea6-4d49-8cdf-4bc9ab8196e6" />

### Add Memory 
<img width="250" alt="add memory" src="https://github.com/user-attachments/assets/9848ea02-d6d6-4f21-b1c3-878ff0e905fd" />

### Gallery — Grid View
<img width="250" alt="gallery in grid" src="https://github.com/user-attachments/assets/531d446b-deef-4c54-941d-d5528dc91014" />

### Gallery — Timeline View
<img width="250" alt="gallery in timeline" src="https://github.com/user-attachments/assets/169f9333-f1c1-4612-a161-3753a0d60d10" />

---

## 🎯 Purpose & Target Audience
**Problem:** People forget travel details over time.  
**Solution:** Charikawa gives users a digital map-based way to preserve memories with photos, notes, and locations.

**Target users:**
- Travelers  
- Hikers & explorers  
- Content creators  
- Anyone who wants to log personal experiences  

---

## 🗺️ Key Features

### Map-Based Memory Creation
- Long-press anywhere on the map to add a memory  
- Custom pin annotations  
- Reverse-geocoding for location names  
- Search bar for global place lookup  

### Memory Details
- Add a title, notes, and photo  
- Auto-generated AI tag (CoreML)  
- Edit or delete memories  
- Stores created date  

### Memory Gallery
- Clean card layout  
- Tap a memory to jump to its pinned map location  
- Smooth transitions & animations

 ### Share Memories  
- Each saved memory can be exported.  
- Users can share their travel memories through social apps, messages, or cloud platforms.

### CoreML Photo Tagging
- MobileNetV2 auto-classifies the photo  
- Tag stored in Core Data  
- Tag can be manually edited   

### Advanced UI & UX
- Custom animations  
- Custom map markers  
- Gradient backgrounds  
- Responsive layouts  

### Core Data Persistence
- Stores title, description, image, coordinates, date, and AI tag  

---

## 🛠️ Tech Stack

| Technology       | Usage                             |
|------------------|-----------------------------------|
| SwiftUI          | UI development                    |
| MapKit           | Maps & geolocation                |
| Core Data        | Local database                    |
| CoreML + Vision  | Image classification              |
| PhotosUI         | Image picker                      |
| CoreLocation     | Location & geocoding              |
| NavigationStack  | App navigation                    |

---

## 🚀 How to Build & Run

1. Clone or download the repository  
2. Open **Charikawa.xcodeproj** in Xcode  

**Requirements:**
- Xcode 15+
- iOS 17+ deployment

**Run on:**
- iOS Simulator  
- Physical device (Developer account required)

**Permissions required:**
- Location access  
- Photos access  

---

## Testing & Debugging
Includes:
- Basic Unit Tests  
- UI Tests for navigation and memory CRUD  
- Manual user acceptance testing  

Debugging:
- MapKit with simulator location  
- Core Data with mock data  

---

## 📁 Project Structure

Charikawa

┣ 📂 Models

┣ 📂 Views

┣ 📂 ViewModels

┣ 📂 CoreData

┣ 📂 Helpers

┣ 📂 ML

┣ 📂 Assets.xcassets

┗ App.swift


---

## AI-Assisted Development Notes
**Tools Used:**  
- ChatGPT  

**How AI Assisted:**
- Generated SwiftUI components  
- Guided Core Data structure  
- Provided MapKit examples  
- Created CoreML integration prompts  
- Helped fix UI layout bugs  
- Generated documentation sections  

---

## Design Decisions
- MapKit for a natural travel experience  
- Core Data for offline storage  
- CoreML for emerging technology integration  
- SwiftUI for clean, reactive UI  

---

## Future Enhancements
- CloudKit sync  
- Trip folders / categories  
- Offline map support  

---

## Author
**Bhagya Deepathi Pathirana — IT22306890**

---

## License
This project is academic coursework and is **not licensed for commercial use**.


