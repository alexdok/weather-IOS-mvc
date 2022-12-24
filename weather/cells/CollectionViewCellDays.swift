//
//  CollectionViewCell.swift
//  weather
//
//  Created by алексей ганзицкий on 12.10.2022.
//

import UIKit

class CollectionViewCellDays: UICollectionViewCell {
    var network = WorkWithNetwork()
    var date: String = "загрузка"
    var temp: Double = 0
    var icon: String = "загрузка"
    
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var tempLable: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadVieCell() {
        loadImage()
        self.dateLable.text = "\(convertDateToString())"
        self.tempLable.text = "\(temp) °C"
    }
    
    func loadValueCell(objectCell: ForecastDayArray) {
        date = objectCell.date
        temp = objectCell.day.avgtempC
        icon = objectCell.day.condition.icon
        loadVieCell()
    }
    
    func convertDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let convertDate = dateFormatter.date(from: date) else { return " " }
        dateFormatter.dateFormat = "dd.MM.yy"
        let newString = dateFormatter.string(from: convertDate)
        return newString
    }
    
    
    func loadImage() {
        network.loadImage(urlForImage: icon) { image in
            DispatchQueue.main.async {
                self.iconImage.image = image
            }
        }
    }
}
