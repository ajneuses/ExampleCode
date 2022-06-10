//
//  APIRequest.swift
//
//  Created by Adam Neuses  on 6/28/21.
//
import Foundation

// MARK: ------------------------------ APIRequest
///
/// Generall class representing a request to an API
///
/// What makes up an API Request? You need a __url, HTTP method
/// and valid data in the HTTP response__. This class gets that necessary information
/// from the [APIResource](x-source-tag://APIResource) class and
/// implements the [NetworkRequest](x-source-tag://NetworkRequest)
/// protocol so that it can make the request and decode the returned data.
///
/// - Tag: APIRequest
class APIRequest<T: APIResource> {


    /// The generic [APIResource](x-source-tag://APIResource) used
    /// for an API request
    let resource: T
    
    
    /// If the API request is a POST or PUT, this is the variable that stores
    /// the parameters used in the body of the HTTP request.
    private(set) var params: [String: String]?
    
    
    /// When the HTTP reponse returns, validate the status code is correct
    /// with this variables.
    ///
    /// If you want to check that the status codes are OK, set this variable
    /// with the (validate(statusCodes: ))[x-source-tag://validate(statusCodes)]
    /// or (validate(statusCode: ))[x-source-tag://validate(statusCode)]
    /// __BEFORE calling the [callAPI()](x-source-tag://callAPI) function!__
    ///
    /// - Tag: validHTTPStatusCodes
    private(set) var validHTTPStatusCodes: [Int]?
    ///
    ///
    ///
    init(resource: T) {
        self.resource = resource
    }
}


// MARK: ---------------------------- NetworkRequest


extension APIRequest: NetworkRequest {


    /// Check the `decode()` [function in NetworkRequest](x-source-tag://NetworkRequest.decode)
    /// for more details on why this returns an optional type
    ///
    /// - Tag: decode(data: )
    func decode(_ data: Data) -> T.ModelType? {
        let model = try? JSONDecoder().decode(T.ModelType.self, from: data)
        return model
    }
    
    
    /// - Tag: addBodyParameters
    func addBodyParameters(_ params: [String: String]) -> Self {
        self.params = params
        return self
    }
    
    /// Set the HTTP status codes that are considered "successful" for
    /// this API request.
    ///
    /// If you want to check the HTTP status codes when the API reponse
    /// returns, you should call this function __BEFORE calling the__
    /// [callAPI](x-source-tag://callAPI) __function!__
    ///
    ///```
    /// APIRequest(resource: ...)
    ///     .validate(statusCode: [200])
    ///     .callAPI {
    ///
    ///     }
    ///```
    ///
    /// - Tag: validate(statusCodes)
    func validate(statusCodes: [Int]) -> Self {
        self.validHTTPStatusCodes = statusCodes
        return self
    }
    
    /// Set just one HTTP status code that is considered "successful" for
    /// this API request.
    ///
    /// If you want to check the HTTP status codes when the API reponse
    /// returns, you should call this function __BEFORE calling the__
    /// [callAPI](x-source-tag://callAPI) __function!__
    ///
    ///```
    /// APIRequest(resource: ...)
    ///     .validate(statusCode: 200)
    ///     .callAPI {
    ///
    ///     }
    ///```
    ///
    /// - Tag: validate(statusCode)
    func validate(statusCode: Int) -> Self {
        self.validHTTPStatusCodes = [statusCode]
        return self
    }


    /// Make the API call
    ///
    /// This is essnetially just calling the [load()](x-source-tag://NetworkRequest.load)``
    ///
    /// - Parameters:
    ///   - params: optional body parameters for POST and PUT requests
    ///   - completion: handler for the response from the API
    ///
    /// - Tag: callAPI
    func callAPI(withCompletion completion: @escaping (Result<T.ModelType, APIError>) -> Void) {
        self
            .load(url: self.resource.url,
                  method: self.resource.method,
                  params: self.params,
                  validStatusCodes: self.validHTTPStatusCodes,
                  withCompletion: completion)
    }
}
