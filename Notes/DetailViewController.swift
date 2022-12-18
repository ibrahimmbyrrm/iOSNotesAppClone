//
//  DetailViewController.swift
//  Notes
//
//  Created by İbrahim Bayram on 4.12.2022.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var noteTitle: UITextView!
   
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var note: UITextView!
    var secilenNotBaslik = ""
    var secilenNotUUID : UUID?
  
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if secilenNotBaslik != "" {
            saveButton.isEnabled = false
            if let uuidString = secilenNotUUID?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
                
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let baslik = sonuc.value(forKey: "title") as? String{
                                noteTitle.text = baslik
                            }
                            if let nott = sonuc.value(forKey: "subtitle") as? String {
                                note.text = nott
                            }
                        }
                    }
                }catch {
                    print("veri çekme başarısız")
                }
                        
            }
        }else {
            saveButton.isEnabled = true
            note.text = ""
            noteTitle.text = "New Note"
        }
            

        
    }

    @IBAction func faasf(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let not = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context)
        not.setValue(noteTitle.text, forKey: "title")
        not.setValue(note.text, forKey: "subtitle")
        not.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("kaydetme basarili")
        }catch {
            print("kaydetme esnasında hata oluştu")
        }
        NotificationCenter.default.post(name: NSNotification.Name("veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    }
    

    

