# Introduction

HAULER is an iOS mobile app built using SwiftUI that provides users with a convenient marketplace platform for buying and selling products. The app incorporates essential features such as product listings, user profiles, messaging capabilities, location services, and push notifications. By leveraging the power of Firebase, the app ensures seamless data management, real-time communication, and secure user authentication.

## Overview

This document aims to overview HAULER, introducing its purpose, core features, user flow, and the technologies employed to develop the app. It serves as a comprehensive reference guide for developers, designers, and stakeholders involved in the development and understanding of the HAULER marketplace app.

HAULER is designed to create an interactive and efficient platform where users can effortlessly buy and sell a wide range of products. With a user-friendly interface and robust functionality, HAULER connects buyers and sellers, streamlines transactions, and enhances the overall user experience. The app leverages advanced technologies, including camera integration, location services, and push notifications, to offer a comprehensive marketplace solution.

# Features

- Product Search : Users can easily search for products available on the app based on keywords or categories.

- Address Management : Users can add their addresses or opt for meetups as pick-up locations, providing flexibility for transactions.
- Messaging : HAULER enables users to communicate with each other through an in-app messaging system, facilitating inquiries about products and negotiations.
- Chat Enable/Disable : Users can choose to enable or disable the chat feature as per their preference.
- Favorites and Following : Users can mark products as favorites and follow specific sellers to receive updates and notifications about their listings.
- Personalized Feeds : Users can view a customized feed of products from sellers they follow or explore the general marketplace.
- Profile Management : Users have a dedicated profile screen where they can manage their personal information, such as name, email, and phone number.
- Post History : Users can access a screen that displays their own listings and their respective statuses.

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

# Introduction

Hauler iOS app
Overview
HAULER is an iOS mobile app built using SwiftUI that provides users with a convenient marketplace platform for buying and selling products. The app incorporates essential features such as product listings, user profiles, messaging capabilities, location services, and push notifications. By leveraging the power of Firebase, the app ensures seamless data management, real-time communication, and secure user authentication.

This document aims to overview HAULER, introducing its purpose, core features, user flow, and the technologies employed to develop the app. It serves as a comprehensive reference guide for developers, designers, and stakeholders involved in the development and understanding of the HAULER marketplace app.

HAULER is designed to create an interactive and efficient platform where users can effortlessly buy and sell a wide range of products. With a user-friendly interface and robust functionality, HAULER connects buyers and sellers, streamlines transactions, and enhances the overall user experience. The app leverages advanced technologies, including camera integration, location services, and push notifications, to offer a comprehensive marketplace solution.

# Features

- Product Search : Users can easily search for products available on the app based on keywords or categories.

- Address Management : Users can add their addresses or opt for meetups as pick-up locations, providing flexibility for transactions.
- Messaging : HAULER enables users to communicate with each other through an in-app messaging system, facilitating inquiries about products and negotiations.
- Chat Enable/Disable : Users can choose to enable or disable the chat feature as per their preference.
- Favorites and Following : Users can mark products as favorites and follow specific sellers to receive updates and notifications about their listings.
- Personalized Feeds : Users can view a customized feed of products from sellers they follow or explore the general marketplace.
- Profile Management : Users have a dedicated profile screen where they can manage their personal information, such as name, email, and phone number.
- Post History : Users can access a screen that displays their own listings and their respective statuses.

# Technologies Used

HAULER utilizes various technologies to deliver its functionalities effectively. This section provides an overview of the key technologies employed in the development of the app, including:

- SwiftUI: The app's user interface is built using SwiftUI, Apple's modern declarative framework for creating user interfaces across all Apple platforms.
- Firebase: HAULER leverages Firebase for its backend infrastructure, offering real-time database management, user authentication, and secure data storage.
- Camera Integration: The app integrates with the device's camera capabilities to allow users to capture product photos directly within the app.
- Location Services: HAULER utilizes location services to provide users with location-based features such as address management, distance-based search, and meetup options.
  -Push Notifications: The app incorporates push notifications to keep users informed about updates, new listings, messages, and other relevant activities within the marketplace.
