//
//  URLSessionHelper.swift
//  Test
//
//  Created by Ahmad Mohammadi on 7/29/21.
//

import Foundation
// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers

extension URLSession {
    func decodableTask<T: Decodable>(with urlRequest: URLRequest, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            
//            debugPrint("====Request Response====\n", String(describing: try? JSONSerialization.jsonObject(with: data, options: [])))
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }
}
