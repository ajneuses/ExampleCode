//
//  NetworkRequest.swift
//
//  Created by Adam Neuses on 6/28/21.
//
import Foundation

/// NetworkRequest is going to be our general protocol that
/// all our API network requests will have to conform to.
///
/// These requests all need a Model Type (CO2 data, Paris Accord data, Renewable Data)
/// that they are trying to get. And they also need a load function to get the data.
///
/// - Tag: NetworkRequest

protocol NetworkRequest: AnyObject {
    
    
    /// The model of the reponse returned from the Network request (generally from
    /// an API)
    ///
    /// We need this so that we can try to [decode()](x-source-tag://NetworkRequest.decode)
    /// the response from the request inside the [load(url: )](x-source-tag://NetworkRequst.load)
    /// funciton
    
    associatedtype ModelType

    
    /// Decode the data returned from a network request (generally an API
    /// Request). To account for possible errors in the API, either return the
    ///
    /// - Returns: Optional __ModelType__ associated type. If the data is bad
    /// this should return nil so the app doesn't crash
    ///
    /// - Tag: NetworkRequest.decode

    func decode(_ data: Data) -> ModelType?
    
    
    /// See the default implementation of this function [here](x-source-tag://NetworkRequst.load)

    func load(url: URL,
              method: String,
              params: [String: String]?,
              validStatusCodes: [Int]?,
              withCompletion completion: @escaping (Result<ModelType, APIError>) -> Void)
}
///
// MARK: ------------------------------ default protocol implementations
///
///
///
extension NetworkRequest {
    
    /// Make a network request
    ///
    /// The `url` and `method` will come from [APIResource](x-source-tag://APIResource)
    ///
    /// - Important: Only call this method from [APIRequest](x-source-tag://APIRequest)
    /// when you make an API call with
    ///
    /// - Parameters:
    ///   - url: The url you're making the request to
    ///   - method: HTTP method type. GET, POST, PUT, etc.
    ///   - params: body parameters if necessary for POST or PUT requests
    ///   - validStatusCodes: an array of HTTP status codes that signify a valid response
    ///   - completion: handler for the response from the request
    ///
    /// - Tag: NetworkRequst.load
    func load(url: URL,
              method: String,
              params: [String: String]?,
              validStatusCodes: [Int]?,
              withCompletion completion: @escaping (Result<ModelType, APIError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let bodyParams = params {
            // let bodyData = try? JSONSerialization.data(withJSONObject: bodyParams) {
            var body = ""
            for bodyParam in bodyParams {
                body.append("\(bodyParam.key)=\(bodyParam.value)")
            }
            request.httpBody = body.data(using: .utf8)
        }
        // print("🥬🥬🥬", request.url, request.httpMethod, params ?? "No params", separator: "\n")
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: request,
                                    completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            guard error == nil else {
                completion(.failure(.other(error: error!)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidURLResponse))
                return
            }
            
            /// If the HTTP status code doesn't match what is considered __valid__,
            /// then return an error
            if let validStatusCodes = validStatusCodes,
               validStatusCodes.contains(httpResponse.statusCode) == false {
                completion(
                    .failure(
                        APIError.statusCode(
                            message: "HTTP returned status code \(httpResponse.statusCode)"
                        )
                    )
                )
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.emptyBody))
                return
            }
            
            guard let model = self.decode(data) else {
                completion(.failure(APIError.decodingError))
                return
            }
            
            completion(.success(model))
        })
        task.resume()
    }
}


// TODO: - Completion with Error type
enum APIError: Error {
    case invalidURLResponse
    case statusCode(message: String)
    case emptyBody
    case decodingError
    case other(error: Error)
}
