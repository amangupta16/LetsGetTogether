//
//  EventDetailsViewController.swift
//  letsGetTogether
//
//  Created by macbook_user on 11/13/16.
//  Copyright © 2016 Kaustubh. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import Firebase

struct Comment{
    let name : String!
    let comment : String!
}

class EventDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var selectedEvent: Event!
    var selectedEventKey: String?
    var comments = [Comment]()
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var interestedImage: UIImageView!
    @IBOutlet weak var commentInput: UITextField!
    @IBOutlet weak var userComments: UITableView!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var peopleGoingLabel: UILabel!
    
    
    @IBAction func saveComment(_ sender: UIButton) {
        
        let userComment = self.commentInput.text!
        let userName = AppState.sharedInstance.firstName!
        let postComment : [String : AnyObject] = ["userComment" : userComment as AnyObject,
                                                  "userName" : userName as AnyObject]
        
        let databaseRef = FIRDatabase.database().reference()
        let childRef = databaseRef.child("events")
        let childRef1 = childRef.child(selectedEventKey!)
        childRef1.child("comments").childByAutoId().setValue(postComment)
        commentInput.text = ""
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AppState.sharedInstance.interestedEvents.contains((selectedEventKey)!) {
            interestedImage.accessibilityIdentifier = "y"
            self.interestedImage.image = UIImage(named: "interested")
        } else {
            interestedImage.accessibilityIdentifier = "n"
            self.interestedImage.image = UIImage(named: "notInterested")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapInterestedImage))
        interestedImage.addGestureRecognizer(tap)
        interestedImage.isUserInteractionEnabled = true
        
        eventNameLabel.text = selectedEvent.eventName
        descriptionLabel.text = selectedEvent.eventDescription
        dateTimeLabel.text = selectedEvent.dateAndTime
        locationLabel.text = selectedEvent.mapLocation
        createdByLabel.text = selectedEvent.createdBy
        peopleGoingLabel.text = selectedEvent.peopleGoing
        // Do any additional setup after loading the view.
    
        let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(selectedEvent.destLat)!, longitude: CLLocationDegrees(selectedEvent.destLong)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        mapView.addAnnotation(MKPlacemark(coordinate: center))
        
        let databaseRef = FIRDatabase.database().reference()
        let childRef = databaseRef.child("events")
        let childRef1 = childRef.child(selectedEventKey!)
        childRef1.child("comments").queryOrderedByKey().observe(.childAdded, with: {snapshot in
            let value = snapshot.value as? NSDictionary
            let name = value?["userName"] as? String ?? ""
            let comment = value?["userComment"] as? String ?? ""
            self.comments.insert(Comment(name: name, comment: comment), at: 0)
            self.userComments.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CommentTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CommentTableViewCell
        let name = comments[indexPath.row].name
        let comment = comments[indexPath.row].comment
        
        cell.comment?.text = name! + ": " + comment!
        
        return cell
    }
    
    func tapInterestedImage() {
        let databaseRef = FIRDatabase.database().reference()
        
        if self.interestedImage.accessibilityIdentifier == "n" {
            self.interestedImage.image = UIImage(named: "interested")
            self.interestedImage.accessibilityIdentifier = "y"
            AppState.sharedInstance.interestedEvents.append(selectedEventKey!)
            databaseRef.child("users").child(AppState.sharedInstance.uid!).updateChildValues(["interestedEvents": AppState.sharedInstance.interestedEvents])
            databaseRef.child("events").child(selectedEvent.key).updateChildValues(
                [
                    "peopleGoing": String(Int(peopleGoingLabel.text!)! + 1)
                ]
            )
            peopleGoingLabel.text = String(Int(peopleGoingLabel.text!)! + 1)
        }
        else {
            let eventIndex = AppState.sharedInstance.interestedEvents.index(of: selectedEventKey!)
            AppState.sharedInstance.interestedEvents.remove(at: (eventIndex)!)
            databaseRef.child("users").child(AppState.sharedInstance.uid!).updateChildValues(["interestedEvents": AppState.sharedInstance.interestedEvents])
            databaseRef.child("events").child(selectedEvent.key).updateChildValues(
                [
                    "peopleGoing": String(Int(peopleGoingLabel.text!)! - 1)
                ]
            )
            peopleGoingLabel.text = String(Int(peopleGoingLabel.text!)! - 1)
            self.interestedImage.image = UIImage(named: "notInterested")
            self.interestedImage.accessibilityIdentifier = "n"
        }        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
