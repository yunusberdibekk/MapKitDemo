//
//  VeriDetayViewController.swift
//  MapApp
//
//  Created by Yunus Emre Berdibek on 14.03.2023.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class VeriDetayViewController: UIViewController {
    
    @IBOutlet weak var labelMekanYorum: UILabel!
    @IBOutlet weak var labelMekanAdi: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let context = appDelegate.persistentContainer.viewContext
    var locationManager = CLLocationManager()
    
    var mekan:Mekanlar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() //konum için kullanıcıdan izin alındı
        locationManager.startUpdatingLocation()
        
        if let m = mekan {
            labelMekanAdi.text = m.mekan_isim
            labelMekanYorum.text = m.mekan_yorum
            
            annotationEkle(m: m)
        }
        
    }
    
    func annotationEkle(m:Mekanlar) {
        let annotation = MKPointAnnotation()
        annotation.title = m.mekan_isim
        annotation.subtitle = m.mekan_yorum
        let coordinate = CLLocationCoordinate2D(latitude: m.mekan_enlem, longitude: m.mekan_boylam)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        locationManager.stopUpdatingLocation()
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func silButonAction(_ sender: Any) {
        veriSil()
    }
    
    func veriSil(){
        
        if let m = mekan {
            
            let alertController = UIAlertController(title: "!!Dikkat!!", message: "Veriyi silmek istediğinize emin misiniz ? Bu işlem geri döndürülemez !!", preferredStyle: .alert)
            
            let iptalActionButton = UIAlertAction(title: "İptal Et", style: .cancel){
                action in
                
                print("İptal Et.")
            }
            alertController.addAction(iptalActionButton)
            
            let silActionButton = UIAlertAction(title: "Sil", style: .destructive){
                action in
                
                self.context.delete(m)
                appDelegate.saveContext()
            }
            alertController.addAction(silActionButton)
            
            self.present(alertController, animated: true)
        }
    }
    
    
}

extension VeriDetayViewController: MKMapViewDelegate, CLLocationManagerDelegate{
    
    //Annotation içinde bulunan info butonu oluşturuluyor.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            return nil
        }
        
        let annotationId = "annotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId)
        
        if pinView == nil {
            
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            
            pinView?.canShowCallout = true //annotasyon ekstra bir şey gösterebilir mi
            pinView?.tintColor = .blue
            
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    //İnfo butonuna tıklanında yapılacak işlemler.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let m = mekan {
            
            let requestLocation = CLLocation(latitude: m.mekan_enlem, longitude: m.mekan_boylam)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) {(placemarkDizisi, hata) in
                
                if let placemarks = placemarkDizisi{
                    if placemarks.count > 0 {
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: yeniPlacemark)
                        item.name = m.mekan_isim
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
        
    }
    
    
}
