//
//  NetworkManager.swift
//  Test
//
//  Created by Ahmad Mohammadi on 7/29/21.
//

import Foundation
import Combine

enum ApiError: Error, Equatable {
    case Server
    
    var localizedDescription: String {
        switch self {
        case .Server:
            return NSLocalizedString("Connection failed. please try again", comment: "")
        }
    }
}

class NetworkManager {
    
    private init() {}
    
    static let shared = NetworkManager()
    
    func getHolidays() -> Future<Holidays, Error> {
        
        let url = URL(string: "https://aeef24c2-e41a-4561-8e3b-589339b2a52b.mock.pstmn.io/holidays")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return Future {[weak self] promise in
            guard let `self` = self else {
                return
            }
            
            URLSession.shared.HolidaysTask(with: request) { (_data, _response, _error) in
                
                do {
                    let data = try self.reponseCheck(data: _data, response: _response, error: _error)
                    
                    promise(.success(data))
                    
                } catch let error {
                    promise(.failure(error as! ApiError))
                    return
                }
                
            }.resume()
            
        }
        
    }
    
    func reponseCheck<T>(data: T?, response: URLResponse?, error: Error?) throws -> T {
        if error != nil {
            throw ApiError.Server
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                throw ApiError.Server
            }
        }else {
            throw ApiError.Server
        }
        
        guard let data = data else {
            throw ApiError.Server
        }
        
        return data
    }
    
}

extension URLSession {
    func HolidaysTask(with urlRequest: URLRequest, completionHandler: @escaping (Holidays?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.decodableTask(with: urlRequest, completionHandler: completionHandler)
    }
}



