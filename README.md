# Introduction

HAULER is an iOS mobile app built using SwiftUI that provides users with a convenient marketplace platform for buying and selling products. The app incorporates essential features such as product listings, user profiles, messaging capabilities, location services, and push notifications. By leveraging the power of Firebase, the app ensures seamless data management, real-time communication, and secure user authentication.

## Overview

This document aims to overview HAULER, introducing its purpose, core features, user flow, and the technologies employed to develop the app. It serves as a comprehensive reference guide for developers, designers, and stakeholders involved in the development and understanding of the HAULER marketplace app.

HAULER is designed to create an interactive and efficient platform where users can effortlessly buy and sell a wide range of products. With a user-friendly interface and robust functionality, HAULER connects buyers and sellers, streamlines transactions, and enhances the overall user experience. The app leverages advanced technologies, including camera integration, location services, and push notifications, to offer a comprehensive marketplace solution.

# Features

## Done
All preliminary features are done in the current version of hauler.

### Product Search
Users can easily search for products available on the app based on keywords or categories.
  
![ezgif com-video-to-gif (1)](https://github.com/m-mraisi/hauler/assets/34162216/45f04b3c-27ad-4482-8ba5-b3a91860431b)

Usage Guide:
1. On the main page, type in the product name as a search keyword.
2. Select a category tab as a filter.
3. press the delete button at the end of the search bar to clear the keyword.

### Messaging
HAULER enables users to communicate with each other through an in-app messaging system, facilitating inquiries about products and negotiations.

![Simulator Screen Recording - iPhone 14 Pro Max - 2023-06-27 at 21 21 09](https://github.com/m-mraisi/hauler/assets/34162216/c5b22f4c-35fa-4245-83d5-9c047aed79dd)

Usage Guide:
1. Start a new chat on the product detail page, press the mail button, and enter the message.
2. Then the user will be redirected to the chat page.
3. enter a message and press send button to chat.
4. The chat tab badge will be indicating on receiving new messages.

### Post History
Users can access a screen that displays their own listings and their respective statuses.

![ezgif com-crop](https://github.com/m-mraisi/hauler/assets/34162216/56007ff6-bb88-4c1f-af8d-34254d05e290)

Usage Guide:
1. On the user listing page, users can view all listings made by themselves.
2. by tabbing "mark as sold" and "mark as available", the listing status will be switched between the two states.
3. details of the listing can also be modified on this page.

### Profile Management
Users have a dedicated profile screen where they can manage their personal information, such as name, email, and phone number.

![ezgif com-video-to-gif (5)](https://github.com/m-mraisi/hauler/assets/34162216/e9ef7798-b180-454b-9d8f-b9325a692e7a)

Usage Guide:
1. On the user profile page, user can edit their preference such as address, phone number, and nickname.
2. Make changes as needed, and then save the modifications by pressing save.

### Favorites
Users can mark products as favorites.

![ezgif com-video-to-gif (6)](https://github.com/m-mraisi/hauler/assets/34162216/caf806a0-a2f9-4a85-8aa0-7ba2f5e1986f)

User Guide:
1. On the product detail page, listings can be saved into a list by pressing the heart button.
2. Those saved listings can be reviewed on the favorited product page which can be reached by pressing the middle button on the top right bar.
3. Saved listing can be deleted on the favorited product page individually (by heart button) or all at once (delete all button).

### In-app notifications
Users can follow specific sellers to receive updates and notifications about their listings.

![ezgif com-video-to-gif (4)](https://github.com/m-mraisi/hauler/assets/34162216/c57f6b9f-9ffd-4f3f-b885-c8b10cc1cf74)

User Guide:
1. The number of notifications received will be shown on the right button on the top right bar.
2. By pressing that button, details of the notifications will be revealed.
3. By pressing the new listing notification, users will be navigated to the product detail page regarding that listing.


### Following and Personalized Feeds
Users can view a customized feed of products from sellers they follow or explore the general marketplace.

![ezgif com-video-to-gif (3)](https://github.com/m-mraisi/hauler/assets/34162216/b3153b2b-33e7-40a0-b71f-63165106580d)

User Guide:
1. On the user profile page, users can be saved into a list by pressing the following button.
2. Those saved user's profiles can be reviewed on the following page which can be reached by pressing the left button on the top right bar.
3. Followed can be deleted on the following page individually by pressing the unfollow button.

# Technologies Used

HAULER utilizes various technologies to deliver its functionalities effectively. This section provides an overview of the key technologies employed in the development of the app, including:

- SwiftUI: The app's user interface is built using SwiftUI, Apple's modern declarative framework for creating user interfaces across all Apple platforms.
- Firebase: HAULER leverages Firebase for its backend infrastructure, offering real-time database management, user authentication, and secure data storage.
- Camera Integration: The app integrates with the device's camera capabilities to allow users to capture product photos directly within the app.
- Location Services: HAULER utilizes location services to provide users with location-based features such as address management, distance-based search, and meetup options.
  -Push Notifications: The app incorporates push notifications to keep users informed about updates, new listings, messages, and other relevant activities within the marketplace.

# Library / Source Code / Resources

## Material design like text field by Nikita Lazarev-Zubov

https://lazarevzubov.medium.com/material-design-like-text-field-with-swiftui-d50d299da3b

### Demo

![](https://miro.medium.com/v2/resize:fit:1200/1*v3SL9xVdLSePwqB5oWqJzQ.gif)

### OurApp

![ezgif com-video-to-gif (2)](https://github.com/m-mraisi/hauler/assets/34162216/bd038be4-c1de-4aeb-b6e3-b2f45b3de920)

### Usage

Detect if the the field is editing, then reset other field focus

```
@State private var isTitleEditing : Bool = false{
        didSet{
            guard isTitleEditing != oldValue else {return}
            if(isTitleEditing){isDescEditing = false; isValueEditing = false}
        }
    }
```

Change the hint text after validation

```
@State var titleValid = true {
       didSet {
           listingTitleHint = titleValid ? "Hint 1" : "Error 1"
       }
     }
```

title and hint strings

```
@State private var listingTitle : String = ""
@State private var listingTitleHint = "Hint 1"
```

the view, inputting all the paras, because this block is written before the .focused appear, so ontap = onfocus.

```
MaterialDesignTextField($listingTitle, placeholder: "Title", hint: $listingTitleHint, editing: $isTitleEditing, valid: $titleValid)
.focused($focusedField, equals: .some(.title))
.onTapGesture {
    isTitleEditing = true
}
```

validation func

```
func validateTitle(){
        let copy = self.listingTitle
        if copy.isEmpty{
            self.titleValid = false
            self.listingTitleHint = validationErrorsTitle.Empty.desc
            return
        }
        if copy.count < 5{
            self.titleValid = false
            self.listingTitleHint = validationErrorsTitle.tooShort.desc
            return
        }
        if copy.count > 20{
            self.titleValid = false
            self.listingTitleHint = validationErrorsTitle.tooLong.desc
            return
        }
        self.titleValid = true
}
```

## Expandable Text by n3d1117

https://github.com/n3d1117/ExpandableText/blob/main/Sources/ExpandableText/ExpandableText%2BModifiers.swift

### Our App

![ezgif com-video-to-gif](https://github.com/m-mraisi/hauler/assets/34162216/f6ccfa64-8941-403d-bb94-9eaf0eacecff)

### Usage

```
ExpandableText("\(listing.desc)")
  .font(.body)
  .foregroundColor(.gray)
  .lineLimit(3)
  .moreButtonText("More detailed")
  .moreButtonColor(Color("HaulerOrange"))
  .lessButtonText("less")
  .expandAnimation(.default)
  .trimMultipleNewlinesWhenTruncated(true)
```

## Searchable (IOS built-In Feature)

### Our App

![ezgif com-video-to-gif (1)](https://github.com/m-mraisi/hauler/assets/34162216/45f04b3c-27ad-4482-8ba5-b3a91860431b)

### Usage

In Controller (Observable Obj)

```
@Published var searchText: String = ""
@Published var listingsList = [Listing]()
@Published var selectedTokens : [ListingCategory] = []
@Published var suggestedTokens : [ListingCategory] = ListingCategory.allCases


 var filteredList: [Listing]{
        var list = self.listingsList
        if(selectedTokens.count > 0){
            for token in selectedTokens {
                list = list.filter{$0.category.containsTag(cat: token)}
            }
        }
        if(searchText.count > 0){
            list = list.filter{$0.title.localizedCaseInsensitiveContains(searchText)}
        }
        return list
    }
```

In viewModel

```
NavigationView{
  ForEach(listingController.filteredList, id: \.self.id){item in
    //render items
  }
}
.searchable(text: $listingController.searchText,
                            tokens: $listingController.selectedTokens,
                            suggestedTokens: $listingController.suggestedTokens,
                            token: { token in
                    Label(token.rawValue, systemImage: token.icon())

})
```
