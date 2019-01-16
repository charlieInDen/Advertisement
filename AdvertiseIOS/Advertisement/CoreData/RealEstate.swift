//
//  RealEstate.swift
//  Advertisement
//
//  Created by Nishant Sharma on 3/1/19.
//  Copyright © 2019 Personal. All rights reserved.
//
/*
 Summary: We declare all the properties related to the entity with associated type, the property also need to be declared with @NSManaged keyword for the compiler to understand that this property will use Core Data at its backing store.
     We also create a simple function that maps a JSON Dictionary property and assign it to the properties of Film Managed Object.
 */
import CoreData

class RealEstate: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var title: String
    @NSManaged var price: Int
    @NSManaged var address: String
    @NSManaged var url: String
    @NSManaged var favorite: Bool
    
    func update(with result: Item){
        self.id = result.id
        self.title = result.title
        self.price = result.price
        self.address = result.location.address
        self.url = result.images?[0].url ?? ""
        //self.favorite = result.favorite
    }
}
