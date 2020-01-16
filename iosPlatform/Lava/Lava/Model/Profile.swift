//
//  Profile.swift
//  Lava
//
//  Copyright © 2018 JNJ. All rights reserved.
//

import Foundation
import UIKit

/*
 Each user has a unique profile.
 Each user/profile has a unique string handle.
 A Profile also has an order history, some current, open orders, an account balance, a profile picture, a birth date, a dorm, a name, and a gender
 */
public struct Profile: Codable{

    let id: Int
    public var handle: String
    var accountBalance: Int
    var profilePicture: String
    var birthDate: String
    var dorm: String
    var name: String
    var gender: String

    public init(id: Int, handle: String, accountBalance: Int=0, profilePicture: String, birthDate: String, dorm: String, name: String, gender: String){
        self.id = id
        self.handle = handle
        self.accountBalance = accountBalance
        self.profilePicture = profilePicture
        self.birthDate = birthDate
        self.dorm = dorm
        self.name = name
        self.gender = gender
    }

}
