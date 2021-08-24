![swift 5](https://img.shields.io/badge/Swift-5-blue) 
![iOS14.5](https://img.shields.io/badge/iOS-14.5-blue)

# What is RockMap?
RockMap is a map app that allows you to share Boulder and its courses.

<img src="https://user-images.githubusercontent.com/44093643/125480570-590c49fc-9643-42d2-b894-4035c4b742a8.PNG" width="250">　
<img src="https://user-images.githubusercontent.com/44093643/125480595-806e3866-2a0d-47cb-b133-bd870f0d94ac.PNG" width="250">　
<img src="https://user-images.githubusercontent.com/44093643/125480630-23bf1373-ddd8-44ee-abce-769234198d5d.PNG" width="250">
<img src="https://user-images.githubusercontent.com/44093643/125480678-a3cc1762-1beb-4e9f-b98e-a603a3aabc39.PNG" width="250">
<img src="https://user-images.githubusercontent.com/44093643/125480918-ae6ce164-6b50-4fa8-baa3-0464440d63fd.PNG" width="250">

## App Store link
https://apps.apple.com/jp/app/rockmap/id1576276950

## Feature
* Login(using FirebaseUI)
* Search Location of Rocks(MapKit)
* Register rocks, courses, climbing(FireStore)

## Architecture
### Design
* MVVM + Routor

※ Currently I'm replacing an archtecture from MVVM to CleanArchtecture
Before: MVVM + Routor
After: CleanArchtecture(Presentation + Domain + Data)

### UI
* UIKit
* CompositionalLayout
* DiffableDataSource

### Database
* Firestore
* FirebaseStorage
* Cloud Function

* BackEnd of RockMap is here
  * https://github.com/toya108/RockMapFirebase

### Authentication
* FirebaseUI 

### Manage Library
- SPM     

## Data Model

<img src="https://user-images.githubusercontent.com/44093643/119843554-a0b69880-bf42-11eb-970d-dfba516a2e0a.png" width="300">

## Comunication
* If you found a bug, open an issue.
* If you have a feature request, open an issue.

## Licence
MIT license.

