//
//  PeopleListDataProviderTests.swift
//  Birthdays
//
//  Created by Dima on 11.09.15.
//  Copyright © 2015 Dominik Hauser. All rights reserved.
//

import XCTest
import CoreData
import Birthdays

class PeopleListDataProviderTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    var tableView: UITableView!
    
    var testRecord: PersonInfo!
    
    var dataProvider: PeopleListDataProvider!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    
        // 1
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try store = storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        // 2
        dataProvider = PeopleListDataProvider()
        dataProvider.managedObjectContext = managedObjectContext
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PeopleListViewController") as! PeopleListViewController
        viewController.dataProvider = dataProvider
        
        tableView = viewController.tableView
        
        testRecord = PersonInfo(firstName: "TestFirstName", lastName: "TestLastName", birthday: NSDate())
    }


    override func tearDown() {
        managedObjectContext = nil
        
        do {
            try storeCoordinator.removePersistentStore(store)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        super.tearDown()
    }
    
    func testThatStoreIsSetUp() {
        XCTAssertNotNil(store, "no persistent store")
    }
    
    func testOnePersonInThePersistantStoreResultsInOneRow() {
        dataProvider.addPerson(testRecord)
        
        XCTAssertEqual(tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 0), 1, "After adding one person number of rows is not 1")
    }
    
}
