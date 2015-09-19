//
//  PeopleListViewControllerTests.swift
//  Birthdays
//
//  Created by Dima on 09.09.15.
//  Copyright © 2015 Dominik Hauser. All rights reserved.
//

import UIKit
import XCTest
import Birthdays
import CoreData
import AddressBookUI

class PeopleListViewControllerTests: XCTestCase {
    
    var viewController: PeopleListViewController!
    
    override func setUp() {
        super.setUp()
        
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PeopleListViewController") as! PeopleListViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBarButtonItemsAreSet() {
        let mockDataProvider = MockDataProvider()
        viewController.dataProvider = mockDataProvider
        
        let _ = viewController.view
        
        let rightBarButton = viewController.navigationItem.rightBarButtonItem
        
        XCTAssertNotNil(rightBarButton, "Should not be nil")
        XCTAssertEqual(rightBarButton!.action, Selector("addPerson"), "Action should be addPerson")
    }
    
    func testDataProviderHasTableViewPropertySetAfterLoading() {
        // given
        let mockDataProvider = MockDataProvider()
        viewController.dataProvider = mockDataProvider    // 1
        
        // when
        XCTAssertNil(mockDataProvider.tableView, "Before loading the table view should be nil")  // 2
        let _ = viewController.view    // 3
        
        // then    // 4
        XCTAssertTrue(mockDataProvider.tableView != nil, "The table view should be set")
        XCTAssert(mockDataProvider.tableView === viewController.tableView, "The table view should be set to the table view of the data source")
    }
    
    func testCallsAddPersonOfThePeopleDataSourceAfterAddingAPersion() {
        let mockDataSource = MockDataProvider()
        viewController.dataProvider = mockDataSource
        
        let record: ABRecord = ABPersonCreate().takeRetainedValue()
        ABRecordSetValue(record, kABPersonFirstNameProperty, "TestFirstname", nil)
        ABRecordSetValue(record, kABPersonLastNameProperty, "TestLastname", nil)
        ABRecordSetValue(record, kABPersonBirthdayProperty, NSDate(), nil)
        viewController.peoplePickerNavigationController(ABPeoplePickerNavigationController(), didSelectPerson: record)
        
        XCTAssert(mockDataSource.addPersonGotCalled, "addPerson should have been called")
    }
    
    func testSortingCanBeChanged() {
        // given
        let mockUserDefaults = MockUserDefaults(suiteName: "testing")!
        viewController.userDefaults = mockUserDefaults
        
        // when
        let segmentedControl = UISegmentedControl()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(viewController, action: "changeSorting:", forControlEvents: .ValueChanged)
        segmentedControl.sendActionsForControlEvents(.ValueChanged)
        
        // then
        XCTAssertTrue(mockUserDefaults.sortWasChanged, "Sort value in user defaults should be altered")
    }
    
    func testFetchingPeopleFromAPICallsAddPeople() {
        // given
        let mockDataProvider = MockDataProvider()
        viewController.dataProvider = mockDataProvider
        
        let mockCommunicator = MockAPICommunicator()
        mockCommunicator.allPersonInfo = [PersonInfo(firstName: "firstname", lastName: "lastname", birthday: NSDate())]
        viewController.communicator = mockCommunicator
        
        // when
        viewController.fetchPeopleFromAPI()
        
        // then
        XCTAssertTrue(mockDataProvider.addPersonGotCalled, "addPerson should have been called")
    }
    
    func testSendPersonToAPICallsPostPerson() {
        // given
        let mockDataProvider = MockDataProvider()
        viewController.dataProvider = mockDataProvider
        
        let mockCommunicator = MockAPICommunicator()
        viewController.communicator = mockCommunicator
        
        // when
        viewController.sendPersonToAPI(PersonInfo(firstName: "firstname", lastName: "lastname", birthday: NSDate()))
        
        // then
        XCTAssertTrue(mockCommunicator.postPersonGotCalled, "addPerson should have been called")
    }
    
    class MockDataProvider: NSObject, PeopleListDataProviderProtocol {
        
        var addPersonGotCalled = false
        
        var managedObjectContext: NSManagedObjectContext?
        weak var tableView: UITableView!
        func addPerson(personInfo: PersonInfo) { addPersonGotCalled = true }
        func fetch() { }
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell { return UITableViewCell() }
        
    }
    
    class MockUserDefaults: NSUserDefaults {
        var sortWasChanged = false
        override func setInteger(value: Int, forKey defaultName: String) {
            if defaultName == "sort" {
                sortWasChanged = true
            }
        }
    }
    
    class MockAPICommunicator: APICommunicatorProtocol {
        var allPersonInfo = [PersonInfo]()
        var postPersonGotCalled = false
        
        func getPeople() -> (NSError?, [PersonInfo]?) {
            return (nil, allPersonInfo)
        }
        
        func postPerson(personInfo: PersonInfo) -> NSError? {
            postPersonGotCalled = true
            return nil
        }
    }
}
