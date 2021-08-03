//
//  TrainingVolume.swift
//  Lift
//
//  Created by Donald Seo on 2020-10-24.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation
import Firebase

struct TrainingVolume {
  var key: String
  let date: String?
  let totalVolume: Int?
  let ref: DatabaseReference?
  
  init(key: String="", date: String, totalVolume: Int) {
    self.key = key
    self.date = date
    self.totalVolume = totalVolume
    self.ref = nil
  }
  
  init(snapshot: DataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    date = snapshotValue["date"] as! String
    totalVolume = snapshotValue["totalVolume"] as! Int
    ref = snapshot.ref
  }
}
