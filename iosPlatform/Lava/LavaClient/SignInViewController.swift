//
//  SignInViewController.swift
//  LavaClient
//
//  Copyright © 2019 JNJ. All rights reserved.
//

import UIKit
import Foundation

class SignInViewController: UIViewController{

    //the user's profile
    var profile: Profile?



    //if there is a profile in user defaults, then prepare and segue to the dashboard, otherwise force to create account
    override func viewDidLoad() {
        let defaults = UserDefaults.standard

        //account exists
        if let account = defaults.dictionary(forKey: "account"){
            if let id = account["id"] as? Int,
                let handle = account["handle"] as? String,
                let accountBalance = account["accountBalance"] as? Int,
                let profilePicture = account["profilePicture"] as? String,
                let birthDate = account["birthDate"] as? String,
                let dorm = account["dorm"] as? String,
                let name = account["name"] as? String,
                let gender = account["gender"] as? String{

                profile = Profile(id: id, handle: handle, accountBalance: accountBalance, profilePicture: profilePicture, birthDate: birthDate, dorm: dorm, name: name, gender: gender)
                performSegue(withIdentifier: "account exists", sender: self)
            }
        //new user
        }else{
          
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "account exists"{
            if let prof = profile{
                let destination = segue.destination
                if let dashboard = destination as? DashboardViewController{
                    dashboard.profile = prof
                }
            }

        }
    }

}
