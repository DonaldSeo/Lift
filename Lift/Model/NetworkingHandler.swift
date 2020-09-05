//
//  NetworkingHandler.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-07.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation

class Networking {
  
  static let sharedInstance = Networking()
  
  let exerciseCategoryURL = "https://wger.de/api/v2/exercisecategory/"
  let exerciseListFromCategoryURL = "https://wger.de/api/v2/exercise/?status=2&language=2&category="
  
  
  
  func getCategory(completion: @escaping ([ExerciseCategory]) -> ()) {
    guard let url = URL(string: exerciseCategoryURL) else {
      fatalError()
    }
    URLSession.shared.dataTask(with: url) { data, response, taskError in
      guard let httpResponse = response as? HTTPURLResponse,
        (200..<300).contains(httpResponse.statusCode),
        let data = data else {
          return
      }
      print(String(data: data, encoding: .utf8))
      let decoder = JSONDecoder()
      guard let category = try? decoder.decode(AllCategory.self, from: data) else {
        return
      }
      completion(category.results)
    }.resume()
  }
  
  func getExerciseFromCategory(categoryId: Int, completion: @escaping ([Exercise]) -> ()) {
    guard let url = URL(string: exerciseListFromCategoryURL+"\(categoryId)") else {
      fatalError()
    }
    URLSession.shared.dataTask(with: url) { data, response, taskError in
      guard let httpResponse = response as? HTTPURLResponse,
        (200..<300).contains(httpResponse.statusCode),
        let data = data else {
          return
      }
      let decoder = JSONDecoder()
      guard let exerciseList = try? decoder.decode(AllExercise.self, from: data) else {
        return
      }
      completion(exerciseList.results)
    }.resume()
  }
}
