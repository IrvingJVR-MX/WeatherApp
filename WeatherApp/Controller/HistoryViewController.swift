

import UIKit
import CoreData
import Foundation

class HistoryViewController: UIViewController {
    var searchedCityInfo: Weather?
    var cityId : Int32 = 0
    var savedCity = [WeatherHistoryData]()
    var cityWeatherSelected : Details?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedCity()
    }
    
    func loadSavedCity(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<WeatherHistoryData>(entityName: "WeatherHistoryData")
        do{
            let dbPhotos = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.savedCity = dbPhotos
                self.tableView.reloadData()
            }
            
        }catch(let error){
            print ("error", error)
        }
    }
    

}


extension HistoryViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  savedCity.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "MyCellTest") as? HistoryTableViewCell ?? HistoryTableViewCell(style: .subtitle, reuseIdentifier: "MyCellTest")
         
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         let myString = formatter.string(from: savedCity[indexPath.row].date ?? Date()) // string purpose I add here
         let yourDate = formatter.date(from: myString)
         formatter.dateFormat = "dd-MMM-yyyy"
         let myStringDate = formatter.string(from: yourDate!)

         var searchedcity = savedCity[indexPath.row].cityName ?? ""
         searchedcity =  searchedcity + "   \(myStringDate)"
         cell.citySearchedLabel.text = searchedcity
         return cell
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cityname = self.savedCity[indexPath.row].cityName ?? ""
        loadWeather2(cityname)
        cityId = savedCity[indexPath.row].id
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let actions = [
            UIContextualAction ( style: .destructive, title: "Delete" , handler: { _,_,_ in
                self.removeTableItem(indexPath.row)
            })
        ]
        
        return UISwipeActionsConfiguration (actions: actions)
        
    }
     
    

}




extension HistoryViewController {
    
    func removeTableItem (_ index:Int){
        let alert = UIAlertController(title: "Are you sure you want to delete this record", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction (title: "Yes, Delete", style: .default) {_ in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
             context.delete(self.savedCity[index])
             try? context.save()
             self.savedCity.remove(at: index)
             self.tableView.reloadData()

            
        })
        
        alert.addAction(UIAlertAction(title: "No, cancel", style: .cancel, handler: nil))
        self.navigationController?.present(alert, animated:true, completion: nil  )
        
    }
    
    
    func loadWeather2 (_ searchedCity: String){
        let urlStr = "https://openweathermap.org/data/2.5/find?q=\(searchedCity)&appid=439d4b804bc8187953eb36d2a8c26a02&units=metric"
        guard let url = URL(string: urlStr) else { return }

        NetworkManager.shared.get( Weather.self, from: url ) { result in
            
            switch result {
                
            case .success(let Response):
                self.searchedCityInfo = Response
                self.viewDetailWeather()
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
    
    func viewDetailWeather(){
        if let city = searchedCityInfo?.list.first(where: {$0.id == cityId}){
            guard   let cityWeatherSelected = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherViewController") as?
            WeatherViewController else{ return }
            cityWeatherSelected.cityWeatherSelected =  city
            show(cityWeatherSelected, sender: nil)
        }
    }
    

    
}
