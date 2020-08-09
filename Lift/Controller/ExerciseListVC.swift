//
//  ExerciseListVC.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-07.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ExerciseListVC: UIViewController {
  
  var selectedCategoryId: Int?
  var selectedCategoryName: String = ""
  var exerciseList: [Exercise] = []
  var user: User!
  //Firebase ref
  let rootReference = Database.database().reference()
//  let userRef: DatabaseReference? = nil
//  let userWorkoutRef: DatabaseReference? = nil

  
  @IBOutlet weak var exerciseTableView: UITableView!
  @IBOutlet weak var titleBar: UINavigationBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    getCurrentUser()
//
//    let userRef = rootReference.child("user")
//    let userWorkoutRef = userRef.child("workout-list")
    
    titleBar.topItem?.title = selectedCategoryName
    exerciseTableView.delegate = self
    exerciseTableView.dataSource = self
    getExerciseListFromCategory()
    
  }
  
  func getCurrentUser() {
    
    if let authData = Auth.auth().currentUser {
      user = User(uid: authData.uid, email: authData.email!)
    }
  }
  
  func getExerciseListFromCategory() {
    Networking.sharedInstance.getExerciseFromCategory(categoryId: selectedCategoryId!) { exerciseList in
      DispatchQueue.main.async {
        self.exerciseList = exerciseList
        self.exerciseTableView.reloadData()
        print(self.exerciseList)
      }
      
    }
  }
  
  func addExerciseToWorkoutPlan(at indexPath: IndexPath) {
    // TODO: - update firebase workout list with selected exercise
    let exercise : [String: Any] = ["name" : exerciseList[indexPath.row].name]
    let userWorkoutRef = rootReference.child("Workout").child(user.uid).child("List").childByAutoId()
//    let userWorkoutRef = rootReference.child("Workout-List/\(user.uid)/name")
    userWorkoutRef.setValue(exercise)
  }
  
}

extension ExerciseListVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    exerciseList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath)
    cell.textLabel?.text = exerciseList[indexPath.row].name
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // here call addExerciseToWorkoutPlan()
    
    addExerciseToWorkoutPlan(at: indexPath)
    print("user uid is \(user.uid)")
  }
  
  
}
