//
//  ViewController.swift
//  Notes
//
//  Created by İbrahim Bayram on 4.12.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    var notDizisi = [String]()
    var idDizisi = [UUID]()
    var secilenNot = ""
    var secilenUUID : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.orange]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        verileriAl()
        
      
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = notDizisi[indexPath.row]
        cell.textLabel?.textColor = .orange
        cell.backgroundColor = .black
        cell.textLabel?.font = UIFont.init(name: "Helvetica", size: 20)
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notDizisi.count
    }
    @objc func addButtonClicked() {
        secilenNot = ""
        secilenUUID = nil
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    @objc func verileriAl() {
        notDizisi.removeAll(keepingCapacity: false)
        idDizisi.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let sonuclar = try context.fetch(fetchRequest)
            if sonuclar.count > 0 {
                for sonuc in sonuclar as! [NSManagedObject] {
                    if let not = sonuc.value(forKey: "title") as? String{
                        notDizisi.append(not)
                    }
                    if let uuid = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(uuid)
                    }
                }
                self.tableView.reloadData()
            }
        }catch {
            print("veri çekme başarısız")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name("veriGirildi"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenNot = notDizisi[indexPath.row]
        secilenUUID = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destVC = segue.destination as! DetailViewController
            destVC.secilenNotBaslik = secilenNot
            destVC.secilenNotUUID = secilenUUID
        }
    }
    func tableView(_ tableView: UITableView,commit  editingStyle: UITableViewCell.EditingStyle ,forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            let uuidString = idDizisi[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0 {
                    for sonuc in sonuclar as! [NSManagedObject] {
                        if let id = sonuc.value(forKey: "id") as? UUID {
                            if id == idDizisi[indexPath.row] {
                                context.delete(sonuc)
                                idDizisi.remove(at: indexPath.row)
                                notDizisi.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                }catch {
                                    
                                }
                                break
                            }
                        }
                    }
                }
            }catch {
                print("hata var")
            }
        }
    }
    
    



}

