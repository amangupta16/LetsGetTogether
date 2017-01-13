//
//  EventsListTableViewController.swift
//  iOS-project-16
//
//  Created by macbook_user on 10/29/16.
//  Copyright © 2016 Kaustubh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation
import Foundation

class EventsListTableViewController: UITableViewController, CLLocationManagerDelegate {

    var events = [Event]()
    var ref: FIRDatabaseReference!
    var remoteConfig: FIRRemoteConfig!
    var dataStorage: UserDefaults?
    var locationManager = CLLocationManager()
    var locationCount: Int?
    var currentLocation: CLLocation?

    override func viewDidAppear(_ animated: Bool) {
        //events = NSKeyedUnarchiver.unarchiveObject(with: dataStorage?.object(forKey: "event") as! Data) as! [Event]
        //tableView.reloadData()
        locationCount = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationCount = 1
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last! as CLLocation
        locationManager.stopUpdatingLocation()
        
        if(locationCount! > 1){
            return
        }
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("events").queryOrderedByKey().observe(.childAdded, with: {snapshot in
            let value = snapshot.value as? NSDictionary
            
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
            let destDistance = self.currentLocation?.distance(from: CLLocation(latitude: CLLocationDegrees(destLat)!, longitude: CLLocationDegrees(destLong)! ))
            
            self.events.insert(Event(name: eventName, description: eventDescription, dateAndTime: eventDateAndTime, mapLocation: eventLocation, maxCount: eventMaxPeople, distance: String(Int(destDistance!)/1000), dLat: destLat, dLong: destLong, key: snapshot.key, createdBy: createdBy, peopleGoing: peopleGoing, uid: uid), at: 0)
            self.tableView.reloadData()
        })
        databaseRef.child("events").queryOrderedByKey().observe(.childChanged, with: {snapshot in
            let value = snapshot.value as? NSDictionary
            for (index, event) in self.events.enumerated() {
                if event.key == snapshot.key {
                    event.eventName = value?["eventName"] as? String ?? ""
                    event.mapLocation = value?["eventLocation"] as? String ?? ""
                    event.eventDescription = value?["eventDescription"] as? String ?? ""
                    event.dateAndTime = value?["eventDateAndTime"] as? String ?? ""
                    event.maxCount = value?["eventMaxPeople"] as? String ?? ""
                    event.destLat = value?["destLat"] as? String ?? ""
                    event.destLong = value?["destLong"] as? String ?? ""
                    event.peopleGoing = value?["peopleGoing"] as? String ?? ""
                    event.createdBy = value?["createdBy"] as? String ?? ""
                }
            }
            self.tableView.reloadData()
        })
        databaseRef.child("events").queryOrderedByKey().observe(.childRemoved, with: {snapshot in
            var deletedEventIndex: Int?
            for (index, event) in self.events.enumerated() {
                if event.key == snapshot.key {
                    deletedEventIndex = index
                }
            }
            self.events.remove(at: deletedEventIndex!)
            self.tableView.reloadData()
        })
        locationCount = locationCount! + 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "EventTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EventTableViewCell
        // Configure the cell...
        cell.eventName.text = events[indexPath.row].eventName
        cell.eventLocation.text = events[indexPath.row].mapLocation
        cell.eventDateTime.text = events[indexPath.row].dateAndTime
        cell.eventDistance.text = events[indexPath.row].eventDistance + " Kms away"
        return cell
    }
    
    @IBAction func Logout(_ sender: UIBarButtonItem) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailsController = segue.destination as! EventDetailsViewController
        let indexPath = tableView.indexPathForSelectedRow
        let selectedEvent = events[(indexPath?.row)!]
        detailsController.selectedEvent = selectedEvent
        detailsController.selectedEventKey = selectedEvent.key
        print(selectedEvent);
    }
}
