import UIKit

class WeatherViewController: UIViewController {

    var cityWeatherSelected : Details?
   
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var skyConditionLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
      
    }
    
    func loadData(){
        let searchedCityName =  cityWeatherSelected?.name ?? " "
        self.title = searchedCityName
        let temp = cityWeatherSelected?.main.temp ?? 0.00
        cityNameLabel.text = searchedCityName + "  " + temp.description
         skyConditionLabel.text = cityWeatherSelected?.weather[0].description
        let imageName =  cityWeatherSelected?.weather[0].icon
        if let url = URL (string: "https://openweathermap.org/img/wn/\(imageName ?? "")@2x.png"){
            weatherImageView.load(url: url)
        }
        let countryName = cityWeatherSelected?.sys.country ?? " "
        
        countryNameLabel.text = "Country: " + countryName
        
        if let url2 = URL (string: "https://countryflagsapi.com/png/\(cityWeatherSelected?.sys.country ?? "")"){
            countryImageView.load(url: url2)
        }
        
        let wind = cityWeatherSelected?.wind.speed.description ?? ""
        windLabel.text = "Wind: " + wind

    }

}


