//
//  ViewController.swift
//  Demo_ToDoList
//
//  Created by Vimal on 23/06/20.
//  Copyright © 2020 Vimal. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    
    var listArray : [ToDoList] = []
    var list : [ToDoList] = []
    var searchedList : [ToDoList] = []
    
    @IBOutlet weak var toDoListTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var isSearching : Bool {
        get {
            return !(self.searchBar.text?.isEmpty ?? true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateArray()
    }
    
    func updateArray() {
        self.list.removeAll()
        let entity = CoreDataHelper.sharedInstance().getListOfEntityWithName("ToDoList", withPredicate: nil, sortKey: "done", isAscending: true)
        print(entity!.count)
        
        for data in entity as! [NSManagedObject] {
            self.list.append(data as! ToDoList)
            print(list)
        }
        //
        self.toDoListTableView.reloadData()
    }
}
extension ViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isSearching == true {
            return self.searchedList.count
        } else {
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        if self.isSearching == true {
            
            cell.textLabel?.text = searchedList[indexPath.row].title
            cell.detailTextLabel?.text = searchedList[indexPath.row].description
            cell.accessoryType = (searchedList[indexPath.row].done ?? 0) == 1 ? .checkmark : .none
        } else {
            cell.textLabel?.text = list[indexPath.row].title
            cell.detailTextLabel?.text = list[indexPath.row].desc
            let check = list[indexPath.row].done
            if check == 1{
                cell.backgroundColor = .darkGray
            }else{
                cell.backgroundColor = .white
            }
            
            cell.accessoryType = (list[indexPath.row].done ?? 0) == 1 ? .checkmark : .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: nil, message: "Are you sure you want to make changes", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
            
            if self.isSearching == true {
                if let index = self.list.firstIndex(where: { (object) -> Bool in (object.title ?? "" == self.searchedList[indexPath.row].title ?? "") && (object.desc ?? "" == self.searchedList[indexPath.row].desc ?? "") }) {
                    
                    self.list[index].done = true
                    self.updateArray()
                    self.searchBar(self.searchBar, textDidChange: self.searchBar.text ?? "")
                } else {
                    
                    self.searchedList[indexPath.row].done = true
                }
            } else {
                
                if  self.list[indexPath.row].done == true{
                    self.list[indexPath.row].done = false
                }else{
                    self.list[indexPath.row].done = true
                }
                CoreDataHelper.sharedInstance().saveContext()
                
                self.updateArray()
                
            }
            
            self.toDoListTableView.reloadData()
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
extension ViewController : UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.toDoListTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty == false {
            self.searchedList = self.list.filter({ (object) -> Bool in
                let title = object.title?.lowercased() ?? ""
                let desc = object.desc?.lowercased() ?? ""
                let searchText = searchBar.text?.lowercased() ?? ""
                return title.contains(searchText) || desc.contains(searchText)
            })
        }
        
        self.toDoListTableView.reloadData()
    }
}
