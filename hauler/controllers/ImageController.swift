//
//  ImageController.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 22/05/2023.
//

import Foundation
import FirebaseStorage
import UIKit

class ImageController : ObservableObject {
    let storage = Storage.storage()

    func uploadImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = storage.reference()

        // Generate a unique filename for the image
        let filename = UUID().uuidString
        let imageRef = storageRef.child("hauler_images/\(filename).jpg")

        // Convert the image to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            return
        }

        // Upload the image data to the storage reference
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Get the download URL for the uploaded image
                imageRef.downloadURL { url, error in
                    if let url = url {
                        completion(.success(url))
                    } else if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                    }
                }
            }
        }
    }
}
