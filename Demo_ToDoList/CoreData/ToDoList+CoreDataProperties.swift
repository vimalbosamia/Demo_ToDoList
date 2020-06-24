//
//  ToDoList+CoreDataProperties.swift
//  Demo_ToDoList
//
//  Created by Vimal on 23/06/20.
//  Copyright © 2020 Vimal. All rights reserved.
//

import Foundation
import CoreData


extension ToDoList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoList> {
        return NSFetchRequest<ToDoList>(entityName: "ToDoList")
    }

    @NSManaged public var desc: String?
    @NSManaged public var title: String?
    @NSManaged public var done : NSNumber?

}
