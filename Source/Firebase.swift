//
//  Firebase.swift
//  FirebaseSwift
//
//  Created by Graham Chance on 10/15/16.
//
//

import Foundation
import Just


private enum Method: String {
    case delete = "DELETE"
    case post = "POST"
    case get = "GET"
    case patch = "PATCH"
    case put = "PUT"
}

public class Firebase {

    
    /// Auth token
    public var auth: String?
    
    /// Base URL (e.g. http://myapp.firebaseio.com)
    public let baseURL: String
    
    /// Timeout of http operations
    public let timeout: Double = 30.0 // seconds

    private let headers = ["Accept": "application/json"]


    
    /// Constructor
    ///
    /// - Parameters:
    ///   - baseURL: Base URL (e.g. http://myapp.firebaseio.com)
    ///   - auth: Auth token
    public init(baseURL: String = "", auth: String? = nil) {
        self.auth = auth

        var url = baseURL
        if url.characters.last != Character("/") {
            url.append(Character("/"))
        }
        self.baseURL = url

    }

    
    /// Performs a synchronous PUT at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to base url
    ///   - value: value to PUT
    /// - Returns: resulting data
    public func setValue(path: String, value: Any)->[String: AnyObject]? {
        return put(path: path, value:  value)
    }

    
    /// Performs an asynchronous PUT at base url plus given path
    ///
    /// - Parameters:
    ///   - path: path to append to base url
    ///   - value: value to PUT
    ///   - complete: callback containing resulting data as a parameter
    public func setValueAsync(path: String, value: Any, complete: @escaping ([String: AnyObject]?)->()) {
        putAsync(path: path, value:  value, complete: complete)
    }

    
    /// Performs a synchronous POST at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: value to post
    /// - Returns: resulting data
    public func post(path: String, value: Any)->[String: AnyObject]? {
        return write(value: value, path: path, method: .post, complete: nil)
    }

    
    /// Performs an asynchronous POST at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: value to post
    ///   - complete: callback containing resulting data as a parameter
    public func postAsync(path: String, value: Any, complete: @escaping ([String: AnyObject]?)->()) {
        let _ = write(value: value, path: path, method: .post, complete: complete)
    }

    
    /// Performs a synchronous PUT at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: value to put
    /// - Returns: resulting data
    public func put(path: String, value: Any)->[String: AnyObject]? {
        return write(value: value, path: path, method: .put, complete: nil)
    }

    
    /// Performs an asynchronous PUT at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: value to put
    ///   - complete: callback containing resulting data as a parameter
    public func putAsync(path: String, value: Any, complete: @escaping ([String: AnyObject]?)->()) {
        let _ = write(value: value, path: path, method: .put, complete: complete)
    }

    
    /// Performs a synchronous PATCH at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: value to put
    /// - Returns: resulting data
    public func patch(path: String, value: Any)->[String: AnyObject]? {
        return write(value: value, path: path, method: .patch, complete: nil)
    }

    
    /// Performs an asynchronous PATCH at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - value: value to put
    ///   - complete: callback containing resulting data as a parameter
    public func patchAsync(path: String, value: Any, complete: @escaping ([String: AnyObject]?)->()) {
        let _ = write(value: value, path: path, method: .patch, complete: complete)
    }

    
    /// Performs a synchronous DELETE at given path from the base url
    ///
    /// - Parameter path: path to append to the base url
    /// - Returns: deleted data
    public func delete(path: String)->[String: AnyObject]? {
        return delete(path: path, complete: nil)
    }

    
    /// Performs an asynchronous DELETE at given path from the base url
    ///
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - complete: callback containing deleted data as a parameter
    public func deleteAsync(path: String, complete: @escaping ([String: AnyObject]?)->()) {
        let _ = delete(path: path, complete: complete)
    }

    
    /// Performs a synchronous GET at given path from the base url
    ///
    /// - Parameter path: path to append to the base url
    /// - Returns: data at the path location
    public func get(path: String)->Any? {
        return get(path: path, complete: nil)
    }

    
    /// Performs an asynchronous GET at given path from the base url
    ///
    /// - Parameters:
    ///   - path: path to append to the base url
    ///   - complete: callback containing the resulting data as a parameter
    public func getAsync(path: String, complete: @escaping (Any?)->()) {
        let _ = get(path: path, complete: complete)
    }


    private func delete(path: String, complete: (([String: AnyObject]?)->())?)->[String: AnyObject]? {

        let url = completeURLWithPath(path: path)

        var completionHandler: ((HTTPResult)->())? = nil
        if let complete = complete {
            completionHandler = { result in
                complete(self.process(httpResult: result, method: .delete))
            }
        }

        let result = Just.delete(url, params: [:], data: [:], json: nil, headers: headers,
                                 files: [:], auth: nil, cookies: [:], allowRedirects: false,
                                 timeout: timeout, URLQuery: nil, requestBody: nil,
                                 asyncProgressHandler: nil, asyncCompletionHandler: completionHandler)

        if let error = result.error {
            print("DELETE Error: \(error.localizedDescription)")
            return nil
        }

        do {
            if let jsonMap = try result.contentAsJSONMap() as? [String: AnyObject] {
                return jsonMap
            }
        } catch let e {
            print("DELETE Error: \(e.localizedDescription)")
        }

        guard complete == nil else { return nil }
        return process(httpResult: result, method: .delete)
    }


    private func get(path: String, complete: ((Any?)->())?)->Any? {

        let url = completeURLWithPath(path: path)

        var completionHandler: ((HTTPResult)->())? = nil
        if let complete = complete {
            completionHandler = { result in
                complete(self.process(httpResult: result, method: .get))
            }
        }

        let httpResult = Just.get(url, params: [:], data: [:], json: nil, headers: headers,
                                  files: [:], auth: nil, cookies: [:], allowRedirects: false,
                                  timeout: timeout, URLQuery: nil, requestBody: nil,
                                  asyncProgressHandler: nil, asyncCompletionHandler: completionHandler)

        guard complete == nil else { return nil }
        return process(httpResult: httpResult, method: .get)
    }


    private func write(value: Any, path: String, method: Method, complete: (([String: AnyObject]?)->())?)->[String: AnyObject]? {

        let url = completeURLWithPath(path: path)
        let json: Any? = JSONSerialization.isValidJSONObject(value) ? value : [".value": value]

        var completionHandler: ((HTTPResult)->())? = nil
        if let complete = complete {
            completionHandler = { result in
                complete(self.process(httpResult: result, method: method))
            }
        }

        let result: HTTPResult!
        switch method {
        case .put:
            result = Just.put(url, params: [:], data: [:], json: json, headers: headers,
                              files: [:], auth: nil, cookies: [:], allowRedirects: false,
                              timeout: timeout, URLQuery: nil, requestBody: nil,
                              asyncProgressHandler: nil, asyncCompletionHandler: completionHandler)
        case .post:
            result = Just.post(url, params: [:], data: [:], json: json, headers: headers,
                               files: [:], auth: nil, cookies: [:], allowRedirects: false,
                               timeout: timeout, URLQuery: nil, requestBody: nil,
                               asyncProgressHandler: nil, asyncCompletionHandler: completionHandler)
        case .patch:
            result = Just.patch(url, params: [:], data: [:], json: json, headers: headers,
                                files: [:], auth: nil, cookies: [:], allowRedirects: false,
                                timeout: timeout, URLQuery: nil, requestBody: nil,
                                asyncProgressHandler: nil, asyncCompletionHandler: completionHandler)
        default:
            return nil
        }

        guard complete == nil else { return nil }
        return process(httpResult: result, method: method)
    }


    private func completeURLWithPath(path: String)->String {
        var url = baseURL + path + ".json"
        if let auth = auth {
            url += "?auth=" + auth
        }
        return url
    }

    private func process(httpResult: HTTPResult, method: Method)->[String: AnyObject]? {
        if let error = httpResult.error {
            print(method.rawValue + " Error: " + error.localizedDescription)
            return nil
        }

        do {
            if let jsonMap = try httpResult.contentAsJSONMap() as? [String: AnyObject] {
                return jsonMap
            }
        } catch let e {
            print(method.rawValue + " Error: " + e.localizedDescription)
        }
        return nil
    }

}
