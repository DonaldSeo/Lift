//
//  Exercise.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-07.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation

struct AllCategory: Codable {
  let results: [ExerciseCategory]
}

struct AllExercise: Codable {
  let results: [Exercise]
}

struct ExerciseCategory: Codable {
  let id: Int
  let name: String
}

struct Exercise: Codable {
  let id: Int
  let status, name: String
  let category: Int
  let muscles, musclesSecondary: [Int]

  enum CodingKeys: String, CodingKey {
    case id, status, name, category, muscles
    case musclesSecondary = "muscles_secondary"
  }
}
