//
//  SignUpAuthError.swift
//  hauler
//
//  Created by Aratrika Mukherjee on 2023-05-20.
//

import Foundation

enum SignUpAuthError: Error {
    case userAlreadyExist
    case unknownErr
}

extension SignUpAuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userAlreadyExist:
            return NSLocalizedString("User Already exist", comment: "")
        case .unknownErr:
            return NSLocalizedString("Unknown error. Cannot sign up", comment: "")
        }
    }
}
