//
//  SensorDataTableViewCell.swift
//  TestSensingKit
//
//  Created by Ксения Шкуренко on 03.10.2020.
//

import UIKit

class SensorDataTableViewCell: UITableViewCell {

    @IBOutlet weak var sensorNameLabel: UILabel!
    @IBOutlet weak var sensorDataLabel: UILabel!
    @IBOutlet weak var updateFrequencyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(sensorName: String, sensorData: String, updateFrequency: String) {
        sensorNameLabel.text = sensorName
        sensorDataLabel.text = sensorData
        updateFrequencyLabel.text = updateFrequency
    }
    
}
