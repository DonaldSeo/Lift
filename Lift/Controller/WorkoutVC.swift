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
  

  var userWorkoutSession: [Exercise] = []
  let userWorkoutReference = Database.database().reference(withPath: "user-workout")
//  var userWorkoutPlan: [[Exercise]] = [[]]
  override func viewDidLoad() {
    
//    let rootRef = Database.database().reference()
//    let userWorkoutRef = Database.database().reference(withPath: "user-workout")
  }
}

extension WorkoutVC: UITableViewDataSource, UITableViewDelegate {
//  func numberOfSections(in tableView: UITableView) -> Int {
//    userWorkoutPlan.count
//  }
//
//  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//    <#code#>
//  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    userWorkoutSession.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  
}
