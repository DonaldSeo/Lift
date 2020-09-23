//
//  UserWorkoutSession.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-07.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation
import Firebase

struct UserWorkoutItem {
  
  let key: String
  let name: String
  let section: Int
  let ref: DatabaseReference?
  
  init(name: String, section: Int, key: String = "") {
    self.key = key
    self.name = name
    self.section = section
    self.ref = nil
  }
  
  init(snapshot: DataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = snapshotValue["name"] as! String
    section = snapshotValue["workoutSection"] as! Int
    ref = snapshot.ref
  }
  
  func toAnyObject() -> Any {
    return [
      "name": name,
    ]
  }
}
