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
    // Do any additional setup after loading the view.
    getExerciseCategory()
  }
  
  func getExerciseCategory() {
    Networking.sharedInstance.getExerciseCategory { exerciseCategory in
      DispatchQueue.main.async {
        self.category = exerciseCategory
        self.tableview.reloadData()
      }
    }
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
  
  
}

