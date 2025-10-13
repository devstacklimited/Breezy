//
//  ApiRouter.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation
import Alamofire

enum ApiRouter: URLRequestConvertible {
    case loadWeather(_ p: Parameters)
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = AppConstants.URLs.baseURL
        let url = baseURL + path
        guard let completeURL = URL(string: url) else {
            fatalError("Invalid URL: \(url)")
        }
        var urlRequest = URLRequest(url: completeURL)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(AppConstants.ContentType.json.rawValue, forHTTPHeaderField: AppConstants.HttpHeaderField.contentType.rawValue)
        urlRequest.setValue(AppConstants.ContentType.json.rawValue, forHTTPHeaderField: AppConstants.HttpHeaderField.acceptType.rawValue)
        /// Encoding
        let encoding: ParameterEncoding = {
            switch method {
            case .get:
                return URLEncoding.default
            case .post, .patch:
                return JSONEncoding.default
            case .delete:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }()
        let encodedURL = try encoding.encode(urlRequest, with: parameters)
        return encodedURL
    }
    
    var path: String {
        switch self {
        case .loadWeather(let p):
            return "weather?" + p.queryString
        }
    }
    
    private var method: HTTPMethod {
        switch self {
        case .loadWeather:
            return .get
        }
    }
    
    private var parameters: Parameters? {
        switch self {
        case .loadWeather:
            return nil
        }
    }
}
