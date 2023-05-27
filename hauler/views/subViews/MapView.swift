//
//  MapView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    let location: CLLocation
    let userFlag = MKPointAnnotation()
        
    init(location: CLLocation) {
        self.location = location
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.isZoomEnabled = true
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinate = location.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.setRegion(region, animated: true)
        
        userFlag.coordinate = coordinate
        uiView.addAnnotation(userFlag)
    }
    
    typealias UIViewType = MKMapView
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(location: CLLocation(latitude: 43.6896109, longitude: -79.3889326))
    }
}
