//
//  ExampleAPIResource.swift
//
//  Created by Adam Neuses on 8/10/21.
//
import Foundation


/// - Tag: ExampleAPIResource
struct ExampleAPIResource: APIResource {
    var url = URL(string: APIConstants.exampleAPIURL)!
    var method = "GET"
    typealias ModelType = ExampleModelType
}
