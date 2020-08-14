//
//  TableViewCell.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-13.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import UIKit

class ExerciseLogCell: UITableViewCell, UITextFieldDelegate {

  
  @IBOutlet weak var setLabel: UILabel!
  @IBOutlet weak var repTextField: UITextField!
  @IBOutlet weak var weightTextField: UITextField!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }
  
    
}
