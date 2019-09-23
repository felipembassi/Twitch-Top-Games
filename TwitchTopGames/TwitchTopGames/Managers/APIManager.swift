//
//  APIManager.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 07/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import Foundation
import UIKit
import Network

protocol Endpoint {
    var base: String { get }
    var path: String { get }
}

extension Endpoint {
    var base: String {
        return K.API.Base.url
        
    }
    
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        return components
    }
    
    var request: URLRequest {
        let url = urlComponents.url!
        return URLRequest(url: url)
    }
}

enum APIError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    case decryptFailed
    case encryptFailed
    case serverError(data: Data)
    
    var localizedDescription: String {
        switch self {
        case .requestFailed: return K.API.ErrorMessage.requestFailed
        case .invalidData: return K.API.ErrorMessage.invalidData
        case .responseUnsuccessful: return K.API.ErrorMessage.responseUnsuccessful
        case .jsonParsingFailure: return K.API.ErrorMessage.jsonParsingFailure
        case .jsonConversionFailure: return K.API.ErrorMessage.jsonConversionFailure
        case .decryptFailed: return K.API.ErrorMessage.decryptFailed
        case .encryptFailed: return K.API.ErrorMessage.encryptFailed
        case .serverError (let data):
            do {
                let genericError = try JSONDecoder().decode(ServerError.self, from: data)
                return genericError.cause
            } catch {
                return K.API.ErrorMessage.unkownError
            }
        }
    }
    
    var statusCode: Int {
        switch self {
        case .requestFailed: return -1
        case .invalidData: return -2
        case .responseUnsuccessful: return -3
        case .jsonParsingFailure: return -4
        case .jsonConversionFailure: return -5
        case .decryptFailed: return -6
        case .encryptFailed: return -7
        case .serverError (let data):
            do {
                let genericError = try JSONDecoder().decode(ServerError.self, from: data)
                return genericError.statusCode
            } catch {
                return 500
            }
        }
    }
}

struct GenericDeleteSuccessObject: Codable {
    let success: Bool
    
    init() {
        self.success = true
    }
}

//Change this according to API error management
struct ServerError: Codable {
    let type: String
    let httpStatus, statusCode: Int
    let cause: String
}


enum Result<T, U> where U: Error {
    case success(T)
    case failure(U)
}

protocol APIClient {
    
    var session: URLSession { get }
    func fetch<T: Decodable>(with request: URLRequest, httpMethod: K.API.HTTPMethod, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void)
}

extension APIClient {
    
    typealias JSONTaskCompletionHandler = (Decodable?, APIError?) -> Void
    
    private func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, _ in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            if (200 ..< 300).contains (httpResponse.statusCode) {
                if httpResponse.statusCode == 204 {
                    completion(GenericDeleteSuccessObject(),nil)
                    return
                }
                
                if let data = data {
                    do {
                        let genericModel = try JSONDecoder().decode(decodingType, from: data)
                        completion(genericModel, nil)
                    } catch {
                        #if DEBUG
                        print("\(APIError.jsonConversionFailure)" + "\n httpResponse: " + (String(data: data, encoding: String.Encoding.utf8) ?? "Json null"))
                        #endif
                        completion(nil, .jsonConversionFailure)
                    }
                    
                } else {
                    #if DEBUG
                    print("httpResponse: \(httpResponse)")
                    #endif
                    completion(nil, .invalidData)
                }
            } else {
                if httpResponse.statusCode >= 500 {
                    #if DEBUG
                    print("Error 500 API")
                    #endif
                }
                if let data = data {
                    #if DEBUG
                    print("\(APIError.serverError(data: data))" + "\n httpResponse: " + (String(data: data, encoding: String.Encoding.utf8) ?? "Json null"))
                    #endif
                    completion(nil, .serverError(data: data))
                } else {
                    #if DEBUG
                    print("\(APIError.responseUnsuccessful)")
                    #endif
                    completion(nil, .responseUnsuccessful)
                }
            }
        }
        return task
    }
    
    func fetch<T: Decodable>(with request: URLRequest, httpMethod: K.API.HTTPMethod, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void) {
        var finalRequest = request
        finalRequest.url = URL(string: finalRequest.url!.absoluteString.removingPercentEncoding!)
        finalRequest.httpMethod = httpMethod.rawValue
        finalRequest.addValue(K.API.Headers.Value.contentType, forHTTPHeaderField: K.API.Headers.Field.contentType)
        finalRequest.addValue(K.API.Headers.Value.accept, forHTTPHeaderField: K.API.Headers.Field.accept)
        finalRequest.addValue(K.API.Headers.Value.clientKey, forHTTPHeaderField: K.API.Headers.Field.clientKey)
        
        let task = self.decodingTask(with: finalRequest, decodingType: T.self) { (json, error) in
            
            // MARK: change to main queue
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(Result.failure(error))
                    } else {
                        completion(Result.failure(.invalidData))
                    }
                    return
                }
                if let value = decode(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(.jsonParsingFailure))
                }
            }
        }
        task.resume()
    }
}

class AsyncOperation {
    
    typealias NumberOfPendingActions = Int
    typealias DispatchQueueOfReturningValue = DispatchQueue
    typealias CompleteClosure = ()->()
    
    private let dispatchQueue: DispatchQueue
    private var semaphore: DispatchSemaphore
    
    private var numberOfPendingActionsQueue: DispatchQueue
    public private(set) var numberOfPendingActions = 0
    
    var whenCompleteAll: (()->())?
    
    init(numberOfSimultaneousActions: Int, dispatchQueueLabel: String) {
        dispatchQueue = DispatchQueue(label: dispatchQueueLabel)
        semaphore = DispatchSemaphore(value: numberOfSimultaneousActions)
        numberOfPendingActionsQueue = DispatchQueue(label: dispatchQueueLabel + "_numberOfPendingActionsQueue")
    }
    
    func run(closure: @escaping (@escaping CompleteClosure)->()) {
        
        self.numberOfPendingActionsQueue.sync {
            self.numberOfPendingActions += 1
        }
        
        dispatchQueue.async {
            self.semaphore.wait()
            closure {
                self.numberOfPendingActionsQueue.sync {
                    self.numberOfPendingActions -= 1
                    if self.numberOfPendingActions == 0 {
                        self.whenCompleteAll?()
                    }
                }
                self.semaphore.signal()
            }
        }
    }
}

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public func hash(into hasher: inout Hasher) {
        // No-op
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}


class JSONCodingKey: CodingKey {
    let key: String
    
    required init?(intValue: Int) {
        return nil
    }
    
    required init?(stringValue: String) {
        key = stringValue
    }
    
    var intValue: Int? {
        return nil
    }
    
    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {
    let value: Any
    
    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }
    
    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }
    
    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }
    
    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }
    
    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }
    
    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}

