//
//  ViewController+extansion.swift
//  weather
//
//  Created by алексей ганзицкий on 20.10.2022.
//

import Foundation
import UIKit

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == forecastDayHoursCollection) {
            let count = currentData.arrayCurentHours.count
            return count
        } else {
            return currentData.arrayOfCellsDays.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == forecastDayHoursCollection) {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCellForecastHours", for: indexPath) as? CollectionViewCellForecastHours else { return UICollectionViewCell() }
                cell.loadValueCell(objectCell: currentData.arrayCurentHours[indexPath.item]) //sometimes i have trouble out of range
                return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCellDays", for: indexPath) as? CollectionViewCellDays else { return UICollectionViewCell()}
            cell.loadValueCell(objectCell: currentData.arrayOfCellsDays[indexPath.item])
            return cell
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentData.citys.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCollectionCells", for: indexPath) as? CityCollectionCells else { return UITableViewCell()}
        cell.cityName.text = currentData.citys[indexPath.row].localized()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(currentData.citys[indexPath.row])
        self.workWithAPI.city = currentData.citys[indexPath.row]
        sendRequestForCurentTemp()
        returnAnimate()
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            self.currentData.citys.remove(at: indexPath.row)
            self.changeCityTable.deleteRows(at: [indexPath], with: .automatic)
            SaveSettingsManager.shared.saveCitysTable(arrayCitys: currentData.citys)
        }
    }
}


extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        isThisARealCity()
        textField.text = ""
        return true
    }
}
