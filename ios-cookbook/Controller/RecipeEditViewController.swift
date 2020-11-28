//
//  RecipeEditViewController.swift
//  ios-cookbook
//
//  Created by Jae Paek on 11/23/20.
//

import UIKit
import WebKit

class RecipeEditViewController: UIViewController {
    @IBOutlet weak var youtubeVideoView: WKWebView!
    @IBOutlet weak var ingredientText: UITextView!
    @IBOutlet weak var stepText: UITextView!
    
    var recipe: Recipe?
    var name: String?
    var category: Category?
    var youtubeVideo: YoutubeReponse?
    
    override func viewDidLoad() {
        if name != nil {
            setNewRecipe()
        }
        setVideoView()
        setEditPage()
    }
    
    func setNewRecipe() {
        recipe = Recipe(context: DataController.shared.viewContext)
        recipe?.name = name
        recipe?.category = category
        if let videoId = youtubeVideo?.videoId {
            recipe?.youtubeLink = URL(string: YoutubeClient.Endpoints.videoBase + videoId)
        }
        
    }
    
    func setEditPage() {
        ingredientText.text = recipe?.ingredients
        stepText.text = recipe?.steps
    }
    
    func setVideoView() {
        if let url = recipe?.youtubeLink {
            youtubeVideoView.isHidden = false
            youtubeVideoView.load(URLRequest(url: url))
        }
        else {
            youtubeVideoView.isHidden = true
        }
        
    }
    @IBAction func saveRecipe(_ sender: Any) {
        recipe?.ingredients = ingredientText.text
        recipe?.steps = stepText.text
        try? DataController.shared.viewContext.save()
        
        let listViewController = self.storyboard!.instantiateViewController(withIdentifier: "RecipeListViewController") as! RecipeListViewController
        listViewController.category = recipe?.category
        self.navigationController!.pushViewController(listViewController, animated: true)
        
    }
}
