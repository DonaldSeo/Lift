//
//  ExerciseDetailVC.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-11.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation
import UIKit
import ScrollableGraphView
import Firebase

class ExerciseDetailVC: UIViewController {
  
  

  @IBOutlet weak var exerciseTitle: UILabel!
  @IBOutlet weak var graphRenderView: UIView!
  
  @IBOutlet weak var setTableView: UITableView!
  @IBOutlet weak var repsTextField: UITextField!
  @IBOutlet weak var weightTextField: UITextField!
  @IBOutlet weak var addSetButton: UIButton!
  @IBOutlet weak var exerciseNoteTextView: UITextView!
  
  
  private var disabledCellsIndexPath = [IndexPath]()
  var currentExercise = ""
  var completedSet: [CompletedExerciseSet] = []
  var completedPRData: [CompletedExerciseSet] = []
  var currentDayDate: String {
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd"
    let today = dateFormatter.string(from: now)
    return today
  }
  let rootReference = Database.database().reference()
  let userWorkoutReference = Database.database().reference(withPath: "Workout")
  var user: User!
  
  var selectedCellIndexPath: IndexPath?
  let defaults = UserDefaults.standard
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.hideKeyboardWhenTappedAround()
    
    addSetButton.isUserInteractionEnabled = false
    addSetButton.alpha = 0.5
    
    getCurrentUser()
    exerciseTitle.text = currentExercise
    print(selectedCellIndexPath!)
    
    exerciseNoteTextView.delegate = self
//    let workoutNote = defaults.object(forKey: currentExercise) as? [Int : [Int : String]] ?? "Add exercise note (# sets * # reps)"
//    exerciseNoteTextView.text = workoutNote[selectedCellIndexPath!.section][selectedCellIndexPath!.row]
    if let workoutNote = defaults.dictionary(forKey: String(selectedCellIndexPath!.section)) {
      if let workoutNoteText =  workoutNote[String(selectedCellIndexPath!.row)] {
        exerciseNoteTextView.text = workoutNoteText as! String
      }
    } else {
      exerciseNoteTextView.text = "Add exercise note (# sets * # reps)"
      exerciseNoteTextView.textColor = UIColor.lightGray
    }
    
    setTableView.dataSource = self
    setTableView.delegate = self
    
    repsTextField.delegate = self
    weightTextField.delegate = self
    
    let exerciseLogCell = UINib(nibName: "ExerciseLogCell", bundle: nil)
    setTableView.register(exerciseLogCell, forCellReuseIdentifier: "ExerciseLogCell")
//    observePRFirebaseDB()
    
    userWorkoutReference.child(user.uid).child("PR").child("\(self.currentExercise)").observe(.value, with: { snapshot in
      var newGraphData: [CompletedExerciseSet] = []
      for item in snapshot.children {
        let PRdata = CompletedExerciseSet(snapshot: item as! DataSnapshot)
        newGraphData.append(PRdata)
      }
      self.completedPRData = newGraphData
      self.animateGraph()
    })
  }
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    userWorkoutReference.removeAllObservers()
  }
  
  func getCurrentUser() {
    
    if let authData = Auth.auth().currentUser {
      user = User(uid: authData.uid, email: authData.email!)
    }
  }
  @IBAction func exerciseDetailViewDismiss(_ sender: Any) {
    dismiss(animated: true)
  }
  
  @IBAction func addSetButtonPressed(_ sender: Any) {
    if let weightText = weightTextField?.text, let repsText = repsTextField?.text {
      let finishedExercise = CompletedExerciseSet(name: "\(currentExercise)", weight: weightText, reps: repsText, date: currentDayDate)
      completedSet.append(finishedExercise)
      setTableView.reloadData()
    }
  }
  
  func addPRsetButton(at indexPath: IndexPath) {
  
    let PRexerciseSet: [String: Any] = ["maxWeight" : completedSet[indexPath.row].weight, "date": completedSet[indexPath.row].date]
    let userPRWorkoutRef = rootReference.child("Workout").child(user.uid).child("PR").child("\(currentExercise)").childByAutoId()
    userPRWorkoutRef.setValue(PRexerciseSet)
    completedSet[indexPath.row].key = userPRWorkoutRef.key!
  }
   
  func animateGraph() {
    let graphView = ScrollableGraphView(frame: graphRenderView.bounds, dataSource: self)
    
    // Setup the plot
    let barPlot = BarPlot(identifier: "bar")

    barPlot.barWidth = 25
    barPlot.barLineWidth = 1
    barPlot.barLineColor = UIColor(rgb: 0x777777)
    barPlot.barColor = UIColor(rgb: 0x555555)
    
    barPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
    barPlot.animationDuration = 1.5
    
    
    // Setup the reference lines
    let referenceLines = ReferenceLines()

    referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 12)
    referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
    referenceLines.referenceLineLabelColor = UIColor.white
    
    referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)

    // Setup the graph
    graphView.backgroundFillColor = UIColor(rgb: 0x333333)

    graphView.shouldAnimateOnStartup = true

    graphView.rangeMax = 600
//    graphView.shouldAdaptRange = true
    graphView.rangeMin = 0

    // Add everything
    graphView.addPlot(plot: barPlot)
    graphView.addReferenceLines(referenceLines: referenceLines)
    
    graphRenderView.addSubview(graphView)
    
  }
}

// MARK: - scrollable graph datasource
extension ExerciseDetailVC: ScrollableGraphViewDataSource {
  func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
    // Return the data for each plot.
    switch(plot.identifier) {
    case "bar":
      if let weightPlot = completedPRData[pointIndex].weight {
        return (weightPlot as NSString).doubleValue
      } else {
        return 0.0
      }
    default:
      return 0
    }
  }
  
  func label(atIndex pointIndex: Int) -> String {
    if let datePlot = completedPRData[pointIndex].date {
      return datePlot
    } else {
      return "No Data to Plot"
    }
  }
  
  func numberOfPoints() -> Int {
    return completedPRData.count
  }
}

extension ExerciseDetailVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return completedSet.count ?? 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseLogCell") as? ExerciseLogCell else {
      fatalError()
    }
    let finishedExercise = completedSet[indexPath.row]
    cell.setLabel?.text = "Set \(indexPath.row + 1)"
    cell.repsLabel?.text = finishedExercise.reps
    cell.weightLabel?.text = finishedExercise.weight
    return cell
  }
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      if completedSet[indexPath.row].key != "" {
        userWorkoutReference.child(user.uid).child("PR").child("\(currentExercise)").child(completedSet[indexPath.row].key).setValue(nil)
      }
      completedSet.remove(at: indexPath.row)
      tableView.reloadData()
    default:
      return
    }
  }
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//    return !disabledCellsIndexPath.contains(indexPath)
    true
  }
  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let addAction = UIContextualAction(style: .normal, title: "Add PR") { (action, view, actionPerformed:(Bool) -> Void) in
      self.addPRsetButton(at: indexPath)
//      self.disabledCellsIndexPath.append(indexPath)
      actionPerformed(true)
    }
    addAction.backgroundColor = .blue
    return UISwipeActionsConfiguration(actions: [addAction])
  }
}

extension ExerciseDetailVC: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)

    if !text.isEmpty{
        //make isUserInteractionEnabled = true
      addSetButton.isUserInteractionEnabled = true
      addSetButton.alpha = 1.0
    } else {
        //make isUserInteractionEnabled = false
      addSetButton.isUserInteractionEnabled = false
      addSetButton.alpha = 0.5
    }

    return true
  }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ExerciseDetailVC: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      textView.text = nil
      textView.textColor = UIColor.black
    }
  }
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Add exercise note (# sets * # reps)"
      textView.textColor = UIColor.lightGray
    }
    if !textView.text.isEmpty && textView.text != "Add exercise note (# sets * # reps)" {
      var workoutNoteDict = defaults.dictionary(forKey: String(selectedCellIndexPath!.section)) as? [String : String] ?? [String : String]()
      workoutNoteDict.updateValue(textView.text, forKey: String(selectedCellIndexPath!.row))
      defaults.set(workoutNoteDict, forKey: String(selectedCellIndexPath!.section))
      NotificationCenter.default.post(name: .didReceiveData, object: nil)
    }
  }
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
    if text == "\n" {
        textView.resignFirstResponder()
        return false
    }
    // get the current text, or use an empty string if that failed
    let currentText = textView.text ?? ""

    // attempt to read the range they are trying to change, or exit if we can't
    guard let stringRange = Range(range, in: currentText) else { return false }

    // add their new text to the existing text
    let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

    // make sure the result is under 16 characters
    return updatedText.count <= 20
  }
}
