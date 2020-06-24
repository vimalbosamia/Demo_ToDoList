//
//  AddVC.swift
//  Demo_ToDoList
//
//  Created by Vimal on 23/06/20.
//  Copyright © 2020 Vimal. All rights reserved.
//

import UIKit
import CoreData
class AddVC: UIViewController {

   
    @IBOutlet weak var txtViewDesc: TextView!
    @IBOutlet weak var txtTitle: UITextField!
    var toDoTitle : String?
    var toDoDesc : String?
    var imageData : Data?
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnActionUploadImage(_ sender: Any) {
        
        ImagePicker().pickImage(self){ image in
            self.imageData = image.jpegData(compressionQuality: 1)
        }
    }
    //MARK: - Add Device Action
    @IBAction func btnActionSave(_ sender: Any) {
        if txtTitle.text?.isEmpty ?? true {
            toDoTitle = "Default Title"
        } else {
            toDoTitle = txtTitle.text
        }
        
        if txtTitle.text?.isEmpty ?? true {
            toDoDesc = "This is default description"
        } else {
            toDoDesc = txtTitle.text
        }
        
        let todo = CoreDataHelper.sharedInstance().createEntityWithName("ToDoList", uniqueKey: nil, value: nil) as! ToDoList
        todo.title = toDoTitle
        todo.desc = toDoDesc
        todo.done = 0
        if let data = self.imageData{
            todo.image = data
        }else{
            todo.image = jpegdata
        }
       
        CoreDataHelper.sharedInstance().saveContext()
        self.txtTitle.text = nil
        self.txtViewDesc.text = nil
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnActionCancel(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
   
}
