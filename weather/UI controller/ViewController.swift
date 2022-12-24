

import UIKit
import CoreLocation

enum FormateForLableTime {
    case date
    case time
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var feelsLikeLableText = "Feels Like: "
    var windLableText = "Wind: "
    var presureLableText = "Presure: "
    
    var curentData = ObjectWeAreWorkingWith()
    var workWithAPI = WorkWithNetwork()
    let spiner = ActivityIndicator()

    
    
    @IBOutlet weak var forecastDayCollection: UICollectionView!
    @IBOutlet weak var forecastDayHoursCollection: UICollectionView!
    
    var requestDone = 0 {
        didSet {
            DispatchQueue.main.async {
                self.cityLable.text = self.curentData.city.localized()
//                self.viewModel.setLableCity()
                SaveSettingsManager.shared.saveCurentCity(curentCity: self.curentData.city)
                self.tempLable.text = " \(self.curentData.temp)°C"
                self.feelsLikeLable.text = self.feelsLikeLableText.localized() + "\(self.curentData.tempFeelsLike)°C"
                self.windLable.text = self.windLableText.localized() + "\(self.curentData.windMph) MPH"
                self.presureLable.text = self.presureLableText.localized() + "\(self.curentData.presure) inHg"
                self.timeLableDate.text = self.convertDateToString(format: .date)
                self.timeLableCurent.text = self.convertDateToString(format: .time)
                self.loadImage()
                self.forecastDayCollection.reloadData()
                self.forecastDayHoursCollection.reloadData()
                self.spiner.hideLoading()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1 ) {
                self.forecastDayHoursCollection.reloadData()
                self.forecastDayCollection.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spiner.showLoading(onView: self.view)
        
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
    
    @IBOutlet weak var myCityLocation: UIButton!
    @IBOutlet weak var timeLableCurent: UILabel!
    @IBOutlet weak var forecastForFiveDaysButtonConstraintForHideOrNot: NSLayoutConstraint!
    @IBOutlet weak var feelsLikeLable: UILabel!
    @IBOutlet weak var presureLable: UILabel!
    @IBOutlet weak var windLable: UILabel!
    @IBOutlet weak var forecastForFiveDaysButton: UIButton!
    @IBOutlet weak var containerForColectionViewHours: UIView!
    @IBOutlet weak var dailyForecastButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dailyForecastButton: UIButton!
    @IBOutlet weak var noInternetConnectionLable: UILabel!
    @IBOutlet weak var timeLableDate: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var changeCityTable: UITableView!
    @IBOutlet weak var leftConstrainOutlet: NSLayoutConstraint!
    @IBOutlet weak var containerForCollectionView: UIView!
    @IBOutlet weak var cityLable: UILabel!
    @IBOutlet weak var tempLable: UILabel!
    @IBOutlet weak var imageForTempLable: UIImageView!
    @IBOutlet weak var findCityTF: UITextField!
    @IBOutlet weak var visualBlurEffect: UIVisualEffectView!
    @IBOutlet weak var viewForChangeCity: UIView!
    @IBOutlet weak var viewForCancel: UIView!
    
    @IBAction func changeCityButton(_ sender: UIButton) {
        leftConstrainOutlet.constant += viewForChangeCity.bounds.width
        viewForChangeCity.isHidden = false
        viewForCancel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.visualBlurEffect.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func myCityLocationButtonPrassed(_ sender: UIButton) {
        workWithAPI.firstStart = true
        returnAnimate()
        connectWithServer()
    }
    
    @IBAction func dailyForecastHideOrNotButtonPrassed(_ sender: UIButton) {
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
    
    @IBAction func forecastForFiveDaysHideOrNotButtonPrassed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            if curentData.arrayOfCellsDays.count < 5 {
                createAlertTroubldeDaysForecast()
            }
            UIView.animate(withDuration: 0.3) {
                self.windLable.alpha = 0
                self.presureLable.alpha = 0
                self.feelsLikeLable.alpha = 0
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
                    self.windLable.alpha = 1
                    self.presureLable.alpha = 1
                    self.feelsLikeLable.alpha = 1
                    self.forecastDayCollection.isHidden = true
                }
            }
        }
    }
    
    @IBAction func findCityButtonTapt(_ sender: UIButton) {
        isThisARealCity()
        addNewCity()
        if findCityTF.text == "" {
            self.spiner.hideLoading()
        }
        findCityTF.text = nil
    }
    
    @IBAction func tapForReturn() {
        returnAnimate()
        self.spiner.hideLoading()
    }
    
    
    func connectWithServer() {
        workWithAPI.sendTestConnect { connect in
            if connect != true {
                DispatchQueue.main.async {
                    self.visualBlurEffect.isHidden = false
                    self.noInternetConnectionLable.isHidden = false
                }
            } else {
                self.sendRequestForCurentTemp()
                if self.curentData.error == 2008 {
                    self.visualBlurEffect.isHidden = false
                    self.noInternetConnectionLable.text = "API KEY not working"
                    self.noInternetConnectionLable.isHidden = false
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager,didChangeAuthorization status: CLAuthorizationStatus) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else {return}
        workWithAPI.curentLatitude = location.latitude
        workWithAPI.curentLongitude = location.longitude
//        connectWithServer()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        workWithAPI.curentLatitude = location.latitude
        workWithAPI.curentLongitude = location.longitude
    }
    
    func isThisARealCity() {
        addNewCity()
        workWithAPI.sendRequestForCurentTemp { request in
            self.curentData = request
            if request.error != nil {
                DispatchQueue.main.async {
                    self.createAlertNoCity()
                }
            }
            else {
                DispatchQueue.main.async {
                    self.returnAnimate()
                    if self.curentData.citys.contains(self.curentData.city) {
                    } else {
                        self.curentData.citys.append(self.curentData.city)
                    }
                    SaveSettingsManager.shared.saveCitysTable(arrayCitys: self.curentData.citys)
                    self.changeCityTable.reloadData()
                    self.requestDone += 1
                }
            }
        }
    }
    
    func sendRequestForCurentTemp() {
        workWithAPI.sendRequestForCurentTemp { request in
            self.curentData = request
            self.requestDone += 1
        }
    }
    
    func createAlertNoCity() {
        let alert = UIAlertController.init(title: "WARNING!", message: "City not found!", preferredStyle: .alert)
        let okAktion = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAktion)
        self.present(alert, animated: true, completion: self.spiner.hideLoading )
    }
    
    func createAlertTroubldeDaysForecast() {
        let alert = UIAlertController.init(title: "SORRY!", message: "api restrictions are currently observed!", preferredStyle: .alert)
        let okAktion = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAktion)
        self.present(alert, animated: true, completion: nil )
    }
    
    func returnAnimate() {
        leftConstrainOutlet.constant -= viewForChangeCity.bounds.width
        self.spiner.showLoading(onView: self.view)
        viewForCancel.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.visualBlurEffect.isHidden = true
        } completion: { _ in
            self.viewForChangeCity.isHidden = true
        }
    }
    
    func convertDateToString(format: FormateForLableTime) -> String {
        switch format {
        case .date :
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            guard let convertDate = dateFormatter.date(from: self.curentData.localTime) else { return "error" }
            dateFormatter.dateFormat = "dd.MMMM.yyyy"
            let newString = dateFormatter.string(from: convertDate)
            return newString
        case .time :
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            guard let convertDate = dateFormatter.date(from: self.curentData.localTime) else { return "error" }
            dateFormatter.dateFormat = "HH:mm"
            let newString = dateFormatter.string(from: convertDate)
            return newString
        }
    }
    

    
    func loadImage() {
        workWithAPI.loadImage(urlForImage: self.curentData.urlForCurentImage) { image in
            DispatchQueue.main.async {
                self.imageForTempLable.image = image
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



