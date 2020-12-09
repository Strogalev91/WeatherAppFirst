//
//  ViewController.swift
//  WeatherApp
//
//  Created by Strogalev Ilia on 08/12/2020.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentCityIcon: UIImageView!
    @IBOutlet weak var currentCityTemp: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addCityButton: UIBarButtonItem!
    @IBOutlet weak var currentRegion: UILabel!
    @IBOutlet weak var addCityInFavourList: UIButton!
    @IBOutlet weak var viewHidden: UIView!
    
    var array = [String]()
    var arrCity = [City]()
    
    override func viewWillAppear(_ animated: Bool) {
        viewHidden.isHidden = false
    }
 
    // Функция анимации ячеек при появлении
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let degree: Double = 90
        let rotationAngle = CGFloat(degree * M_PI / 180)
        let rotationTransform = CATransform3DMakeRotation(rotationAngle, 1, 0, 0)
        cell.layer.transform = rotationTransform
        
        UIView.animate(withDuration: 1, delay: 0.2 * Double(indexPath.row), options: .curveEaseInOut, animations: {
            cell.layer.transform = CATransform3DIdentity
        })
    }

    //Функция удаления ячейки свайпом  - пока не работает
/*
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .delete {
            self.array.remove(at: indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .fade)
        }
    }
*/

        //Другой вариант функции удаления ячейки свайпом - пока не работает
 /*
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
        let place = array[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, boolValue) in
                StorageManager.deleteObject(place)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                complete(true)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
*/
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        for cityItem in array {
            setCityArray(name: cityItem)
        }
        getCityDetail(name: currentCity.text!)
    }
    //при нажатии на кнопку enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addCityAction(self)
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.nameCity.text = arrCity[indexPath.row].name
        cell.temp.text = arrCity[indexPath.row].temp
        cell.time.text = arrCity[indexPath.row].time
        cell.icon.image = UIImage(data: try! Data(contentsOf: URL(string: arrCity[indexPath.row].icon)!))
        
        //Проверка времени и в зависимости от него замена картинки города
        //Необходимо получить значение типа Double
/*
        if (time >= 00.00) && (time < 06.00) {
            print("Night")
            cell.backgroundCell.image = UIImage(named: "night")
        } else if (time >= 06.00) && (time < 12.00) {
            print("morning")
            cell.backgroundCell.image = UIImage(named: "morning")
        } else if (time >= 12.00) && (time < 18.00) {
            print("day")
         cell.backgroundCell.image = UIImage(named: "day")
         } else if (time >= 18.00) && (time < 00.00) {
            print("evening")
         cell.backgroundCell.image = UIImage(named: "evening")
         }
*/
        cell.backgroundCell.image = UIImage(named: "evening")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    //Получение данных на основной город
    func getCityDetail(name: String) {
        let url = "https://api.weatherapi.com/v1/current.json?key=\(token)&q=\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AF.request(url as! URLConvertible, method: .get).validate().responseJSON { (response) in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                //Парсим нужные данные из api
                    self.currentCity.text = self.textField.text!
                    self.currentCityTemp.text = json["current"]["temp_c"].stringValue
                    let iconString = "https:\(json["current"]["condition"]["icon"].stringValue)"
                    self.currentCityIcon.image = UIImage(data: try! Data(contentsOf: URL(string: iconString)!))
                    self.currentRegion.text = json["location"]["region"].stringValue
                case .failure(let error):
                    print(error)
            }
        }
    }
    //Получение данных в массив городов
    func setCityArray(name: String) {
        let url = "https://api.weatherapi.com/v1/current.json?key=\(token)&q=\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AF.request(url as! URLConvertible, method: .get).validate().responseJSON { (response) in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let temp = json["current"]["temp_c"].stringValue
                    let icon = "https:\(json["current"]["condition"]["icon"].stringValue)"
                    let city = json["location"]["name"].stringValue
                    let time = json["location"]["localtime"].stringValue
                    self.arrCity.append(City(name: city, temp: temp, time: time, icon: icon))
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
            }
        }
    }//
    
    //проверка и передача из текущего города в избранные
    @IBAction func addCityInFavourAction(_ sender: Any) {
        if array.contains(currentCity.text!) {
            print("no no no")
        } else if currentCity.text == "" {
            return
            print("current city is empty")
        } else {
            self.setCityArray(name: currentCity.text!)
            print("city is in favour")
        }
    }
    //проверка и передача из текстфилда в текущий город
    @IBAction func addCityAction(_ sender: Any) {
        if textField.text == "" {
            return
        }
        self.getCityDetail(name: textField.text!)
        viewHidden.isHidden = true
        textField.resignFirstResponder()
    }
    struct City {
        var name: String
        var temp: String
        var time: String
        var icon: String
    }
    
}
