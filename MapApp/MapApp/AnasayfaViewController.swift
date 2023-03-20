//
//  ViewController.swift
//  MapApp
//
//  Created by Yunus Emre Berdibek on 14.03.2023.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class AnasayfaViewController: UIViewController {
    
    var context = appDelegate.persistentContainer.viewContext
    var mekanListe = [Mekanlar]()
    
    var sonKonum:Double?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tumMekanlariGetir()
    }
    
    func tumMekanlariGetir() {
        mekanListe.removeAll(keepingCapacity: false)
        do {
            mekanListe = try context.fetch(Mekanlar.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Mekanlar getirilirken hata oluştu")
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVeriDetayVC" {
            let indeks = sender as? Int
            let hedefVC = segue.destination as! VeriDetayViewController
            
            if indeks != nil {
                hedefVC.mekan = mekanListe[indeks!]
            } else{
                print("Mekan transferi yaşanırken sorun oluştu.")
            }
        }
    }
    
    @IBAction func ekleButonAction(_ sender: Any) {
        performSegue(withIdentifier: "toVeriEkleVC", sender: nil)
    }
    
}

extension AnasayfaViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mekanListe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mekan = mekanListe[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = mekan.mekan_isim
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toVeriDetayVC", sender: indexPath.row)
    }
    
    
    
}


