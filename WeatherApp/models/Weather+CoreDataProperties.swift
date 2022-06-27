import Foundation
import CoreData


extension WeatherHistoryData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherHistoryData> {
        return NSFetchRequest<WeatherHistoryData>(entityName: "WeatherHistoryData")
    }

    @NSManaged public var id : Int32
    @NSManaged public var cityName: String?
    @NSManaged public var date: Date?

}

extension WeatherHistoryData : Identifiable {

}
