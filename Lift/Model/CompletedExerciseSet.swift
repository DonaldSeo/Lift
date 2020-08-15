//
//  CompletedExerciseSet.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-14.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation
import Firebase

struct CompletedExerciseSet {
  
  var key: String
  let name: String?
  let weight: String?
  let reps: String?
  let date: String?
  let ref: DatabaseReference?
  
  init(name: String, key: String = "", weight: String, reps: String, date: String) {
    self.key = key
    self.name = name
    self.ref = nil
    self.weight = weight
    self.reps = reps
    self.date = date
  }
  
  init(snapshot: DataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = "nil"
    weight = snapshotValue["maxWeight"] as! String
    reps = "nil"
    date = snapshotValue["date"] as! String
    ref = snapshot.ref
  }
  
  func toAnyObject() -> Any {
    return [
      "name": name,
    ]
  }
}
