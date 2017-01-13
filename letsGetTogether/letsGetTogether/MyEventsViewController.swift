//
//  MyEventsViewController.swift
//  iOS-project-16
//
//  Created by macbook_user on 10/31/16.
//  Copyright © 2016 Kaustubh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class MyEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myHostedEvents = [Event]()
    var interestedEvents = [Event]()
    var allEvents = [Event]()
    @IBOutlet weak var hostingEventsTable: UITableView!
    @IBOutlet weak var interestedEventsTable: UITableView!
    
    //Handling My Hosted Events table//
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        if tableView == self.hostingEventsTable {
            count = myHostedEvents.count
        }
        if tableView == self.interestedEventsTable {
            count = interestedEvents.count
        }
        return count!
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // cell reuse id (cells that scroll out of view can be reused)
        let cellReuseIdentifier = "hostingEventCell"
        // create a new cell if needed or reuse an old one
        let cell = self.hostingEventsTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! HostingEventsTableViewCell
        // set the text from the data model
        if tableView == self.hostingEventsTable {
            cell.deleteEvent.tag = indexPath.row
            cell.editEvent.tag = indexPath.row
            cell.eventNameLabel.text = myHostedEvents[indexPath.row].eventName
            cell.eventLocationLabel.text = myHostedEvents[indexPath.row].mapLocation
            cell.eventDateTimeLabel.text = myHostedEvents[indexPath.row].dateAndTime
            cell.tableReference = self
        }
        else {
            cell.deleteEvent.alpha = 0
            cell.editEvent.alpha = 0
            cell.eventNameLabel.text = interestedEvents[indexPath.row].eventName
            cell.eventLocationLabel.text = interestedEvents[indexPath.row].mapLocation
            cell.eventDateTimeLabel.text = interestedEvents[indexPath.row].dateAndTime
        }
        return cell
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let databaseRef = FIRDatabase.database().reference()
        myHostedEvents = []
        interestedEvents = []
        databaseRef.child("events").observe(.childAdded, with: {snapshot in
            let value = snapshot.value as? NSDictionary
            let userID = value?["uid"] as? String ?? ""
            
            let eventName = value?["eventName"] as? String ?? ""
            let eventLocation = value?["eventLocation"] as? String ?? ""
            let eventDescription = value?["eventDescription"] as? String ?? ""
            let eventDateAndTime = value?["eventDateAndTime"] as? String ?? ""
            let eventMaxPeople = value?["eventMaxPeople"] as? String ?? ""
            let destLat = value?["destLat"] as? String ?? ""
            let destLong = value?["destLong"] as? String ?? ""
            let createdBy =  value?["createdBy"] as? String ?? ""
            let peopleGoing = value?["peopleGoing"] as? String ?? ""
            let uid = value?["uid"] as? String ?? ""
            
            self.allEvents.insert(Event(name: eventName, description: eventDescription, dateAndTime: eventDateAndTime, mapLocation: eventLocation, maxCount: eventMaxPeople, distance: "", dLat: destLat, dLong: destLong, key: snapshot.key, createdBy: createdBy, peopleGoing: peopleGoing, uid: uid), at: 0)
            
            if userID == (AppState.sharedInstance.uid)! {
                self.myHostedEvents.insert(Event(name: eventName, description: eventDescription, dateAndTime: eventDateAndTime, mapLocation: eventLocation, maxCount: eventMaxPeople, distance: "", dLat: destLat, dLong: destLong, key: snapshot.key, createdBy: createdBy, peopleGoing: peopleGoing, uid: uid), at: 0)
                self.hostingEventsTable.reloadData()
            }
            
            if AppState.sharedInstance.interestedEvents.contains(snapshot.key) {
                self.interestedEvents.insert(Event(name: eventName, description: eventDescription, dateAndTime: eventDateAndTime, mapLocation: eventLocation, maxCount: eventMaxPeople, distance: "", dLat: destLat, dLong: destLong, key: snapshot.key, createdBy: createdBy, peopleGoing: peopleGoing, uid: uid), at: 0)
            }
            self.interestedEventsTable.reloadData()
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hostingEventsTable.delegate = self
        self.hostingEventsTable.dataSource = self
        self.interestedEventsTable.delegate = self
        self.interestedEventsTable.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
