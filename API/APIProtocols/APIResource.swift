//
//  APIResource.swift
//
//  Created by Adam Neuses on 6/28/21.
//
import Foundation

/// APIResource is just a generic way to say: "What model type is returned? What's the URL? What HTTP method is it?"
///
/// - `url`: The URL of the API
/// - `method`: HTTP Method (GET, POST, PUT, etc.)
/// - `ModelType`: what does the data returned from the API look like?
///
/// - Tag: APIResource
protocol APIResource {
    var url: URL { get }
    var method: String { get }
    associatedtype ModelType: Decodable
}
