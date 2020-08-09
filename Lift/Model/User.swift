//
//  User.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-08.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation

struct User {
  
  let uid: String
  let email: String
  
  init(authData: User) {
    uid = authData.uid
    email = authData.email
  }
  
  init(uid: String, email: String) {
    self.uid = uid
    self.email = email
  }
  
}
