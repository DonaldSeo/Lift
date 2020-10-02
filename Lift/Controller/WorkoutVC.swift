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
  var selectedSection: Int?
  let tableviewSections = ["Unsorted", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  
  let defaults = UserDefaults.standard
  
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
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
  @objc func onDidReceiveData(_ notification: Notification)
  {
    workoutTableView.reloadData()
  }

  
  
  @IBAction func customExerciseButtonPressed(_ sender: Any) {
    
    
    let alert = UIAlertController(title: "Custom Exercise", message: "Add your own exericse", preferredStyle: .alert)
    
    let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 110, width: 260, height: 100))
    
    alert.view.addSubview(pickerFrame)
    pickerFrame.dataSource = self
    pickerFrame.delegate = self
    pickerFrame.selectRow(1, inComponent: 0, animated: true)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { action in
      let titleField = alert.textFields![0]
      print("current selected section is \(self.selectedSection)")
      let exercise: [String: Any] = ["name" : titleField.text, "workoutSection" : self.selectedSection]
      let newExerciseRef = self.userWorkoutReference.child(self.currentUser.uid).child("List").childByAutoId()
      newExerciseRef.setValue(exercise)
    }
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default)
    
    alert.addTextField { textTitle in
      textTitle.placeholder = "Exercise Title"
    }
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    var height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.3)
    alert.view.addConstraint(height);
    
    present(alert, animated: true, completion: nil)
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
  
  @IBAction func toggleEditMode(_ sender: UIBarButtonItem) {
    workoutTableView.isEditing.toggle()
    sender.title = sender.title == "Edit" ? "Done" : "Edit"
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
  
  func getExerciseNote(at indexPath: IndexPath) -> String {
    if let workoutNote = defaults.dictionary(forKey: String(indexPath.section)) {
      if let workoutNoteText = workoutNote[String(indexPath.row)] {
        return workoutNoteText as! String
      }
    }
    return "Add Note"
  }
  
  func updateExerciseNote(at indexPath: IndexPath) {
    if var workoutNote = defaults.dictionary(forKey: String(indexPath.section)) {
      workoutNote[String(indexPath.row)] = nil
      defaults.set(workoutNote, forKey: String(indexPath.section))
    }
  }


  
}

// MARK: - prepare segue

extension WorkoutVC {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "GoToExerciseDetail":
      let destinationVC = segue.destination as! ExerciseDetailVC
//      destinationVC.transitioningDelegate = self
      if let indexPath = workoutTableView.indexPathForSelectedRow {
        let matchingSession = userWorkoutSession.filter {$0.section == indexPath.section}
        destinationVC.currentExercise = matchingSession[indexPath.row].name
        destinationVC.selectedCellIndexPath = indexPath
      }
    case "GoToWorkoutCategory":
      _ = segue.destination as! ExerciseCategoryVC
      
    default:
      return
    }
    
  }
}


// MARK: - Tableview Extension
extension WorkoutVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let matchingSection = userWorkoutSession.filter {$0.section == section}
    return matchingSection.count
  }
  func numberOfSections(in tableView: UITableView) -> Int {
    tableviewSections.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
    
    let matchingSession = userWorkoutSession.filter {$0.section == indexPath.section}
    cell.textLabel?.text = matchingSession[indexPath.row].name
    cell.detailTextLabel?.text = getExerciseNote(at: indexPath)
//    cell.detailTextLabel?.text = "hello"
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return tableviewSections[section]
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      print(indexPath.section)
      let matchingSession = userWorkoutSession.filter {$0.section == indexPath.section}
      let workoutItem = matchingSession[indexPath.row]
      userWorkoutReference.child(currentUser.uid).child("List").child(workoutItem.key).setValue(nil)
      //remove at indexPath.row where indexPath.section is current section
//      userWorkoutSession.remove(at: indexPath.row)
      updateExerciseNote(at: indexPath)
      workoutTableView.reloadData()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("indexpath.row \(indexPath.row) and indexpath.section \(indexPath.section)")
    performSegue(withIdentifier: "GoToExerciseDetail", sender: self)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}
extension WorkoutVC: UIPickerViewDelegate, UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    tableviewSections.count
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    tableviewSections[row]
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
    switch row {
    case 0:
      selectedSection = 0
    case 1:
      selectedSection = 1
    case 2:
      selectedSection = 2
    case 3:
      selectedSection = 3
    case 4:
      selectedSection = 4
    case 5:
      selectedSection = 5
    case 6:
      selectedSection = 6
    case 7:
      selectedSection = 7
    default:
      selectedSection = 0
    }
  }
}

extension Notification.Name {
  static let didReceiveData = Notification.Name("didReceiveData")
}
