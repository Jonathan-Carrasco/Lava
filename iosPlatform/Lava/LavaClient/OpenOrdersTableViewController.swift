//
//  OpenOrdersTableViewController.swift
//  LavaClient
//
//  Copyright © 2018 JNJ. All rights reserved.
//

import UIKit

class OpenOrdersTableViewController: UITableViewController {

    //user defaults
    let profileID = 2

    var history: Bool = false

  private var openOrders : [Order]? {
    didSet {
      tableView.reloadData()
    }
  }

    //this profile from user defaults for more complex implementation
    //private var thisProfile =

    override func viewDidLoad() {
        // Make estimated height whatever the user chose in the
        // storyboard.
        tableView.estimatedRowHeight = tableView.rowHeight

        // Let the table compute how tall the cells should be based
        // on the autolayout constraints.
        tableView.rowHeight = UITableViewAutomaticDimension
    }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if !history{
        // get open orders from server -- right now just one profile #.
        ClientRequests.getOpenOrders(profileId: self.profileID) {
          self.openOrders = $0
        }
    }else{
        ClientRequests.getOrdersForProfile(profileId: profileID, orderStatus: false){
            self.openOrders = $0
        }
    }
  }

    /// -Returns: The number of open orders in our model
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openOrders?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenOrder", for: indexPath)

        // Get the order that is associated with the row
        // that the table view is asking us to provide a UITableViewCell for
      if let openOrders = self.openOrders {
         let order = openOrders[openOrders.count - indexPath.row - 1]

        // Configure the cell...
        // the textLabel and detailTextLabel are for non-Custom cells
        //        cell.textLabel?.text = tweet.text
        //        cell.detailTextLabel?.text = tweet.user.name

        // For our custom cell, we need to treat `cell` as the appropriate
        // type so that we can assign to it's model property.  That
        // will cause the cell to load the right data into its UI outlets.
        if let orderCell = cell as? OpenOrderTableViewCell {
            orderCell.order = order
        }
      }
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "OrderDetail"{
            if let cell = sender as? OpenOrderTableViewCell,
                let order = cell.order{

                let destination = segue.destination
                if let orderDetailController = destination as? OrderDetailViewController{
                    orderDetailController.order = order
                    orderDetailController.actionPossible = history ? false: true
                }
            }
        }
    }

}
