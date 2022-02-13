![swift 5](https://img.shields.io/badge/Swift-5-blue) 
![iOS15](https://img.shields.io/badge/iOS-15.0-blue)

# What is RockMap?
RockMap is a map app that allows you to share Boulder and its courses.

<img src="https://user-images.githubusercontent.com/44093643/153755303-a09f7b6b-f18a-4860-98e4-c0e09d123bb1.png" width="250">　<img src="https://user-images.githubusercontent.com/44093643/153755307-1faaab5f-64c2-4a29-a5aa-307ee16732dc.png" width="250">　<img src="https://user-images.githubusercontent.com/44093643/153755309-a320548a-cbb4-4822-a35a-48f7d45600db.png" width="250">　<img src="https://user-images.githubusercontent.com/44093643/153755310-ea1b219e-643e-4351-a569-97bbde817c16.png" width="250"> <img src="https://user-images.githubusercontent.com/44093643/153755374-6155b4ab-7911-4b2e-a28b-dcedb8b4e4aa.png" width="250">

## App Store link
https://apps.apple.com/jp/app/rockmap/id1576276950

## Feature
* Login(using FirebaseUI)
* Search rocks, courses and users.
* Search rocks on the map.(MapKit)
* Register rocks, courses, records.(FireStore)

## Architecture
* Presentation(View + ViewModel + Router)
* Domain(UseCase + Mapper + Entity)
* Data(Repository)

### UI
* UIKit
* CompositionalLayout
* DiffableDataSource

Note: Currently I'm replacing UI from UIKit to SwiftUI.

### Database
* Firestore
* FirebaseStorage
* Cloud Function

* BackEnd is here
  * https://github.com/toya108/RockMapFirebase

### Authentication
* FirebaseUI 

### Manage Library
- SwiftPM     

## Data Model

Using the following collections
- users
- rocks 
- courses
 - totalClimbedNumber 
- climbRecords

## Comunication
* If you found a bug, open an issue.
* If you have a feature request, open an issue.

## Licence
MIT license.
