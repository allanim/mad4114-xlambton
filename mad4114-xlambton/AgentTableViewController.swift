//
//  AgentTableViewController.swift
//  mad4114-xlambton
//
//  Created by Allan Im on 2018-12-09.
//  Copyright © 2018 Allan Im. All rights reserved.
//

import UIKit
import CoreData

class AgentTableViewController: UITableViewController {

    var context: NSManagedObjectContext {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func fetch() -> [AgentEntity] {
        return try! context.fetch(AgentEntity.fetchRequest())
    }
    
    var dataArray: [AgentEntity] {
        return self.fetch().sorted(by: { $0.name! < $1.name! })
    }
    
    var selectedAgent: AgentEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        context.rollback()
        self.tableView.reloadData()
    }
    
    @IBAction func btnAddAgent(_ sender: Any) {
        self.selectedAgent = nil
        self.performSegue(withIdentifier: "details", sender: 0)
    }
    
    @IBAction func btnMap(_ sender: Any) {
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "agentCell", for: indexPath) as? AgentTableViewCell {
            let record = self.dataArray[indexPath.row]
            cell.lbAgent.text = "\(record.date ?? "") \(record.name ?? "")"
            return cell
        } else {
            fatalError("The dequeued cell is not an instance of RestaurantTableViewCell.")
        }
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedAgent = self.dataArray[indexPath.row]
        self.performSegue(withIdentifier: "details", sender: indexPath.row)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AgentDetailViewController {
            if let selected = self.selectedAgent {
                dest.editAgent = selected
            }
        }
    }
 

}

class AgentTableViewCell: UITableViewCell {
    @IBOutlet weak var lbAgent: UILabel!
}
