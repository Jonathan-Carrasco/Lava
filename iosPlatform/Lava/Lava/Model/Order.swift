//
//  Order.swift
//  Lava
//
//  Copyright © 2018 JNJ. All rights reserved.
//

import Foundation

/*
 This represents an order.
 An order is either open or closed.
 An order has a location, consumer, optional supplier, time (including duration), description, and a price
 */
public struct Order: Codable{
    //ToDo: Add time when order was posted/created

    let orderID: Int
    let consumer: Int
    var supplier: Int
    var location: String
    var price: Int
    var folded: Bool
    var description: String
    //time interval?
    var open: Bool

    public init(orderID: Int, consumer: Int, supplier: Int, location: String, price: Int=10, folded: Bool, description: String, open: Bool=true){
        self.orderID = orderID
        self.consumer = consumer
        self.supplier = supplier
        self.location = location
        self.price = price
        self.folded = folded
        self.description = description
        self.open = open
    }


}
