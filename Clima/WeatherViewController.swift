//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "1c8b4f08cab20b6c51e658d4faa1b547"
    
    //e72ca729af228beabd5d20e3b7749713 --appbrewery

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    @IBOutlet weak var toggleSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here. In order to access capabilities of a locationManager we i.e the class needs to be the delegate of the location manager .
//Delegat means : a person acting for another or to give control , For delegation to occur in software, you’d have a situation where one class (a delegator/principal class) would delegate control or responsibility, here meaning behavioral logic, to another class called a delegate.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization() //add description for the popups in order for them to appear,so go to info.plist and add in 2 Privacy keys for location and also the bypass for ssl encryption as apple only allows access to apis which have ssl encryption, that would be found in appbrewery's clima app git page.
        locationManager.startUpdatingLocation() //asynchronous method i.e runs in background. calls didupdatelocation and didfailwitherror
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here: Alamofire is a cocoapod used for hhtp requests and getting json
    func getWeatherData(url : String, parameters: [String: String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess{
                print("Success, got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                //here the value is of type any so we will have to typecast it to JSON and the response can be a nil, as we are already checking the data in if statement we can say that "the value wont be a nil " thus adding a !
                print(weatherJSON)
                self.updateWeatherData(json : weatherJSON)
            }
            else{
                print("Error : \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection issues"
            }
            
            
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateWeatherData(json : JSON){
        if let temperature  = json["main"]["temp"].double { //in swiftyjson
        weatherDataModel.temperature = Int(temperature - 273.15)
        weatherDataModel.city = json["name"].stringValue  //stringvalue is in swiftysjon
        weatherDataModel.condition = json["weather"]["0"]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else{
            cityLabel.text = "Weather Unavailable"
        }
    }
    
    
    @IBAction func toggle(_ sender: UISwitch) {
        if sender.isOn == true{
            temperatureLabel.text = String(weatherDataModel.temperature)
        }
        else{
            let temperature = (Double(weatherDataModel.temperature) * 1.8 ) + 32
            print(temperature)
            temperatureLabel.text = "5.5"
        }
    }
    
    
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)℃"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
       // self.view.backgroundColor = UIColor.blue
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
       
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil //for stop the repeating process.
           
            //print("longitude \(location.coordinate.longitude) , latitude \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude , "lon" : longitude , "appid" : APP_ID]
            
            getWeatherData(url : WEATHER_URL , parameters : params)
        }
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func UserEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city , "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destination = segue.destination as! ChangeCityViewController
            
            destination.delegate = self // taking responsibility just as we did in locationManger.delegate = self
            
        }
    }
    
    
    
    
}


