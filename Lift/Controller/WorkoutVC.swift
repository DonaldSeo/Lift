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
  
  var currentUser: User!
  var userWorkoutSession: [UserWorkoutItem] = []
  let userWorkoutReference = Database.database().reference(withPath: "Workout")
  var handle: AuthStateDidChangeListenerHandle?
//  var userWorkoutPlan: [[Exercise]] = [[]]
  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    handle = Auth.auth().addStateDidChangeListener({ auth, user in
//      self.currentUser = User(uid: user!.uid, email: user!.email!)
//    })
//  }
  override func viewDidLoad() {
    
    self.workoutTableView.dataSource = self
    self.workoutTableView.delegate = self
    getCurrentUser()
    
    Auth.auth().addStateDidChangeListener { _, user in
      if let user = user {
        self.userWorkoutReference.child(user.uid).child("List").observe(.value) { snapshot in
          var newWorkout: [UserWorkoutItem] = []
          for item in snapshot.children {
            let exercise = UserWorkoutItem(snapshot: item as! DataSnapshot)
            newWorkout.append(exercise)
          }
          self.userWorkoutSession = newWorkout
          //      print(self.userWorkoutSession[0].name)
          self.workoutTableView.reloadData()
        }
      } else {
        //not signed in
        print("not signed in")
      }
    }
//    print("current user is \(user.email) with UID \(user.uid)")
//    userWorkoutReference.child(currentUser.uid).child("List").observe(.value, with: { snapshot in
//      var newWorkout: [UserWorkoutItem] = []
//      for item in snapshot.children {
//        let exercise = UserWorkoutItem(snapshot: item as! DataSnapshot)
//        newWorkout.append(exercise)
//      }
//      self.userWorkoutSession = newWorkout
////      print(self.userWorkoutSession[0].name)
//      self.workoutTableView.reloadData()
//    })
  }
  
  @IBAction func signOutButtonPressed(_ sender: Any) {
    do {
      try Auth.auth().signOut()
    } catch let error as NSError {
      print(error.localizedDescription)
    }
    dismiss(animated: true, completion: nil)
  }
  
  func getCurrentUser() {
    
    if let authData = Auth.auth().currentUser {
      currentUser = User(uid: authData.uid, email: authData.email!)
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
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let workoutItem = userWorkoutSession[indexPath.row]
      userWorkoutReference.child(currentUser.uid).child("List").child(workoutItem.key).setValue(nil)
      userWorkoutSession.remove(at: indexPath.row)
      workoutTableView.reloadData()
    }
  }
  
  
  
}
