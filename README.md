# PostsByRxSwift

To display the list of posts retrieved from API.

## Requirements

iOS 14.0+ 
Xcode 15.4+
Swift 5+

## Installation

* Download the project.Unarchive the file
* Open Terminal and navigate to the project directory
* Run the command pod install in your terminal 
* Open xcworkspace file in XCode
* Run the project in any iPhone Simulator. 

## Code Style

This repository is written in swift 5 (latest swift version) , RxSwift and architecture design used is based on MVVM (Model,View,View Model).  

## Why MVVM?

- Separation between the view and model
- Collaboration friendly
- Separated out concerns
- Testability

## Why RxSwift?

- Reactive Programming
- Declarative Coding Style
- Conciseness & Readability of Code Constructions
- Perfect compatibility with MVVM
- Wide support

## Assumptions

* I have assumed a two second delay in login to make it feel like network calling
* I assumed that post view would have two field Title and Body.
* On clicking on single post, the background of selection will change, marking it as favourite. Cliking on it again will unmark it.

## Implementations

* App will try to retrieve the data, In case of success, posts will be shown on the screen, if it fails, Alert will be shown.
* On clicking on every post, the background of selection will change, marking it as favourite. Cliking on it again will unmark it.
* We can see all selected favourite posts in favourite tab as well.
* In case of network failure we are trying to fetch data from realmDB.


