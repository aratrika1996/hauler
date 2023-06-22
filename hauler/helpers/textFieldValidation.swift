//
//  textFieldValidation.swift
//  hauler
//
//  Created by Homing Lau on 2023-06-15.
//

import Foundation

enum Fields : Hashable{
    case title
    case desc
    case price
    case cate
    case loca
}

enum validationErrorsTitle : Error{
    case Empty
    case tooShort
    case tooLong
    
    var desc: String{
        switch(self){
        case.Empty:
            return "Empty Title is Not Allowed"
        case.tooShort:
            return "Title lenght should be greater than 5"
        case.tooLong:
            return "Title lenght should be small than 20"
        }
    }
}

enum validationErrorsDesc : Error{
    case Empty
    case tooShort
    case tooLong
    
    var desc: String{
        switch(self){
        case.Empty:
            return "Empty Desc is Not Allowed"
        case.tooShort:
            return "Desc lenght should be greater than 5"
        case.tooLong:
            return "Desc lenght should be small than 100"
        }
    }
}

enum validationErrorsValue : Error{
    case nan
    case negative
    case tooBig
    
    var desc : String{
        switch(self){
        case.nan:
            return "Price should be a number"
        case .negative:
            return "Negative Price is not allowed"
        case .tooBig:
            return "Price should be below 999,999"
        }
    }
}
