
import UIKit

class TableViewController: ContainerViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override var locationsData: StudentLocationsData? {
        didSet {
            guard let locationsData = locationsData else { return }
            locations = locationsData.studentLocationsdata
        }
    }
    var locations: [StudentLocationData] = [] {
        didSet {
            tableView.reloadData()
        }
    }

}


extension TableViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "TCell", for: indexPath) as!
        TableViewCell
        c.media?.text = locations[indexPath.row].mediaURL
        c.name?.text = "\(locations[indexPath.row].firstName!)  \(locations[indexPath.row].lastName!) "
        return c
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sLocation = locations[indexPath.row]
        let media = sLocation.mediaURL!
        let mediaurl = URL(string: media)!
        
        UIApplication.shared.open(mediaurl, options: [:], completionHandler:nil)
        
    }
    
}
