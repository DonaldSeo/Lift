//
//  ExerciseListVC.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-07.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation
import UIKit

class ExerciseListVC: UIViewController {
  
  var selectedCategoryId: Int?
  var selectedCategoryName: String = ""
  var exerciseList: [Exercise] = []
  
  
  @IBOutlet weak var exerciseTableView: UITableView!
  @IBOutlet weak var categoryLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    categoryLabel.text = selectedCategoryName
    exerciseTableView.delegate = self
    exerciseTableView.dataSource = self
    getExerciseListFromCategory()
    
  }
  
  func getExerciseListFromCategory() {
    Networking.sharedInstance.getExerciseFromCategory(categoryId: selectedCategoryId!) { exerciseList in
      DispatchQueue.main.async {
        self.exerciseList = exerciseList
        self.exerciseTableView.reloadData()
      }
      
    }
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
  
  
}
