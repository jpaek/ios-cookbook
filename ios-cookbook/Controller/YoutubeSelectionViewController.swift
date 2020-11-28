//
//  NewRecipeViewController.swift
//  ios-cookbook
//
//  Created by Jae Paek on 11/23/20.
//

import UIKit
import CoreData
import WebKit

class YoutubeSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var name: String!
    var youtubeResponses: [YoutubeReponse]!
    var category: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getYoutubeResults()
        tableView.reloadData()
    }
    
    func getYoutubeResults() {
        youtubeResponses = [YoutubeReponse]()
        YoutubeClient.getSearchResult(recipeName: name, completion: { results, error in
            if let error = error {
                self.displayError(error: error)
                return
            }
            if let results = results {
                self.youtubeResponses = results
                print(self.youtubeResponses)
                self.tableView.reloadData()
            }
        })
        
    }
    
    func displayError(error: Error) {
        let alert = UIAlertController(title: "Error Found", message: error.localizedDescription, preferredStyle: .alert)

        // Create actions
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        dismissAction.isEnabled = true
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.youtubeResponses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoResultCell")!
        let result = self.youtubeResponses[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        cell.textLabel?.text = result.title
        if let imageUrl = result.imageUrl {
            YoutubeClient.downloadThumbnailImage(path: imageUrl, completion: { data, error in
                guard let data = data else {
                    cell.imageView?.image = UIImage(systemName: "photo")
                    return
                }
                cell.imageView?.image = UIImage(data: data)
            })
        } else {
            cell.imageView?.image = UIImage(systemName: "photo")
        }
        
        // If the cell has a detail label, we will put the evil scheme in.
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = "\(result.description)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let editController = self.storyboard!.instantiateViewController(withIdentifier: "RecipeEditViewController") as! RecipeEditViewController
        editController.youtubeVideo = self.youtubeResponses[(indexPath as NSIndexPath).row]
        editController.name = self.name
        editController.category = self.category
        self.navigationController!.pushViewController(editController, animated: true)
    }
    
}
