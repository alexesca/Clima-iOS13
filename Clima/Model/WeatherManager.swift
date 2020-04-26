//
//  WheaterModel.swift
//  Clima
//
//  Created by Alexander Escamilla on 4/22/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weather: WeatherModel)
    func didFailWithError(_ error: Error?)
}

struct WeatherManager {
    let url: String = "https://samples.openweathermap.org/data/2.5/weather?appid=6ba17d23031a4fa5cc1e6473c1edeb34&unitd=metrics"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather (_ city: String) {
        let newurl = "\(url)&q=\(city)"
        performRequest(newurl)
    }
    
    func fetchWeather( lat: Double, long: Double){
        let newurl = "\(url)&lat=\(lat)&lon=\(long)"
        performRequest(newurl)
    }
    
    func performRequest(_ stringUrl: String) {
        if let url = URL(string: stringUrl) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, urlResponse, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error)
                    return
                }
                
                if let safeData  = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(weather)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let city  = decodedData.name
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let weatherModel = WeatherModel(id: id, city: city, temp: temp)
            return weatherModel
        } catch {
            self.delegate?.didFailWithError(error)
            return nil
        }
    }
    

}



