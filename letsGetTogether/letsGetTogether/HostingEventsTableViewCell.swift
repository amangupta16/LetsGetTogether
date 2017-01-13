//
//  HostingEventsTableViewCell.swift
//  letsGetTogether
//
//  Created by macbook_user on 11/25/16.
//  Copyright © 2016 Kaustubh. All rights reserved.
//

import UIKit
import Firebase

class HostingEventsTableViewCell: UITableViewCell {

    var editableEvents = [Event]()
    var hostingEventsTable: UITableView?
    var tableReference: MyEventsViewController?
    @IBOutlet weak var deleteEvent: UIButton!
    @IBOutlet weak var editEvent: UIButton!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventDateTimeLabel: UILabel!
    
    @IBAction func deleteEventClick(_ sender: UIButton) {
        let deletedEvent: Event?
        var deletedEventIndexFromAll: Int?
        deletedEvent = self.tableReference?.myHostedEvents.remove(at: sender.tag)
        self.tableReference?.hostingEventsTable.reloadData()
        for (index,event) in (self.tableReference?.allEvents.enumerated())! {
            if event.key == deletedEvent?.key{
                deletedEventIndexFromAll = index
            }
        }
        self.tableReference?.allEvents.remove(at: deletedEventIndexFromAll!)
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("events").updateChildValues([(deletedEvent?.key)! : NSNull()])
        
    }
    
    @IBAction func editEventClicked(_ sender: UIButton) {
        print("Edit clicked")
        for (index,event) in (self.tableReference?.myHostedEvents.enumerated())! {
            if index == sender.tag {
                AppState.sharedInstance.eventToEdit = event
                AppState.sharedInstance.editMode = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
