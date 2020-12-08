//
//  ViewController.swift
//  WeatherApp
//
//  Created by Strogalev Ilia on 08/12/2020.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var currentCityIcon: UIImageView!
    @IBOutlet weak var currentCityTemp: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var currentRegion: UILabel!
    
    var array = ["Murmansk", "Moscow", "Ekaterinburg", "Vladivostok"]
    var arrCity = [City]()
    
    override func viewWillAppear(_ animated: Bool) {
        getCityDetail(name: "Екатеринбург")
        
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
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            array.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
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
        for cityItem in array {
            setCityArray(name: cityItem)
        }
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
        cell.backgroundCell.image = UIImage(named: "night")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func getCityDetail(name: String) {
        let url = "https://api.weatherapi.com/v1/current.json?key=\(token)&q=\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        AF.request(url as! URLConvertible, method: .get).validate().responseJSON { (response) in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                //Парсим нужные данные из api
                    self.currentCity.text = name
                    self.currentCityTemp.text = json["current"]["temp_c"].stringValue
                    let iconString = "https:\(json["current"]["condition"]["icon"].stringValue)"
                    self.currentCityIcon.image = UIImage(data: try! Data(contentsOf: URL(string: iconString)!))
                    self.currentRegion.text = json["location"]["region"].stringValue
                case .failure(let error):
                    print(error)
            }
        }
    }
    
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
    }
    
    @IBAction func addCityAction(_ sender: Any) {
        let alert = UIAlertController(title: "Добавить город", message: "", preferredStyle: .alert)
        alert.addTextField { (textFieldAlert) in
            textFieldAlert.placeholder = "Тверь"
        }
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            if let text = alert.textFields![0].text {
                self.setCityArray(name: text)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    struct City {
        var name: String
        var temp: String
        var time: String
        var icon: String
    }
    
}
