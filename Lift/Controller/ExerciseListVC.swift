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
  var selectedWorkoutDay: Int?
  let workoutDays = ["Unsorted", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
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
  func displayWorkoutDaySelectSheet(completion: @escaping (Int) -> ()) {
    let alert = UIAlertController(title: "Select the workout day", message: "Please Select an Option", preferredStyle: .actionSheet)
    
    for dayIndex in 0..<workoutDays.count {
      alert.addAction(UIAlertAction(title: workoutDays[dayIndex], style: .default , handler:{ _ in
        completion(dayIndex)
      }))
    }
    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
        print("User click Dismiss button")
    }))

    self.present(alert, animated: true, completion: nil)
    
  }
  
  func displaySuccessAlert() {
    let alert = UIAlertController(title: "Success", message: "Exercise Added to your workout list", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        switch action.style{
        case .default:
            print("default")

        case .cancel:
            print("cancel")

        case .destructive:
            print("destructive")

        }}))
      self.present(alert, animated: true, completion: nil)
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

          alert.dismiss(animated: true, completion: nil)
      }
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
  
  func addExerciseToWorkoutPlan(at indexPath: IndexPath, day workoutDaySelection: Int) {
    // TODO: - update firebase workout list with selected exercise
    let exercise : [String: Any] = ["name" : exerciseList[indexPath.row].name, "workoutSection" : workoutDaySelection]
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
//    TODO: ADD actionSheet type alert and let user choose workout day for selected exercise
    displayWorkoutDaySelectSheet() { daySelection in
      self.addExerciseToWorkoutPlan(at: indexPath, day: daySelection)
      self.displaySuccessAlert()
    }


    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  
}

extension ExerciseListVC: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 2
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      if component == 0 {
          return 10
      } else {
          return 100
      }
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      if component == 0 {
          return "First \(row)"
      } else {
          return "Second \(row)"
      }
  }
}
