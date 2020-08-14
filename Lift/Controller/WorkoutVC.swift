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
  
  let transition = PopAnimator()
  
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
// MARK: - viewcontroller transition animation delegate
extension WorkoutVC: UIViewControllerTransitioningDelegate {
  
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController, source: UIViewController)
      -> UIViewControllerAnimatedTransitioning? {
        guard
      let selectedIndexPathCell = workoutTableView.indexPathForSelectedRow,
      let selectedCell = workoutTableView.cellForRow(at: selectedIndexPathCell),
      let selectedCellSuperview = selectedCell.superview
      else {
        return nil
    }
    
    transition.originFrame = selectedCellSuperview.convert(selectedCell.frame, to: nil)
    transition.originFrame = CGRect(
      x: transition.originFrame.origin.x + 20,
      y: transition.originFrame.origin.y + 20,
      width: transition.originFrame.size.width - 40,
      height: transition.originFrame.size.height - 40
    )
    
    transition.presenting = true
//    selectedCell.shadowView.isHidden = true
    
    return transition
  }
  
  func animationController(forDismissed dismissed: UIViewController)
      -> UIViewControllerAnimatedTransitioning? {
    transition.presenting = false
    return transition
  }


  
}

// MARK: - prepare segue

extension WorkoutVC {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "GoToExerciseDetail":
      let destinationVC = segue.destination as! ExerciseDetailVC
      destinationVC.transitioningDelegate = self
    case "GoToWorkoutCategory":
      let destinationVC = segue.destination as! ExerciseCategoryVC
      
    default:
      return
    }
    
  }
}


// MARK: - Tableview Extension
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "GoToExerciseDetail", sender: self)
  }
  
  
  
}
