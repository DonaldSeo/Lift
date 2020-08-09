//
//  ViewController.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-06.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import UIKit

class ExerciseCategoryVC: UIViewController {

  @IBOutlet weak var tableview: UITableView!
  
  var category: [ExerciseCategory] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    tableview.dataSource = self
    tableview.delegate = self
    // Do any additional setup after loading the view.
    getExerciseCategory()
  }
  
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//  {
//    if segue.destination is ExerciseListVC {
//      let vc = segue.destination as? ExerciseListVC
//      if let indexPath = tableview.indexPathForSelectedRow {
//        vc?.selectedCategoryId = category[indexPath.row].id
//      }
//    }
//  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! ExerciseListVC
    
    if let indexPath = tableview.indexPathForSelectedRow {
      destinationVC.selectedCategoryId = category[indexPath.row].id
      destinationVC.selectedCategoryName = category[indexPath.row].name
    }
  }
  
  func getExerciseCategory() {
    Networking.sharedInstance.getCategory { exerciseCategory in
      DispatchQueue.main.async {
        self.category = exerciseCategory
        self.tableview.reloadData()
      }
    }
  }
  func addExerciseToWorkoutPlan() {
    // TODO: -
  }


}

extension ExerciseCategoryVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return category.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    cell.textLabel?.text = category[indexPath.row].name
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // segue to exercise list view
    performSegue(withIdentifier: "GoToExerciseList", sender: self)
  }
  
  
}

