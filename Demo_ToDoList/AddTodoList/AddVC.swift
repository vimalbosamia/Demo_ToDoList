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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        CoreDataHelper.sharedInstance().saveContext()
        self.txtTitle.text = nil
        self.txtViewDesc.text = nil
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnActionCancel(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
   
}
