//
//  ToDoDataBase.swift
//  ToDoServer
//
//  Copyright © 2018 JNJ. All rights reserved.
//

import Foundation
import SQLite

/**
 A Database-backed list of ToDoItems.
 */
public class LaundryService {

  /// The connection to the database -- create once and use for
  /// all queries.
  private let db : Connection!

  // The table and columns we have.
  private let profiles = Table("profiles")
  private let id = Expression<Int>("id")
  private let handle = Expression<String>("handle")
  private let accountBalance = Expression<Int>("accountBalance")
  private let profilePicture = Expression<String>("profilePicture")
  private let birthDate = Expression<String>("birthDate")
  private let dorm = Expression<String>("dorm")
  private let name = Expression<String>("name")
  private let gender = Expression<String>("gender")
  //also has orderHistory
  //also has openOrders

  private let orders = Table("orders")
  private let orderID = Expression<Int>("orderID")
  private let consumer = Expression<Int>("consumer")
  private let supplier = Expression<Int>("supplier")
  private let location = Expression<String>("location")
  private let price = Expression<Int>("price")
  private let folded = Expression<Bool>("folded")
  private let description = Expression<String>("description")
  private let open = Expression<Bool>("open")

  /// Creates the new LaundryService, and initializes the database tables
  /// if they do not already exist.
  public init() {
    do {

      // Create DB in user's doc directory.
      let path = NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true).first!

      self.db = try? Connection("\(path)/db.sqlite3")

      // CREATE TABLE "profiles" (
      //     "id"      INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      //     "handle"    TEXT NOT NULL,
      //     "accountBlance" INT NOT NULL,
      //     "profilePicture"    TEXT NOT NULL
      //     "birthDate"    TEXT NOT NULL
      //     "dorm"    TEXT NOT NULL
      //     "name"    TEXT NOT NULL
      //     "gender"    TEXT NOT NULL

      // )
      try db.run(profiles.create(ifNotExists: true) { t in
        t.column(id, primaryKey: .autoincrement)
        t.column(handle)
        t.column(accountBalance)
        t.column(profilePicture)
        t.column(birthDate)
        t.column(dorm)
        t.column(name)
        t.column(gender)
      })

      // Need to do this only if you create the table...
      if findProfile(id: 1) == nil {
        //insert in the null profile
        let insert = profiles.insert(
          self.handle <- "null",
          self.accountBalance <- 0,
          self.profilePicture <- "",
          self.birthDate <- "",
          self.dorm <- "",
          self.name <- "",
          self.gender <- "fish"
        )
        try db.run(insert)
      }
        //for testing purposes
        if findProfile(id: 2) == nil{
            //insert in a profile to test with
            let insert = profiles.insert(
                self.handle <- "nevinbernet",
                self.accountBalance <- 100000,
                self.profilePicture <- "https://wso.williams.edu/pic/nsb2",
                self.birthDate <- "10/28/1997",
                self.dorm <- "Currier",
                self.name <- "Nevin Bernet",
                self.gender <- "male"
            )
            try db.run(insert)
        }

      // CREATE TABLE "orders" (
      //     "orderID"      INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      //     "consumer"    INT NOT NULL,
      //     "supplier" INT NOT NULL,
      //     "location"    TEXT NOT NULL
      //     "price"    INT NOT NULL
      //     "folded"    BOOL NOT NULL
      //     "description"    TEXT NOT NULL
      //     "open"    BOOL NOT NULL

      // )
      try db.run(orders.create(ifNotExists: true) { t in
        t.column(orderID,primaryKey: .autoincrement)
        t.column(consumer)
        t.column(supplier)
        t.column(location)
        t.column(price)
        t.column(folded)
        t.column(description)
        t.column(open)
      })
    } catch let e {
      assertionFailure("Couldn't create Database connection: \(e)")
    }
  }

  /// The profile items
  public var profileItems : [Profile] {
    // SELECT * from "profiles"
    if let rows = try? db.prepare(profiles) {
      // convert each database Row object into a Profile
      return rows.map { (row : Row) in
        Profile(
          id: row[id],
          handle: row[handle],
          accountBalance: row[accountBalance],
          profilePicture: row[profilePicture],
          birthDate: row[birthDate],
          dorm: row[dorm],
          name: row[name],
          gender: row[gender]
        )
      }
    } else {
      return []
    }
  }

  /// The profile items
  public var orderItems : [Order] {
    // SELECT * from "Orders"
    get{
        if let rows = try? db.prepare(orders) {
          // convert each database Row object into an Order
          return rows.map { (row : Row) in
            Order(
              orderID: row[orderID],
              consumer: row[consumer],
              supplier: row[supplier],
              location: row[location],
              price: row[price],
              folded: row[folded],
              description: row[description],
              open: row[open]
            )
          }
        } else {
          return []
        }
    }
  }

  /**
   Create a new profile.

   **Modifies**: Self

   **Effects**: Adds a new profile to profileItems

   - Parameter handle: the profile's handle.
   - Parameter accountBalance: Amount of money someone has.
   - Parameter profilePicture: String representation of a URL to an image
   - Parameter birthDate: person's birthday
   - Parameter dorm: Person's dorm
   - Parameter name: Person's name
   - Parameter gener: Person's gender
   - Returns: true if successful.
   */
  public func insertProfile(handle : String, accountBalance : Int, profilePicture : String, birthDate: String, dorm: String, name: String, gender: String) -> Bool {
    // INSERT INTO "profiles" ("handle", "accountBalance", "profilePicture", "birthDate", "dorm", "name", "gender") VALUES (handle, accountBalance, profilePicture, birthDate, dorm, name, gender)
    let insert = profiles.insert(
      self.handle <- handle,
      self.accountBalance <- accountBalance,
      self.profilePicture <- profilePicture,
      self.birthDate <- birthDate,
      self.dorm <- dorm,
      self.name <- name,
      self.gender <- gender
    )
    if let _ = try? db.run(insert) {
      return true
    } else {
      return false
    }
  }

  /**
   Create a new order.

   **Modifies**: Self

   **Effects**: Adds a new order to orderItems

   - Parameter task: the task in question.
   - Parameter done: Whether it is done or not.
   - Parameter created: When the task was created
   - Returns: true if successful.
   */
  public func insertOrder(consumer : Int, supplier : Int, location : String, price: Int, folded: Bool, description: String, open: Bool) -> Bool {
    // INSERT INTO "orders" ("consumer", "supplier", "location", "price", "folded", "description", "open") VALUES (consumer, supplier, location, price, folded, description, open)
    let insert = orders.insert(
      self.consumer <- consumer,
      self.supplier <- supplier,
      self.location <- location,
      self.price <- price,
      self.folded <- folded,
      self.description <- description,
      self.open <- open
    )
    if let _ = try? db.run(insert) {
      return true
    } else {
      return false
    }
  }

  /**
   - Returns: the profile with the given id, or nil if not found.
   */
  public func findProfile(id profileID: Int) -> Profile? {
    do {
      // SELECT * FROM "users"
      // WHERE ("id" = profileID)
      // LIMIT 1
      if let row = try db.pluck(profiles.filter(id == profileID)) {
        return Profile(
          id: row[id],
          handle: row[handle],
          accountBalance: row[accountBalance],
          profilePicture: row[profilePicture],
          birthDate: row[birthDate],
          dorm: row[dorm],
          name: row[name],
          gender: row[gender]
        )
      } else {
        return nil
      }
    } catch _ {
      return nil
    }
  }

  /**
   - Returns: the order with the given id, or nil if not found.
   */
  public func findOrder(id thisID: Int) -> Order? {
    do {
      // SELECT * FROM "orders"
      // WHERE ("orderID" = thisID)
      // LIMIT 1
      if let row = try db.pluck(orders.filter(orderID == thisID)) {
        return Order(
          orderID: row[self.orderID],
          consumer: row[consumer],
          supplier: row[supplier],
          location: row[location],
          price: row[price],
          folded: row[folded],
          description: row[description],
          open: row[open]
        )
      } else {
        return nil
      }
    } catch _ {
      return nil
    }
  }

    //returns open orders relevant to profile (this relavance is unimportant until more complexity necessary)
    public func findOpenOrders(profileID: Int) -> [Order] {
        // SELECT * FROM "orders"
        // WHERE ("supplier" = the null profile(id=1) && open = true)
        if let rows = try? db.prepare(orders.filter(supplier == 1 && open == true)) {
            // convert each open order into an Order item
            return rows.map { (row : Row) in
                Order(
                    orderID: row[self.orderID],
                    consumer: row[consumer],
                    supplier: row[supplier],
                    location: row[location],
                    price: row[price],
                    folded: row[folded],
                    description: row[description],
                    open: row[open]
                )
            }
        } else {
            return []
        }
    }

  public func findOrdersByProfile(profileID: Int, openStatus: Bool) -> [Order] {
    // SELECT * FROM "orders"
    // WHERE ("consumer" = profileID)
    if let rows = try? db.prepare(orders.filter((consumer == profileID || supplier == profileID) && open == openStatus)) {
      // convert each order of openStatus for a profile id into an Order item
      return rows.map { (row : Row) in
        Order(
          orderID: row[self.orderID],
          consumer: row[consumer],
          supplier: row[supplier],
          location: row[location],
          price: row[price],
          folded: row[folded],
          description: row[description],
          open: row[open]
        )
      }
    } else {
      return []
    }
  }

  /**
   Updates an existing profile.

   **Modifies**: Self

   **Effects**: Modifies the profile with the given id

   - Parameter handle: the profile's handle.
   - Parameter accountBalance: Amount of money someone has.
   - Parameter profilePicture: String representation of a URL to an image
   - Parameter birthDate: person's birthday
   - Parameter dorm: Person's dorm
   - Parameter name: Person's name
   - Parameter gener: Person's gender
   - Returns: true if the profile was found and updated, and false otherwise.
   */
  public func updateProfile(
    id profileID: Int,
    handle : String,
    accountBalance : Int,
    profilePicture : String,
    birthDate : String,
    dorm : String,
    name : String,
    gender : String
    ) -> Bool {
    do {
      // UPDATE "profiles" SET "handle", "accountBalance", "profilePicture", "birthDate", "dorm", "name", "gender" = handle, accountBalance, profilePicture, birthDate, dorm, name, gender
      // WHERE ("id" = profileID)
      try db.run(profiles.filter(id == profileID).update(
        self.handle <- handle,
        self.accountBalance <- accountBalance,
        self.profilePicture <- profilePicture,
        self.birthDate <- birthDate,
        self.dorm <- dorm,
        self.name <- name,
        self.gender <- gender
      ))
      return true
    } catch _ {
      return false
    }
  }

  /**
   Updates an existing order.

   **Modifies**: Self

   **Effects**: Modifies the profile with the given id

   - Parameter handle: the profile's handle.
   - Parameter accountBalance: Amount of money someone has.
   - Parameter profilePicture: String representation of a URL to an image
   - Parameter birthDate: person's birthday
   - Parameter dorm: Person's dorm
   - Parameter name: Person's name
   - Parameter gener: Person's gender
   - Returns: true if the profile was found and updated, and false otherwise.
   */
  public func updateOrder(
    id thisID: Int,
    consumer : Int,
    supplier : Int,
    location : String,
    price: Int,
    folded: Bool,
    description: String,
    open: Bool
    ) -> Bool {
    do {
      // UPDATE "orders" SET "handle", "accountBalance", "profilePicture", "birthDate", "dorm", "name", "gender" = handle, accountBalance, profilePicture, birthDate, dorm, name, gender
      // WHERE ("id" = profileID)
      try db.run(orders.filter(orderID == thisID).update(
        self.consumer <- consumer,
        self.supplier <- supplier,
        self.location <- location,
        self.price <- price,
        self.folded <- folded,
        self.description <- description,
        self.open <- open
      ))
      return true
    } catch _ {
      return false
    }
  }

  /**
   Removes an existing profile.

   **Modifies**: Self

   **Effects**: Removes the profile with the given id

   - Parameter id: unique id of the profile we wish to remove
   - Returns: true if the profile was found and deleted, and false otherwise.
   */
  public func deleteProfile(id profileID: Int) -> Bool {
    do {
      // DELETE FROM "profiles" WHERE ("id" = profileID)
      return try db.run(profiles.filter(id == profileID).delete()) != 0
    } catch _ {
      return false
    }
  }

  /**
   Removes an existing order.

   **Modifies**: Self

   **Effects**: Removes the order with the given id

   - Parameter id: unique id of the order we wish to remove
   - Returns: true if the order was found and deleted, and false otherwise.
   */
  public func deleteOrder(id thisID: Int) -> Bool {
    do {
      // DELETE FROM "order" WHERE ("id" = orderID)
      return try db.run(orders.filter(thisID == orderID).delete()) != 0
    } catch _ {
      return false
    }
  }
}
