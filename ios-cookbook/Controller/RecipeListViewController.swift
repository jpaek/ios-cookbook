//
//  RecipeListViewController.swift
//  ios-cookbook
//
//  Created by Jae Paek on 11/23/20.
//

import  UIKit
import CoreData

class RecipeListViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var category: Category!
    
    var fetchedResultsController:NSFetchedResultsController<Recipe>!
    
    /// A date formatter for date text in note cells
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "\(category)-recipes")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = category.name
        navigationItem.rightBarButtonItem = editButtonItem
        
        setupFetchedResultsController()
        
        updateEditButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @IBAction func addTapped(sender: Any) {
        presentNewRecipeAlert()
    }
    
    func presentNewRecipeAlert() {
        let alert = UIAlertController(title: "New Recipe", message: "Enter a name for this recipe", preferredStyle: .alert)

        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
//                self?.addRecipe(name: name)
                self?.openYoutubeSelection(name: name)
            }
        }
        saveAction.isEnabled = false

        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }
    
//    func addRecipe(name: String) {
//        let note = Note(context: dataController.viewContext)
//        note.creationDate = Date()
//        note.notebook = notebook
//        try? dataController.viewContext.save()
//    }
    
    func openYoutubeSelection(name: String) {
        let youtubeSelectionViewController = self.storyboard!.instantiateViewController(withIdentifier: "YoutubeSelectionViewController") as! YoutubeSelectionViewController
        youtubeSelectionViewController.name = name
        youtubeSelectionViewController.category = category
        self.navigationController!.pushViewController(youtubeSelectionViewController, animated: true)
    }

    func deleteRecipe(at indexPath: IndexPath) {
        let recipeToDelete = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(recipeToDelete)
        try? DataController.shared.viewContext.save()
    }

    func updateEditButtonState() {
       navigationItem.rightBarButtonItem?.isEnabled = fetchedResultsController.sections![0].numberOfObjects > 0
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCell.defaultReuseIdentifier, for: indexPath) as! RecipeCell

        // Configure cell
        cell.nameLabel.text = recipe.name
        
        if let creationDate = recipe.creationDate {
            cell.dateLabel.text = dateFormatter.string(from: creationDate)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteRecipe(at: indexPath)
        default: () // Unsupported
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NoteDetailsViewController, we'll configure its `Note`
        // and its delete action
        if let vc = segue.destination as? RecipeDetailViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.recipe = fetchedResultsController.object(at: indexPath)
            }
        }
    }
}

extension RecipeListViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
