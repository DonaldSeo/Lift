//
//  ExerciseDetailVC.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-11.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation
import UIKit
import ScrollableGraphView

class ExerciseDetailVC: UIViewController {
  
  

  @IBOutlet weak var exerciseTitle: UILabel!
  @IBOutlet weak var graphRenderView: UIView!
  
  
  @IBOutlet weak var setTableView: UITableView!
  var totalSetCounter = 1
  let barPlotData = [20.0, 30.0, 40.0, 50.0, 90.0, 20.0, 30.0, 40.0, 50.0, 90.0, 20.0, 30.0, 40.0, 50.0, 90.0, 20.0, 30.0, 40.0, 50.0, 90.0]
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setTableView.dataSource = self
    setTableView.delegate = self
    
    let exerciseLogCell = UINib(nibName: "ExerciseLogCell", bundle: nil)
    setTableView.register(exerciseLogCell, forCellReuseIdentifier: "ExerciseLogCell")
    
    animateGraph()
  }
  
  func animateGraph() {
    let graphView = ScrollableGraphView(frame: graphRenderView.bounds, dataSource: self)
    
    // Setup the plot
    let barPlot = BarPlot(identifier: "bar")

    barPlot.barWidth = 25
    barPlot.barLineWidth = 1
    barPlot.barLineColor = UIColor.blue
    barPlot.barColor = UIColor.green
    
    barPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
    barPlot.animationDuration = 1.5
    
    // Setup the reference lines
    let referenceLines = ReferenceLines()

    referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
    referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
    referenceLines.referenceLineLabelColor = UIColor.white
    
    referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)

    // Setup the graph
    graphView.backgroundFillColor = UIColor.orange

    graphView.shouldAnimateOnStartup = true

    graphView.rangeMax = 100
    graphView.rangeMin = 0

    // Add everything
    graphView.addPlot(plot: barPlot)
    graphView.addReferenceLines(referenceLines: referenceLines)
    
    graphRenderView.addSubview(graphView)
    
  }
}

// MARK: - scrollable graph datasource
extension ExerciseDetailVC: ScrollableGraphViewDataSource {
  func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
    // Return the data for each plot.
    switch(plot.identifier) {
    case "bar":
      return barPlotData[pointIndex]
    default:
      return 0
    }
  }
  
  func label(atIndex pointIndex: Int) -> String {
    return "FEB \(pointIndex)"
  }
  
  func numberOfPoints() -> Int {
    return barPlotData.count
  }
}

extension ExerciseDetailVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    totalSetCounter
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseLogCell") as? ExerciseLogCell else {
      fatalError()
    }
    return cell
  }
  
  
}
