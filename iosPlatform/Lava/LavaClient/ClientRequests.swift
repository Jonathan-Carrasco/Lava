//
//  ClientRequests.swift
//  LavaClient
//
//  Copyright © 2018 JNJ. All rights reserved.
//

import Foundation

public class ClientRequests {

  public static let profileID = 1

  //gets open orders
  public static func getOpenOrders(profileId id: Int, completion: @escaping ([Order]) -> Void) {
    if let url = URL(string: "http://localhost:9080/orders?id=\(id)") {
      // since the request may take a while, run in global queue
      DispatchQueue.global().async {
        if let data = try? Data(contentsOf: url) {
          // switch back to main queue to update UI
          DispatchQueue.main.async {
            if let orders = try? JSONDecoder().decode([Order].self, from: data) {
              completion(orders)
            }
          }
        }
      }
    }
  }

    //gets open orders/order history for a specific profile
    public static func getOrdersForProfile(profileId id: Int, orderStatus: Bool, completion: @escaping ([Order]) -> Void) {
        if let url = URL(string: "http://localhost:9080/profileOrders?id=\(id)&orderStatus=\(orderStatus)") {
            // since the request may take a while, run in global queue
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    // switch back to main queue to update UI
                    DispatchQueue.main.async {
                        if let orders = try? JSONDecoder().decode([Order].self, from: data) {
                            completion(orders)
                        }
                    }
                }
            }
        }
    }

    //gets a user profile from an ID
    public static func getProfile(profileId id: Int, completion: @escaping (Profile) -> Void) {
        if let url = URL(string: "http://localhost:9080/profiles?id=\(id)") {
            // since the request may take a while, run in global queue
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    // switch back to main queue to update UI
                    DispatchQueue.main.async {
                        if let profile = try? JSONDecoder().decode(Profile.self, from: data) {
                            completion(profile)
                        }
                    }
                }
            }
        }
    }

  //no supplier param because when we add an order it is always open and has no supplier
  public static func addOrder(consumer: Int, location: String, price:Int, folded: Bool, description: String,
                         completion: @escaping () -> Void) {
    let encodedDesc = description.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let encodedLoc = location.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let route = "orders?consumer=\(consumer)&supplier=1&location=\(encodedLoc)&price=\(price)&folded=\(folded)&description=\(encodedDesc)&open=true"
    sendRequest("POST", route, completion)
  }

    //creates a new profile
    public static func addProfile(handle: String, accountBalance: Int, profilePicture: String, birthDate: String, dorm: String, name: String, gender: String,
                                completion: @escaping () -> Void) {
        let encodedHandle = handle.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let encodedPicture = profilePicture.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let encodedDate = birthDate.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let encodedDorm = dorm.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let route = "profiles?handle=\(encodedHandle)&accountBalance=\(accountBalance)&profilePicture=\(encodedPicture)&birthDate=\(encodedDate)&dorm=\(encodedDorm)&name=\(encodedName)&gender=\(gender)"
        sendRequest("POST", route, completion)
    }

    //deletes an order
    public static func deleteOrder(id: Int,
                                completion: @escaping () -> Void) {
        let route = "orders?id=\(id)"
        sendRequest("DELETE", route, completion)
    }

    //updates an order
    public static func updateOrder(id: Int, consumer: Int, supplier: Int, location: String, price:Int, folded: Bool, description: String, open: Bool,
                                completion: @escaping () -> Void) {
        let encodedDesc = description.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let encodedLoc = location.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let route = "orders?id=\(id)&consumer=\(consumer)&supplier=\(supplier)&location=\(encodedLoc)&price=\(price)&folded=\(folded)&description=\(encodedDesc)&open=\(open)"
        sendRequest("PUT", route, completion)
    }

    //updates a profile
    public static func updateProfile(id: Int, handle: String, accountBalance: Int, profilePicture: String, birthDate: String, dorm: String, name: String, gender: String,
                                  completion: @escaping () -> Void) {
        let encodedHandle = handle.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let encodedPicture = profilePicture.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let encodedDate = birthDate.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let encodedDorm = dorm.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let route = "profiles?id=\(id)&handle=\(encodedHandle)&accountBalance=\(accountBalance)&profilePicture=\(encodedPicture)&birthDate=\(encodedDate)&dorm=\(encodedDorm)&name=\(encodedName)&gender=\(gender)"
        sendRequest("PUT", route, completion)
    }

  // MARK: - REST request sender

  /**
   Send a request via http to the server and run the completion
   handler when the respone comes back or we get an error.

   **Requires**: http method is GET,POST,PUT,DELETE.

   - Parameter httpMethod: One of GET,POST,PUT,DELETE
   - Parameter route: The url of the endpoint we wish to connect to.

   - Parameter completion: The code to run when we are done with
   the request.
   */
  private static func sendRequest(_ httpMethod: String, _ route : String, _ completion: @escaping () -> Void) {

    // construct the http request, including the method
    let url = URL(string: "http://localhost:9080/\(route)")!
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod

    // Use the shared session to run the request as a data task.
    // Not guaranteed to run the handler on originating thread.
    let task = URLSession.shared.dataTask(with: request) {
      data, response, error in
      if error == nil,
        let httpStatus = response as? HTTPURLResponse,
        httpStatus.statusCode == 200 {

        // no error -- good to go!
        completion()

      } else {

        // error -- see if we can get a real message or
        // make a general one
        let message = error?.localizedDescription ?? "Request Failed"
        print(message)

      }
    }

    // this is what actually causes the request to run.
    task.resume()
  }


}
