//
//  MasterTableViewController.swift
//  GitHubSearch
//
//  Created by Dmitry Reshetnik on 04.12.2020.
//

import UIKit

class MasterTableViewController: UITableViewController {
    var repositories: [Repository] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Repository", for: indexPath)

        // Configure the cell...
        let repository = repositories[indexPath.row]
        cell.textLabel!.text = repository.name
        cell.detailTextLabel!.text = repository.description

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Data fetching
    
    @objc func fetchJSON() {
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/search/repositories?q=apple&sort=stars&order=desc&per_page=15")!) {
            // Give the data to SwiftyJSON to parse.
            let jsonRepositories = JSON(parseJSON: data)
            
            // Read the commits back out.
            let jsonRepositoriesArray = jsonRepositories["items"].arrayValue
            
            print("Received \(jsonRepositoriesArray.count) new repositories.")
            
            for jsonRepository in jsonRepositoriesArray {
                var repository = Repository()
                repository.name = jsonRepository["full_name"].stringValue
                repository.url = jsonRepository["html_url"].stringValue
                repository.description = jsonRepository["description"].stringValue
                
                repositories.append(repository)
            }
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            return
        }
        
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}