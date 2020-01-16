//
//  TodoServerTableViewController.swift
//  ToDoServer
//
//  Copyright © 2018 JNJ. All rights reserved.
//

import UIKit
import Swifter
import SQLite


/**
 The server for our ToDo App.  This server recognizes the endpoints specified
 in REST.md.  It uses an SQL database to store todo items.

 This server makes use of two additional frameworks:

 - SQLite: Swift wrappers for an sqllite database.
 - Swifter: an HTTP Server.  I have modified Swifter in several small ways to
 better support logging of requests/responses.

 */
class LaundryServerTableViewController: UITableViewController, HttpServerIODelegate {

    /// The http server that handles network requests
    private let server: HttpServer = HttpServer()

    /// Our "service" that manages our profiles and order items
    private let laundryData : LaundryService = LaundryService()

    // MARK: - ViewController Lifecycle

    /**
     Sets up the controller after it is loaded.

     **Modifies**: Self

     **Effects**: Installs handlers for endpoints and starts the server.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        server.delegate = self

        server.POST["/profiles"]   = { self.addProfile($0) }
        server.POST["/orders"]   = { self.addOrder($0) }
        server.GET["/profiles"]    = { self.getProfile($0) }
        server.GET["/orders"]    = { self.getOpenOrders($0) }
        server.GET["/profileOrders"] = { self.getOrdersForProfile($0) }
        server.PUT["/profiles"]    = { self.updateProfile($0) }
        server.PUT["/orders"]    = { self.updateOrder($0) }
        server.DELETE["/profiles"] = { self.deleteProfile($0) }
        server.DELETE["/orders"] = { self.deleteOrder($0) }

        do {
            try server.start(9080)
        } catch let e {
            print("Failed to start server: \(e)")
            abort()
        }
    }

    // MARK: - Endpoint handlers

    /**
     Adds a new profile item.

     **Modifies**: Self

     **Effects**: Inserts a new profile item into our list, using the
     information encoded in the request parameters

     - Parameter request: The request given to us by the server.
     - Returns: The response we create, either .ok, or .badRequest...
     */
    private func addProfile(_ request: HttpRequest) -> HttpResponse {
        let params = request.queryParamsAsMap
        if let handle = params["handle"],
            let accountBalance = Int(params["accountBalance"] ?? ""),
            let profilePicture = params["profilePicture"],
            let birthDate = params["birthDate"],
            let dorm = params["dorm"],
            let name = params["name"],
            let gender = params["gender"],
            laundryData.insertProfile(handle: handle, accountBalance: accountBalance, profilePicture: profilePicture, birthDate: birthDate, dorm: dorm, name: name, gender: gender) {
            return .ok(.json(Data()))
        } else {
            return .badRequest(nil)
        }
    }

    /**
     Adds a new order item.

     **Modifies**: Self

     **Effects**: Inserts a new order item into our list, using the
     information encoded in the request parameters

     - Parameter request: The request given to us by the server.
     - Returns: The response we create, either .ok, or .badRequest...
     */
    private func addOrder(_ request: HttpRequest) -> HttpResponse {
        let params = request.queryParamsAsMap
        if let consumer = Int(params["consumer"] ?? ""),
            let supplier = Int(params["supplier"] ?? ""),
            let location = params["location"],
            let price = Int(params["price"] ?? ""),
            let folded = Bool(params["folded"] ?? ""),
            let description = params["description"],
            let open  = Bool(params["open"] ?? ""),
            laundryData.insertOrder(consumer: consumer, supplier: supplier, location: location, price: price, folded: folded, description: description, open: open) {
            return .ok(.json(Data()))
        } else {
            return .badRequest(nil)
        }
    }

    /**
     Create a reponse with the requested profile.

     - Parameter request: The request given to us by the server.
     - Returns: The response we create, with a payload containing
     the JSON for the profile.
     */
    private func getProfile(_ request: HttpRequest) -> HttpResponse {
        let encoder = JSONEncoder()
        encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
        let params = request.queryParamsAsMap
        if let id = Int(params["id"] ?? "") {
            return .ok(.json(try! encoder.encode(laundryData.findProfile(id: id))))
        }
        return .badRequest(nil)
    }

    /**
     Create a reponse with the requested order.

     - Parameter request: The request given to us by the server.
     - Returns: The response we create, with a payload containing
     the JSON for the order.
     */
    private func getOpenOrders(_ request: HttpRequest) -> HttpResponse {
        let encoder = JSONEncoder()
        encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
        let params = request.queryParamsAsMap
        if let id = Int(params["id"] ?? ""){
            return .ok(.json(try! encoder.encode(laundryData.findOpenOrders(profileID: id))))
        }
        return .badRequest(nil)
    }
    //        server.GET["/profileOpenOrder"] = { self.getOpenOrderByProfile($0) }

    /**
     Create a reponse with all the open orders for a profile.

     - Parameter request: The request given to us by the server.
     - Returns: The response we create, with a payload containing
     the JSON for the order.
     */
    private func getOrdersForProfile(_ request: HttpRequest) -> HttpResponse {
        let encoder = JSONEncoder()
        encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
        let params = request.queryParamsAsMap
        if let id = Int(params["id"] ?? ""),
            let orderStatus = Bool(params["orderStatus"] ?? ""){
            return .ok(.json(try! encoder.encode(laundryData.findOrdersByProfile(profileID: id, openStatus: orderStatus))))
        }
        return .badRequest(nil)
    }

    /**
     Updates an existing profile.

     **Modifies**: Self

     - Parameter request: The request given to us by the server.
     - Returns: Either .ok, or .badRequest if
     profile does not exist.
     */
    private func updateProfile(_ request: HttpRequest) -> HttpResponse {
        let params = request.queryParamsAsMap
        if let handle = params["handle"],
            let accountBalance = params["accountBalance"],
            let intAccountBalance = Int(accountBalance),
            let profilePicture = params["profilePicture"],
            let birthDate = params["birthDate"],
            let dorm = params["dorm"],
            let name = params["name"],
            let gender = params["gender"],
            let rowid = Int(params["id"] ?? ""),
            laundryData.findProfile(id: rowid) != nil,
            laundryData.updateProfile(id: rowid, handle: handle, accountBalance: intAccountBalance, profilePicture: profilePicture, birthDate: birthDate, dorm: dorm, name: name, gender: gender) {
            return .ok(.json(Data()))
        } else {
            return .badRequest(nil)
        }
    }

    /**
     Updates an existing order.

     **Modifies**: Self

     - Parameter request: The request given to us by the server.
     - Returns: Either .ok, or .badRequest if
     order does not exist.
     */
    private func updateOrder(_ request: HttpRequest) -> HttpResponse {
        let params = request.queryParamsAsMap
        if let consumer = Int(params["consumer"] ?? ""),
            let supplier = Int(params["supplier"] ?? ""),
            let location = params["location"],
            let price = Int(params["price"] ?? ""),
            let folded = Bool(params["folded"] ?? ""),
            let description = params["description"],
            let open  = Bool(params["open"] ?? ""),
            let rowid = Int(params["id"] ?? ""),
            laundryData.findOrder(id: rowid) != nil,
            laundryData.updateOrder(id: rowid, consumer: consumer, supplier: supplier, location: location, price: price, folded: folded, description: description, open: open) {
            return .ok(.json(Data()))
        } else {
            return .badRequest(nil)
        }
    }

    /**
     Deletes an existing profile.

     **Modifies**: Self

     **Effects**: Modifies a profile, using the
     information encoded in the request parameters

     - Parameter request: The request given to us by the server.
     - Returns: The response we create, either .ok, or .badRequest if
     the parameters were ill-formed or the item does not exist.
     */
    private func deleteProfile(_ request: HttpRequest) -> HttpResponse {
        let params = request.queryParamsAsMap
        if let rowid = Int(params["id"] ?? ""),
            laundryData.findProfile(id: rowid) != nil,
            laundryData.deleteProfile(id: rowid) {
            return .ok(.json(Data()))
        } else {
            return .badRequest(nil)
        }
    }

    /**
     Deletes an existing order.

     **Modifies**: Self

     **Effects**: Modifies an order, using the
     information encoded in the request parameters

     - Parameter request: The request given to us by the server.
     - Returns: The response we create, either .ok, or .badRequest if
     the parameters were ill-formed or the item does not exist.
     */
    private func deleteOrder(_ request: HttpRequest) -> HttpResponse {
        let params = request.queryParamsAsMap
        if let rowid = Int(params["id"] ?? ""){
            print("first")
            if laundryData.findOrder(id: rowid) != nil{
                print("second")
                if laundryData.deleteOrder(id: rowid) {
                    print("third")
                    return .ok(.json(Data()))
                }
            }
        } else {
            return .badRequest(nil)
        }
        return .badRequest(nil)
    }



    // MARK: - Logging

    /// One request of response.
    private enum LogMessage {
        case request(HttpRequest)
        case response(HttpResponse)
    }

    /// An array of all requests/responses processed by the server.
    private var log: [LogMessage] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: self.log.count-1, section: 0), at: .bottom, animated: true)
            }
        }
    }

    // MARK: Delegate methods for HTTP server.

    func socketConnectionReceived(_ socket: Socket) {   }

    /// **Effects**: Adds request to log.
    func requestReceived(_ request: HttpRequest) {
        DispatchQueue.main.async {
            self.log.append(.request(request))
        }
    }

    /// **Effects**: Adds response to log.
    func responseCreated(_ response: HttpResponse) {
        DispatchQueue.main.async {
            self.log.append(.response(response))
        }
    }




    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return log.count
    }

    /// -Returns: The table view cell for the given request/response.  The view
    /// encodes the type of message and ok/bad with colors.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Log", for: indexPath)

        let row = indexPath.row
        switch(log[row]) {
        case .request(let request):
            cell.textLabel?.text = "\(row) \(request.method): \(request.path)"
            cell.textLabel?.textColor = UIColor.black
        case .response(let response):

            switch (response) {
            case .ok(.json(let data)):
                let text = String(data: data, encoding: .utf8) ?? "ERROR"
                cell.textLabel?.text = "\(row) \(response.reasonPhrase()): \(text)"
                cell.textLabel?.textColor = UIColor.blue
            default:
                cell.textLabel?.text = "\(row) \(response.reasonPhrase())"
                cell.textLabel?.textColor = UIColor.red
            }
        }

        return cell

    }
}





private extension HttpRequest {
    /// The parameters in a request, converting to a map.
    var queryParamsAsMap : [String:String] {
        return Dictionary<String,String>(uniqueKeysWithValues: self.queryParams)
    }
}
