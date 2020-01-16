    //
    //  DashboardViewController.swift
    //  LavaClient
    //
    //  Copyright © 2018 JNJ. All rights reserved.
    //

    import UIKit

    class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

        //ToDo: profile id here should be stored in user defaults and retrieved from there instead of hardcoaded as is
        var id = 2
        var profile: Profile?
        var profileOpenOrders: [Order]?{
            didSet {
                personalOpenOrders.reloadData()
            }
        }

        @IBOutlet private weak var profilePicture: UIImageView!
        @IBOutlet weak var nameLabel: UILabel!
        @IBOutlet weak var accountBalance: UILabel!

        override func viewDidLoad() {
            super.viewDidLoad()

            ClientRequests.getProfile(profileId: id){
                self.profile = $0
            }

            updateUI()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            ClientRequests.getOrdersForProfile(profileId: id, orderStatus: true){
                self.profileOpenOrders = $0
            }

            updateUI()
        }

        func updateUI(){
            if let prof = profile{
                nameLabel.text = "\(prof.name) : \(prof.handle)"
                accountBalance.text = "Balance: $\(prof.accountBalance)"

                DispatchQueue.global().async { [weak self] in
                    let url = URL(string: prof.profilePicture)
                    if let imageData = try? Data(contentsOf: url!) {
                        DispatchQueue.main.async {
                            if url == URL(string: prof.profilePicture){
                                self?.profilePicture?.image = UIImage(data: imageData)
                            }
                        }
                    }
                }

                /////////////////////
                //kill bad database entries where some id is 0 - database starts counting at 1

//                if let orders = profileOpenOrders{
//                    for elem in orders{
//                        if (elem.consumer == 0 || elem.supplier == 0){
//                            ClientRequests.deleteOrder(id: elem.orderID){}
//                        }
//                    }
//                }

                ////////////////////

            }
        }

        ////////////////////////////////////////////////////
        //deals with the profile's open orders table view
        //problem: data there but doesn't show up on screen
        @IBOutlet weak var personalOpenOrders: UITableView!
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OpenOrder", for: indexPath)

            if let data = self.profileOpenOrders {
                let order = data[data.count - indexPath.row - 1]

                //make tableviewcell and give it the data for the order
                if let orderCell = cell as? OpenOrderTableViewCell {
                    orderCell.order = order
                    orderCell.indicatorColor = indexPath.section == 1 ? UIColor.orange: UIColor.blue
                }
            }
            return cell
        }
        //the two sections are the laundry you must do and the laundry people are doing for you
        func numberOfSections(in tableView: UITableView) -> Int {
            return 2
        }
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            if section == 1{
                return "Laundry ToDo:"
            }else{
                return "Laundry Being Done:"
            }
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            if let data = profileOpenOrders{
                if section == 1{
                    return data.filter({ $0.supplier == id }).count
                }else{
                    return data.filter({ $0.consumer == id }).count
                }
            }
            return 0
        }
        ///////////////////////////////////////////////////

        override func prepare(for segue: UIStoryboardSegue, sender: Any?){
            if segue.identifier == "NewOrder"{
                if let prof = profile{
                    let destination = segue.destination
                    if let newOrderController = destination as? NewOrderViewController{
                        newOrderController.profile = prof
                    }
                }
            }else if segue.identifier == "OrderDetail"{
                if let cell = sender as? OpenOrderTableViewCell,
                    let order = cell.order{

                    let destination = segue.destination
                    if let orderDetailController = destination as? OrderDetailViewController{
                        orderDetailController.order = order
                    }
                }
            }else if segue.identifier == "History"{
                if let historyController = segue.destination as? OpenOrdersTableViewController{
                    historyController.history = true
                }
            }
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
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
