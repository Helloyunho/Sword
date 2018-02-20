//
//  Request.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

extension Sword {
  /// Makes an HTTP Request to the land of Discord's API
  ///
  /// - parameter endpoint: The specific endpoint to request
  func request(
    _ endpoint: Endpoint,
    then: @escaping (Data?, RequestError?) -> ()
  ) {
    /// Setup request
    var request = URLRequest(url: URL(string: endpoint.url)!)
    request.httpMethod = endpoint.method.rawValue
    request.addValue(
      "DiscordBot (https://github.com/Azoy/Sword, 1.0.0)",
      forHTTPHeaderField: "User-Agent"
    )
    
    /// Authorize this request with the bot's token
    request.addValue("Bot " + token, forHTTPHeaderField: "Authorization")
    
    /// Setup data task
    let task = session.dataTask(with: request) {
      [unowned self] data, response, error in
      
      /// Handle any errors that happened during the request
      guard error == nil else {
        then(nil, RequestError(error!.localizedDescription))
        self.requestSema.signal()
        return
      }
      
      /// Handle the response first to do things like rate limiting
      guard let response = response as? HTTPURLResponse else {
        then(nil, RequestError("Unable to get a correct HTTP response."))
        self.requestSema.signal()
        return
      }
      
      self.handleRequestResponse(response, then)
      
      /// Make sure we can safely unwrap the data
      guard let data = data else {
        then(nil, RequestError("Unable to safely extract received data."))
        self.requestSema.signal()
        return
      }
      
      then(data, nil)
      self.requestSema.signal()
    }
    
    task.resume()
    
    requestSema.wait()
  }
  
  /// Handles what to do when a request is complete (rate limiting)
  ///
  /// - parameter response: The http response from the Discord
  func handleRequestResponse(
    _ response: HTTPURLResponse,
    _ then: @escaping (Data?, RequestError?) -> ()) {
    print("Get pranked")
  }
  
}
