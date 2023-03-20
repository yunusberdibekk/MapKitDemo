//
//  VeriEkleViewController.swift
//  MapApp
//
//  Created by Yunus Emre Berdibek on 14.03.2023.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class VeriEkleViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textfieldMekanYorum: UITextField!
    @IBOutlet weak var textfieldMekanIsim: UITextField!
    
    let context = appDelegate.persistentContainer.viewContext
    var locationManager = CLLocationManager()
    
    var secilenEnlem = Double()
    var secilenBoylam = Double()
    
    var lokasyonSecildiMi = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() //konum için kullanıcıdan izin alındı
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3 //basılı tutma süresi
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    //Kullanıcının haritada dokunduğu noktayı bulabiliyoruz
    @objc func konumSec(gestureRecognizer:UILongPressGestureRecognizer  ) {
        
        if gestureRecognizer.state == .began {
            let dokunulanNokta = gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            
            secilenEnlem = dokunulanKoordinat.latitude
            secilenBoylam = dokunulanKoordinat.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title =  textfieldMekanIsim.text
            annotation.subtitle = textfieldMekanYorum.text
            mapView.addAnnotation(annotation)
            lokasyonSecildiMi = true
        }
    }
    
    
    @IBAction func kaydetButonAction(_ sender: Any) {
        
        if let mekanAd = textfieldMekanIsim.text, let mekanYorum = textfieldMekanYorum.text {
            
            if lokasyonSecildiMi {
                veriEkle(mekanAd: mekanAd, mekanYorum: mekanYorum, mekanEnlem: secilenEnlem, mekanBoylam: secilenBoylam, mekanUUID: UUID())
                lokasyonSecildiMi = false
            } else {
                print("Lütfen haritadan lokasyon seçin! ")
            }
        }
    }
    
    func veriEkle(mekanAd:String, mekanYorum:String, mekanEnlem:Double, mekanBoylam:Double, mekanUUID:UUID) {
        let mekan = Mekanlar(context: context)
        mekan.mekan_isim = mekanAd
        mekan.mekan_yorum = mekanYorum
        mekan.mekan_enlem = mekanEnlem
        mekan.mekan_boylam = mekanBoylam
        mekan.mekan_id = mekanUUID
        
        appDelegate.saveContext()
        
    }
    
    
}

extension VeriEkleViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let sonKonum:CLLocation = locations[locations.count-1]
        let location = CLLocationCoordinate2D(latitude: sonKonum.coordinate.latitude, longitude: sonKonum.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }
}
