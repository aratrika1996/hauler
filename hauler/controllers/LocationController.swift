//
//  LocationController.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import Foundation
import CoreLocation
import MapKit
import Contacts


class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate{
    @Published var longitude : Double = 0.0
    @Published var latitude : Double = 0.0
    @Published var ReversedLocation : String = ""{
        didSet{
            guard ReversedLocation != oldValue else{ return }
            self.doForwardGeocoding(address: ReversedLocation, completion: {loc in
                self.longitude = loc.coordinate.longitude
                self.latitude = loc.coordinate.longitude
            })
        }
    }
    
    private let locationManager = CLLocationManager()
    
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
    }
    
    func doReverseGeocoding(location : CLLocation, completionHandler: @escaping(String?, NSError?) -> Void){
        let loc_geocoder = CLGeocoder()
        loc_geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if (error != nil){
                print(#function, "Unable to perform reverse geocoding : \(error?.localizedDescription)")
                
                //completionHandler of doReverseGeocoding()
                completionHandler(nil, error as NSError?)
            }else{
                if let placemarkList = placemarks, let placemark = placemarkList.first {
                    
                    print(#function, "Locality : \(placemark.locality ?? "NA")")
                    print(#function, "country : \(placemark.country ?? "NA")")
                    print(#function, "country code : \(placemark.isoCountryCode ?? "NA")")
                    print(#function, "sub-Locality : \(placemark.subLocality ?? "NA")")
                    print(#function, "Street-level address : \(placemark.thoroughfare ?? "NA")")
                    print(#function, "province : \(placemark.administrativeArea ?? "NA")")
    
                    let postalAddress : String = CNPostalAddressFormatter.string(from: placemark.postalAddress!, style: .mailingAddress)
                    print(#function, "Postal Address : \(postalAddress)")
//                    self.ReversedLocation = postalAddress
                    completionHandler(postalAddress, nil)
                   
                }else{
                    print(#function, "Unable to obtain placemark for reverse geocoding")
                }
            }
        })
    }
    
    func doForwardGeocoding(address : String, completion :  @escaping (CLLocation) -> Void){
        let loc_geocoder = CLGeocoder()
        loc_geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
//            CLPlacemark
            
            if (error != nil){
                print(#function, "Unable to perform forward geocoding : \(error?.localizedDescription)")
            }else{
                if let placemark = placemarks?.first {
                    
                    let obtainedLocation = placemark.location!
                    print(#function, "Obtained location after forward geocoding : \(obtainedLocation)")
                    completion(obtainedLocation)
                    
                }else{
                    print(#function, "Unable to obtain placemark for forward geocoding")
                }
            }
            loc_geocoder.cancelGeocode()
        })
        
    }
    
    func addPinToMap(mapView: MKMapView, coordinates : CLLocationCoordinate2D){
        
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = coordinates
        mapAnnotation.title = "You Parked Here"
        mapView.addAnnotation(mapAnnotation)
    }
}
