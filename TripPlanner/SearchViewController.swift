import UIKit
import CoreLocation
import SwiftyJSON


class SearchViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet var plansTable: UITableView!
    @IBOutlet var searchResultsTable: UITableView!
    @IBOutlet weak var plansLabel: UILabel!
    @IBOutlet weak var searchResultsLabel: UILabel!

    
    var forecastData = [Weather]()
    let category = ["bar", "cafe", "casino", "library", "museum", "park", "restaurant", "zoo"]
    var type = "Bar"
    var latitude : CLLocationDegrees = -33.86
    var longitude : CLLocationDegrees = 151.20
    var begin = "Today"
    var days = 3
    
    //Create empty activity arrays for number of days allowed by picker
    var day1Plans : Array<String> = []
    var day2Plans : Array<String> = []
    var day3Plans : Array<String> = []
    var day4Plans : Array<String> = []
    var day5Plans : Array<String> = []
    
    //Int = key which is the day number starting from 0
    //[String] = string array that will store the list of activity strings
    var plans: [Int: [String]] = [:]
    
    var searchResults : [String] = Array(repeating: "", count: 10)

    @IBAction func RadiusSlider(_ sender: UISlider) {
        radiusLabel.text = String(Int(sender.value) * 500)
    }
    
    @IBAction func SearchButton(_ sender: Any) {
        let link = "https://maps.googleapis.com/maps/api/place/search/json?location=\(latitude),\(longitude)&radius=" + radiusLabel.text! + "&type=\(type)&key=AIzaSyC3xHTLIuqMhZkwnsmIdOQ1MFf5Wqya3MA"
        
        print(link)
        guard let url = URL(string: link)
            else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            /*
            if let response = response {
                print(response)
            }
            */
            
            guard let data = data else {return}
            
                do {
                    
                    let json = JSON(data)
                    
                    //Search results given radius and category
                    //Write to data collection
                    for k in 0..<10
                        //json["results"].count
                    {
                        //name: property's name; lat, lng: latitude, longitude
                        //rating: users' rating, vicinity, open: whether the property is open now(true or false)
                        //if some value is missing (e.g. no rating value), returns default value or empty (Won't crash the app)
                        let nameSearch : String = json["results"][k]["name"].stringValue
                        let latSearch : Double = json["results"][k]["geometry"]["location"]["lat"].doubleValue
                        let lngSearch : Double = json["results"][k]["geometry"]["location"]["lng"].doubleValue
                        let ratingSearch : Double = json["results"][k]["rating"].doubleValue
                        let vicinitySearch : String = json["results"][k]["vicinity"].stringValue
                        let openSearch : Bool = json["results"][k]["opening_hours"]["open_now"].boolValue
                        self.searchResults[k] = nameSearch
                        //print(vicinitySearch)
                        //print(ratingSearch)
                        //print(latSearch,lngSearch)
                        //print(openSearch)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute:  {
                        self.searchResultsTable.reloadData()
                    })
                    
                } catch {
                    print(error)
                }
            
            }.resume()
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = category[row]
    }
    
    //override func viewWillAppear(_ animated: Bool) {
        
    
    //}
    func searchForPTG()
    {
        self.title = "Search View"
        var coordinates: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
    
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/search/json?location=" + String(latitude) + "," + String(longitude) + "&radius=10000&keyword=things%20to%20do&rankby=prominence&key=AIzaSyC3xHTLIuqMhZkwnsmIdOQ1MFf5Wqya3MA"
        ) else { return }
    
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
        /*
         if let response = response {
         print(response)
         }
         */
        if let data = data {
    
        do {
        let json = JSON(data)
    
        //After user click "Start Planning", this view loads the search results of TTD(Things To Do) for given address within 10km radius
        //Write to data collection
        for i in 0..<10
        //json["results"].count
            {
            //name: property's name; lat, lng: latitude, longitude
            //rating: users' rating, vicinity, open: whether the property is open now(true or false)
            //if some value is missing (e.g. no rating value), returns default value or empty (Won't crash the app)
            let nameTTD : String = json["results"][i]["name"].stringValue
            let latTTD : Double = json["results"][i]["geometry"]["location"]["lat"].doubleValue
            let lngTTD : Double = json["results"][i]["geometry"]["location"]["lng"].doubleValue
            let ratingTTD : Double = json["results"][i]["rating"].doubleValue
            let vicinityTTD : String = json["results"][i]["vicinity"].stringValue
            let openTTD : Bool = json["results"][i]["opening_hours"]["open_now"].boolValue
            self.searchResults[i] = nameTTD
            //print(vicinityTTD)
            //print(ratingTTD)
            //print(latTTD,lngTTD)
            //print(openTTD)
            }
        }
        catch {
        print(error)
        }
    
        }
        }.resume()
    
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.searchResultsTable.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
        
        getWeatherForLocation(location: String(latitude) + "," + String(longitude))
        
        plans = [0: day1Plans, 1: day2Plans, 2: day3Plans, 3: day4Plans, 4: day5Plans, 5: [], 6: [], 7:[]]
        plansTable.delegate = self
        plansTable.dataSource = self
        searchResultsTable.delegate = self
        searchResultsTable.dataSource = self
        
        self.searchResultsTable.dragDelegate = self
        self.searchResultsTable.dragInteractionEnabled = true
        self.plansTable.dropDelegate = self
        searchForPTG()
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.orange
        self.tabBarController?.tabBar.backgroundColor = UIColor.orange
        
        plansLabel.layer.borderColor = UIColor.white.cgColor
        plansLabel.layer.borderWidth = 0.8
        
        searchResultsLabel.layer.borderColor = UIColor.white.cgColor
        searchResultsLabel.layer.borderWidth = 0.8
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeatherForLocation (location:String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                        
                        if let weatherData = results {
                            self.forecastData = weatherData
                            
                            //Remove the first day if start date is tomorrow
                            if(self.begin == "Tomorrow") {
                                self.forecastData.remove(at: 0)
                            }
                            
                            //Remove extra forecast data as it's not needed
                            if(self.days <= self.forecastData.count) {
                                while(self.forecastData.count > self.days) {
                                    self.forecastData.remove(at: self.forecastData.count - 1)
                                }
                            }
                            DispatchQueue.main.async {
                                self.plansTable.reloadData()
                            }
                        }
                        
                    })
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == plansTable {
            return (plans[section]?.count)!   //count the number activities for that day, section is day number
        } else if (tableView == searchResultsTable) {
            return searchResults.count
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == plansTable) {
            return self.forecastData.count
        } else if(tableView == searchResultsTable) {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if tableView == plansTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "plansCell", for: indexPath)
            
            //Customize plansCell to be clear and have border color
            cell.textLabel?.text = plans[indexPath.section]![indexPath.row]
            
            tableView.backgroundColor = .clear
            cell.backgroundColor = .clear
            tableView.tableFooterView = UIView()
            cell.layer.backgroundColor = UIColor.clear.cgColor
            
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.cornerRadius = 7
            cell.layer.borderWidth = 0.8
            cell.textLabel?.textColor = UIColor.white

            return cell
            
        } else { //searchResultsTable
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultsCell", for: indexPath)
            
            cell.textLabel?.text = searchResults[indexPath.row]
            
            tableView.backgroundColor = .clear
            cell.backgroundColor = .clear
            tableView.tableFooterView = UIView()
            cell.layer.backgroundColor = UIColor.clear.cgColor 
            
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.cornerRadius = 7
            cell.layer.borderWidth = 0.8
            cell.textLabel?.textColor = UIColor.white

            return cell
            
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchResultsTable {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.contentView.backgroundColor = UIColor.black
            cell?.contentView.alpha = 0.55

           
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView == searchResultsTable {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.contentView.backgroundColor = UIColor.clear
            
        }

    }

 
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == plansTable{
            //enable editting for just the plansTable
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == plansTable {
            if (editingStyle == UITableViewCellEditingStyle.delete) {
                
                //remove the data from the plans array
                self.plans[indexPath.section]?.remove(at: indexPath.row)
                
                //delete the corresponding row
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        if(tableView == plansTable) {
            view.layer.backgroundColor = UIColor.clear.cgColor  //customize plansTable's section color
            view.layer.borderColor = UIColor.black.cgColor
            view.layer.cornerRadius = 7
            view.layer.borderWidth = 0.8
            
            // Set the image for the section as the weather icon
            let weatherObject = forecastData[section]
            let headerImage = UIImage(named:weatherObject.icon)
            let imageView = UIImageView()
            imageView.image = headerImage
            imageView.frame = CGRect(x: 5, y: 5, width: 35, height: 35)
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            
            // Set the label for the section as the tempature and date
            var labelStr = ""
            var date = Calendar.current.date(byAdding: .day, value: section, to: Date())
            
            // Increment 1 to value if begin is tomorrow
            if(self.begin == "Tomorrow") {
                date = Calendar.current.date(byAdding: .day, value: section + 1, to: Date())
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            labelStr = dateFormatter.string(from: date!) + " (" + "\(Int(weatherObject.temperature))°F" + ")"
            
            let label = UILabel()
            label.text = labelStr
            label.textColor = UIColor.white
            label.frame = CGRect(x: 45, y: 5, width: 105, height: 35)
            
            view.addSubview(label)
            
        }
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == plansTable {
            return 40
        } else {
            return 0
        }
    }
    
}
extension SearchViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = self.dragItem(forIndexAt: indexPath)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let dragItem = self.dragItem(forIndexAt: indexPath)
        return [dragItem]
    }
    
    /// Helper method
    private func dragItem(forIndexAt indexPath: IndexPath) -> UIDragItem {
        let data = searchResults[indexPath.row]
        let string = data
        let itemProvider = NSItemProvider(object: string as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = data
        return dragItem
    }
    
    
}

extension SearchViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            guard let string = items as? [String] else { return }
            
            var indexPaths = [IndexPath]()
            
            for (index, value) in string.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                //Go to the num of day section and insert into that section's activity array
                self.plans[destinationIndexPath.section]!.insert(value, at: indexPath.row)
                indexPaths.append(indexPath)
            }
            
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
        
    }
    
    
    func tableView(_ tableView: UITableView, dropSessionDidEnter session: UIDropSession) {
        
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .copy, intent: .automatic)
    }
    
    
}



