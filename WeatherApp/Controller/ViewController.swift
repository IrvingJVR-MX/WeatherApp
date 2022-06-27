import UIKit
import CoreData

class ViewController: UIViewController {

    var searchedCityInfo: Weather?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var emptyLabel = UILabel()
    var savedCity = [WeatherHistoryData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
    }


}

extension ViewController:  UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedCityInfo?.list.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let id = Int32(searchedCityInfo?.list[indexPath.row].id ?? 0)

        saveCitySearched(searchedCityInfo?.list[indexPath.row].name ?? "", id)
        guard   let cityWeatherSelected = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherViewController") as?
        WeatherViewController else{ return }
        cityWeatherSelected.cityWeatherSelected =  searchedCityInfo?.list[indexPath.row]
        
        show(cityWeatherSelected, sender: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as? WeatherCollectionViewCell ?? WeatherCollectionViewCell()

         let searchedCityName =  searchedCityInfo?.list[indexPath.row].name ?? " "
         let temp = searchedCityInfo?.list[indexPath.row].main.temp ?? 0.00

         cell.cityNameLabel.text = searchedCityName + "               " + temp.description
         cell.cityWeatherLabel.text = searchedCityInfo?.list[indexPath.row].weather[0].description
         let imageName = searchedCityInfo?.list[indexPath.row].weather[0].icon
        
        if let url = URL (string: "https://openweathermap.org/img/wn/\(imageName ?? "")@2x.png"){
            cell.weatherImage.load(url: url)
       }
        
        return cell
        
    }
    
    
}


extension ViewController : UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         view.endEditing(true)
         searchBar.text = ""
    }
  
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty == false {
            loadWeather(searchBar.text ?? "")
        }
    }
}




extension ViewController {
    
    func loadWeather (_ searchedCity: String){
        
        let searchedCityCleaned : String = searchedCity.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
        let urlStr = "https://openweathermap.org/data/2.5/find?q=\(searchedCityCleaned)&appid=439d4b804bc8187953eb36d2a8c26a02&units=metric"
        guard let url = URL(string: urlStr) else { return }
        
        NetworkManager.shared.get( Weather.self, from: url ) { result in
            
            switch result {
                
            case .success(let Response):
                self.searchedCityInfo = Response
                
                if self.searchedCityInfo?.count == 0{
                    self.emptyLabel.text = "There where no results for \(searchedCity)"
                    self.view.addSubview(self.emptyLabel)
                    self.emptyLabel.topAnchor.constraint(equalTo: self.searchBar.topAnchor, constant: self.searchBar.frame.height + 60).isActive = true
                    self.emptyLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 60).isActive = true
                    self.emptyLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
                    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.collectionView.reloadData()
                }else {
                    self.emptyLabel.removeFromSuperview()
                    self.collectionView.reloadData()
                }
                
                
            case .failure(let error):
                print(error)
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    print("OK")
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func saveCitySearched(_ cityname : String , _ id : Int32){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<WeatherHistoryData>(entityName: "WeatherHistoryData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", String(id))
        do{
             let result = try context.fetch(fetchRequest)
            if result.isEmpty == true {
                guard let entity = NSEntityDescription.entity(forEntityName: "WeatherHistoryData", in: context) else { return }
                guard let weatherH = NSManagedObject(entity: entity, insertInto: context) as? WeatherHistoryData else { return }
                weatherH.cityName = cityname
                weatherH.date = Date()
                weatherH.id = id
                try context.save()
            }
            
        }catch(let error){
            print ("error", error)
        }

    }
    
    func loadSavedCity(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<WeatherHistoryData>(entityName: "WeatherHistoryData")
        do{
            let dbPhotos = try context.fetch(fetchRequest)
             savedCity = dbPhotos
        }catch(let error){
            print ("error", error)
        }
    }
    
    
    
}


extension UIImageView{
    
    func load(url: URL){
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
            
        }
        
    }
}
