//
//  SignInAuthError.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-05-20.
//

import Foundation

enum SignInAuthError: Error {
    case incorrectPassword
    case invalidEmail
    case accountDoesNotExist
    case unknownErr
}

extension SignInAuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .incorrectPassword:
            return NSLocalizedString("Incorrect Password for this account", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Not a valid email address", comment: "")
        case .accountDoesNotExist:
            return NSLocalizedString("This account does not exist.", comment: "")
        case .unknownErr:
            return NSLocalizedString("Unknown error. Cannot sign in", comment: "")
        }
    }
}
