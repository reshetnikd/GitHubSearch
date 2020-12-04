//
//  MasterTableViewController.swift
//  GitHubSearch
//
//  Created by Dmitry Reshetnik on 04.12.2020.
//

import UIKit

class MasterTableViewController: UITableViewController, UISearchResultsUpdating {
    private let searchController: UISearchController = UISearchController(searchResultsController: nil)
    var repositories: [Repository] = []
    var searchQuery: String = ""
    var isFilterActive : Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        title = "GitHub Repos"
        navigationController?.navigationBar.prefersLargeTitles = true
        // Setting up UISearchController.
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Repositories"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        fetchJSON()
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
        let url = GitHubAPI.BaseURL.appendingPathComponent("/search/repositories")
        let query = URLQueryItem(name: "q", value: isFilterActive && !searchQuery.isEmpty ? searchQuery : "apple")
        let sort = URLQueryItem(name: "sort", value: "stars")
        let order = URLQueryItem(name: "order", value: "desc")
        let quantity = URLQueryItem(name: "per_page", value: "30")
        var componetns = URLComponents(string: url.absoluteString)!
        componetns.queryItems = [query, sort, order, quantity]
        print(componetns.url!)
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? String(contentsOf: componetns.url!) {
                // Give the data to SwiftyJSON to parse.
                let jsonRepositories = JSON(parseJSON: data)
                self.repositories.removeAll()
                
                // Parse and read the repositories back out.
                self.parse(json: jsonRepositories)
                return
            }
            
            self.showError()
        }
    }
    
    @objc func showError() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    func parse(json: JSON) {
        let jsonRepositoriesArray = json["items"].arrayValue
        
        print("Received \(jsonRepositoriesArray.count) new repositories.")
        
        for jsonRepository in jsonRepositoriesArray {
            var repository = Repository()
            repository.name = jsonRepository["full_name"].stringValue
            repository.url = jsonRepository["html_url"].stringValue
            repository.description = jsonRepository["description"].stringValue
            
            repositories.append(repository)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.searchQuery = searchBar.text!.lowercased()
            self.fetchJSON()
        }
    }
    
    @objc func handleRefreshControl() {
        // Update your content…
        fetchJSON()
        
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }

}
