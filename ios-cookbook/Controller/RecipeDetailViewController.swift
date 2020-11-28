//
//  RecipeDetailViewController.swift
//  ios-cookbook
//
//  Created by Jae Paek on 11/23/20.
//

import UIKit
import CoreData
import WebKit

class RecipeDetailViewController: UIViewController {
    
    @IBOutlet weak var youtubeVideoView: WKWebView!
    @IBOutlet weak var ingredientText: UITextView!
    @IBOutlet weak var stepText: UITextView!
    
    
    var recipe: Recipe?
    
    override func viewDidLoad() {
        setViewPage()
        setVideoView()
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
    
    func setViewPage() {
        ingredientText.text = recipe?.ingredients
        stepText.text = recipe?.steps
    }
    
    @IBAction func openEdit(_ sender: Any) {
        let editController = self.storyboard!.instantiateViewController(withIdentifier: "RecipeEditViewController") as! RecipeEditViewController
        editController.recipe = self.recipe
        self.navigationController!.pushViewController(editController, animated: true)
    }
}
