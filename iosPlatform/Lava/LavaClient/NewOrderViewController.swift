//
//  NewOrderViewController.swift
//  LavaClient
//
//  Copyright © 2018 JNJ. All rights reserved.
//

import UIKit

class NewOrderViewController: UIViewController{

    var profile: Profile?

    //ToDo: make this a dropdown list of possible dorms
    @IBOutlet weak var dorm: UITextField!

    //updates suggested price when switch flipped
    @IBOutlet weak var folded: UISwitch!
    @IBAction func switched(_ sender: UISwitch) {
        price.text = sender.isOn ? "20": "10"
    }

    @IBOutlet weak var descript: UITextField!

    //mandates can only type numbers into price text field
    @IBOutlet weak var price: UITextField!
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
//        return string.rangeOfCharacter(from: invalidCharacters) == nil
//    }

    @IBAction func complete(_ sender: UIButton) {
        if let p = profile,
            let loc = dorm.text,
            let pr = Int(price.text ?? ""){
            let desc = descript.text ?? ""
            ClientRequests.addOrder(consumer: p.id, location: loc, price: pr, folded: folded.isOn, description: desc){}
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        price.keyboardType = .numberPad
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let prof = profile{
            dorm.text = prof.dorm
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
