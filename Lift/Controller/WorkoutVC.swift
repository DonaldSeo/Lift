//
//  WorkoutVC.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-07.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class WorkoutVC: UIViewController {
  
  @IBOutlet weak var workoutTableView: UITableView!
  
  var user: User!
  var userWorkoutSession: [UserWorkoutItem] = []
  let userWorkoutReference = Database.database().reference(withPath: "Workout")
//  var userWorkoutPlan: [[Exercise]] = [[]]
  override func viewDidLoad() {
    
    self.workoutTableView.dataSource = self
    self.workoutTableView.delegate = self
    getCurrentUser()
    userWorkoutReference.child(user.uid).child("List").observe(.value, with: { snapshot in
      var newWorkout: [UserWorkoutItem] = []
      for item in snapshot.children {
        let exercise = UserWorkoutItem(snapshot: item as! DataSnapshot)
        newWorkout.append(exercise)
      }
      self.userWorkoutSession = newWorkout
      print(self.userWorkoutSession[0].name)
      self.workoutTableView.reloadData()
    })
  }
  
  
  func getCurrentUser() {
    
    if let authData = Auth.auth().currentUser {
      user = User(uid: authData.uid, email: authData.email!)
    }
  }
}

extension WorkoutVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    userWorkoutSession.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
    cell.textLabel?.text = userWorkoutSession[indexPath.row].name
    return cell
  }
  
  
  
}
