

import UIKit
import CoreLocation

enum FormateForLabelTime {
    case date
    case time
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var feelsLikeLabelText = "Feels Like: "
    var windLabelText = "Wind: "
    var presureLabelText = "Presure: "
    var currentData = ObjectWeatherData()
    var workWithAPI = WorkWithNetwork()
    let spinner = ActivityIndicator()
    
    @IBOutlet weak var forecastDayCollection: UICollectionView!
    @IBOutlet weak var forecastDayHoursCollection: UICollectionView!
    @IBOutlet weak var myCityLocation: UIButton!
    @IBOutlet weak var timeLabelCurrent: UILabel!
    @IBOutlet weak var forecastForFiveDaysButtonConstraintForHideOrNot: NSLayoutConstraint!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var presureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var forecastForFiveDaysButton: UIButton!
    @IBOutlet weak var containerForColectionViewHours: UIView!
    @IBOutlet weak var dailyForecastButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dailyForecastButton: UIButton!
    @IBOutlet weak var noInternetConnectionLabel: UILabel!
    @IBOutlet weak var timeLabelDate: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var changeCityTable: UITableView!
    @IBOutlet weak var leftConstraintOutlet: NSLayoutConstraint!
    @IBOutlet weak var containerForCollectionView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var imageForTempLabel: UIImageView!
    @IBOutlet weak var findCityTF: UITextField!
    @IBOutlet weak var visualBlurEffect: UIVisualEffectView!
    @IBOutlet weak var viewForChangeCity: UIView!
    @IBOutlet weak var viewForCancel: UIView!
    
    @IBAction func changeCityButton(_ sender: UIButton) {
        leftConstraintOutlet.constant += viewForChangeCity.bounds.width
        viewForChangeCity.isHidden = false
        viewForCancel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.visualBlurEffect.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func myCityLocationButtonPressed(_ sender: UIButton) {
        workWithAPI.firstStart = true
        returnAnimate()
        connectWithServer()
    }
    
    @IBAction func dailyForecastHideOrNotButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            forecastForFiveDaysButtonConstraintForHideOrNot.constant = containerForColectionViewHours.bounds.height - 15
            dailyForecastButtonBottomConstraint.constant = 15
            dailyForecastButton.frame.size.height = 15
            self.forecastDayHoursCollection.alpha = 0
            self.forecastDayHoursCollection.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.containerForColectionViewHours.layoutIfNeeded()
                self.forecastDayHoursCollection.alpha = 1
            }
        } else {
            forecastForFiveDaysButtonConstraintForHideOrNot.constant = 80
            dailyForecastButtonBottomConstraint.constant = 40
            UIView.animate(withDuration: 0.3) {
                self.containerForColectionViewHours.layoutIfNeeded()
                self.forecastDayHoursCollection.alpha = 0
            } completion: { _ in
                self.forecastDayHoursCollection.isHidden = true
            }
        }
    }
    
    @IBAction func forecastForFiveDaysHideOrNotButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if currentData.arrayOfCellsDays.count < 5 {
                createAlertTroubldeDaysForecast()
            }
            UIView.animate(withDuration: 0.3) {
                self.windLabel.alpha = 0
                self.presureLabel.alpha = 0
                self.feelsLikeLabel.alpha = 0
                self.forecastDayCollection.alpha = 0
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.forecastDayCollection.isHidden = false
                    self.forecastDayCollection.alpha = 1
                }
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.forecastDayCollection.alpha = 0
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.windLabel.alpha = 1
                    self.presureLabel.alpha = 1
                    self.feelsLikeLabel.alpha = 1
                    self.forecastDayCollection.isHidden = true
                }
            }
        }
    }
    
    @IBAction func findCityButtonTapt(_ sender: UIButton) {
        isThisARealCity()
        addNewCity()
        if findCityTF.text == "" {
            self.spinner.hideLoading()
        }
        findCityTF.text = nil
    }
    
    @IBAction func tapForReturn() {
        returnAnimate()
        self.spinner.hideLoading()
    }
    
    func connectWithServer() {
        workWithAPI.sendTestConnect { connect in
            if connect != true {
                DispatchQueue.main.async {
                    self.visualBlurEffect.isHidden = false
                    self.noInternetConnectionLabel.isHidden = false
                }
            } else {
                self.sendRequestForCurentTemp()
                if self.currentData.error == 2008 {
                    self.visualBlurEffect.isHidden = false
                    self.noInternetConnectionLabel.text = "API KEY not working"
                    self.noInternetConnectionLabel.isHidden = false
                }
            }
        }
    }
    
    var requestDone = 0 {
        didSet {
            DispatchQueue.main.async {
                self.cityLabel.text = self.currentData.city.localized()
                SaveSettingsManager.shared.saveCurrentCity(curentCity: self.currentData.city)
                self.tempLabel.text = " \(self.currentData.temp)°C"
                self.feelsLikeLabel.text = self.feelsLikeLabelText.localized() + "\(self.currentData.tempFeelsLike)°C"
                self.windLabel.text = self.windLabelText.localized() + "\(self.currentData.windMph) MPH"
                self.presureLabel.text = self.presureLabelText.localized() + "\(self.currentData.presure) inHg"
                self.timeLabelDate.text = self.convertDateToString(format: .date)
                self.timeLabelCurrent.text = self.convertDateToString(format: .time)
                self.loadImage()
                self.forecastDayCollection.reloadData()
                self.forecastDayHoursCollection.reloadData()
                self.spinner.hideLoading()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1 ) {
                self.forecastDayHoursCollection.reloadData()
                self.forecastDayCollection.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner.showLoading(onView: self.view)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self.forecastDayCollection.dataSource = self
        self.forecastDayCollection.delegate = self
        self.forecastDayHoursCollection.dataSource = self
        self.forecastDayHoursCollection.delegate = self
        background.image = UIImage(named: "background")
        background.addParalaxEffect()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapForReturn))
        viewForCancel.addGestureRecognizer(recognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        viewModel.sendRequestForCurentTemp()
        self.connectWithServer()
    }
    
    func locationManager(_ manager: CLLocationManager,didChangeAuthorization status: CLAuthorizationStatus) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else {return}
        workWithAPI.currentLatitude = location.latitude
        workWithAPI.currentLongitude = location.longitude
        //        connectWithServer()
        print(location.latitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        workWithAPI.currentLatitude = location.latitude
        workWithAPI.currentLongitude = location.longitude
        print(location.latitude)
    }
    
    func isThisARealCity() {
        addNewCity()
        workWithAPI.sendRequestForCurrentTemp { request in
            self.currentData = request
            if request.error != nil {
                DispatchQueue.main.async {
                    self.createAlertNoCity()
                }
            }
            else {
                DispatchQueue.main.async {
                    self.returnAnimate()
                    if self.currentData.citys.contains(self.currentData.city) {
                    } else {
                        self.currentData.citys.append(self.currentData.city)
                    }
                    SaveSettingsManager.shared.saveCitysTable(arrayCitys: self.currentData.citys)
                    self.changeCityTable.reloadData()
                    self.requestDone += 1
                }
            }
        }
    }
    
    func sendRequestForCurentTemp() {
        workWithAPI.sendRequestForCurrentTemp { request in
            self.currentData = request
            self.requestDone += 1
        }
    }
    
    func createAlertNoCity() {
        let alert = UIAlertController.init(title: "WARNING!", message: "City not found!", preferredStyle: .alert)
        let okAktion = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAktion)
        self.present(alert, animated: true, completion: self.spinner.hideLoading )
    }
    
    func createAlertTroubldeDaysForecast() {
        let alert = UIAlertController.init(title: "SORRY!", message: "api restrictions are currently observed!", preferredStyle: .alert)
        let okAktion = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAktion)
        self.present(alert, animated: true, completion: nil )
    }
    
    func returnAnimate() {
        leftConstraintOutlet.constant -= viewForChangeCity.bounds.width
        self.spinner.showLoading(onView: self.view)
        viewForCancel.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.visualBlurEffect.isHidden = true
        } completion: { _ in
            self.viewForChangeCity.isHidden = true
        }
    }
    
    func convertDateToString(format: FormateForLabelTime) -> String {
        switch format {
        case .date :
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            guard let convertDate = dateFormatter.date(from: self.currentData.localTime) else { return "error" }
            dateFormatter.dateFormat = "dd.MMMM.yyyy"
            let newString = dateFormatter.string(from: convertDate)
            return newString
        case .time :
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            guard let convertDate = dateFormatter.date(from: self.currentData.localTime) else { return "error" }
            dateFormatter.dateFormat = "HH:mm"
            let newString = dateFormatter.string(from: convertDate)
            return newString
        }
    }
    
    func loadImage() {
        workWithAPI.loadImage(urlForImage: self.currentData.urlForCurentImage) { image in
            DispatchQueue.main.async {
                self.imageForTempLabel.image = image
            }
        }
    }
    
    func addNewCity() {
        if let lastChar = findCityTF.text?.first?.description.lowercased() {
            let ruCharacters = "йцукенгшщзхъфывапролджэёячсмитьбю"
            if ruCharacters.contains(lastChar) {
                var convertString = findCityTF.text?.lowercased()
                while convertString?.last == " " {
                    convertString?.removeLast()
                }
                while convertString?.first == " " {
                    convertString?.removeFirst()
                }
                if let newCity = convertString?.localized() {
                    workWithAPI.city = newCity.convertStringDellSpace()
                }
            } else {
                guard let newCity = findCityTF.text else { return }
                workWithAPI.city = newCity.convertStringDellSpace()
            }
        }
    }
}



