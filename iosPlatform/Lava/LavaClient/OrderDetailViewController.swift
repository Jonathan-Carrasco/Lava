//
//  OrderDetailViewController.swift
//  LavaClient
//
//  Copyright © 2018 JNJ. All rights reserved.
//

import UIKit

class OrderDetailViewController: UIViewController {

    //user defaults
    var thisProfile = 2

    var actionPossible: Bool = false

    //the order whose details are showing
    var order: Order?{
        didSet{
            updateUI()
        }
    }
    //the order's consumer
    var consumer: Profile?{
        didSet{
            updateUI()
        }
    }
    //the order's supplier
    var supplier: Profile?{
        didSet{
            updateUI()
        }
    }

    //consumer info
    @IBOutlet weak var consumerName: UILabel!
    @IBOutlet weak var consumerHandle: UILabel!
    @IBOutlet weak var consumerProfPic: UIImageView!

    //supplier info
    @IBOutlet weak var supplierName: UILabel!
    @IBOutlet weak var supplierHandle: UILabel!
    @IBOutlet weak var supplierProfPic: UIImageView?

    //other order info
    @IBOutlet weak var dormName: UILabel!
    @IBOutlet weak var dormImage: UIImageView!
    @IBOutlet weak var descript: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var folded: UILabel!

    @IBAction func closeOrder(_ sender: UIButton) {
        if let data = order{
            if data.supplier == 1{
                ClientRequests.deleteOrder(id: data.orderID){}
                _ = self.navigationController?.popViewController(animated: true)
            }else{
                ClientRequests.updateOrder(id: data.orderID, consumer: data.consumer, supplier: data.supplier, location: data.location, price: data.price, folded: data.folded, description: data.description, open: false){}
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }

    //when you pick an open order to fill
    @IBAction func fillOrder(_ sender: UIButton) {

        if let data = order{
            //updates order to have this user as the supplier
            ClientRequests.updateOrder(id: data.orderID, consumer: data.consumer, supplier: thisProfile, location: data.location, price: data.price, folded: data.folded, description: data.description, open: true){}
            print("update successful!")

            //updates profile balances
            if let con = consumer{
                print("change consumer balance")
                ClientRequests.updateProfile(id: data.consumer, handle: con.handle, accountBalance: (con.accountBalance-data.price), profilePicture: con.profilePicture, birthDate: con.birthDate, dorm: con.dorm, name: con.name, gender: con.gender){}
            }
            if let sup = supplier{
                print("change supplier balance")
                ClientRequests.updateProfile(id: data.supplier, handle: sup.handle, accountBalance: (sup.accountBalance+(data.price-1)), profilePicture: sup.profilePicture, birthDate: sup.birthDate, dorm: sup.dorm, name: sup.name, gender: sup.gender){}
            }

            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //get both profiles from server
        if let data = order{
            ClientRequests.getProfile(profileId: data.consumer){
                self.consumer = $0
            }
            ClientRequests.getProfile(profileId: data.supplier){
                self.supplier = $0
            }
        }
    }

    private func updateUI(){
        if ((order != nil) && (consumer != nil) && (supplier != nil)){
            //set all necessary variables
            //consumer vars
            consumerName.text = consumer!.name
            consumerHandle.text = consumer!.handle
            DispatchQueue.global().async { [weak self] in
                let url = URL(string: self!.consumer!.profilePicture)
                if let imageData = try? Data(contentsOf: url!) {
                    DispatchQueue.main.async {
                        if url == URL(string: self!.consumer!.profilePicture){
                            self!.consumerProfPic.image = UIImage(data: imageData)
                        }
                    }
                }
            }

            //supplier vars
            if supplier?.id != 1{
                supplierName.text = supplier!.name
                supplierHandle.text = supplier!.handle
                DispatchQueue.global().async { [weak self] in
                    let url = URL(string: self!.supplier!.profilePicture)
                    if let imageData = try? Data(contentsOf: url!) {
                        DispatchQueue.main.async {
                            if url == URL(string: self!.consumer!.profilePicture){
                                self!.supplierProfPic!.image = UIImage(data: imageData)
                            }
                        }
                    }
                }
            }else if !actionPossible{
                supplierName.text = "unfilled"
                supplierHandle.text = ""
            }

            //other vars
            dormName.text = order!.location
            if let building = order?.location{
                DispatchQueue.global().async { [weak self] in
                    let url = "https://student-life.williams.edu/files/2014/02/" + building + ".jpg"
                    if let imageData = try? Data(contentsOf: URL(string: url)!) {
                        DispatchQueue.main.async {
                            if url == "https://student-life.williams.edu/files/2014/02/" + (self?.order?.location)! + ".jpg"{
                                self?.dormImage?.image = UIImage(data: imageData)
                            }
                        }
                    }
                }
            }
            descript.text = "Description: \(order!.description)"
            price.text = "$\(order!.price)"
            folded.text = order!.folded ? "Folded": "Unfolded"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


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
