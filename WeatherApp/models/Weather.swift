import Foundation

struct Weather : Decodable{
    
    let message: String
    let cod: String
    let count: Int
    let list : [Details]
}


struct Details : Decodable{
   let id: Int
   let name: String
   let weather : [WeatherDetails]
   let main : Main
   let wind : wind
   let sys : Sys
}

struct WeatherDetails : Decodable{
    let id : Int
    let main : String
    let description : String
    let icon : String
    
}

struct Main : Decodable {
    let temp: Float
}

struct Sys : Decodable {
    let country : String
}

struct wind : Decodable {
    let speed : Float
    let deg :   Int
}
