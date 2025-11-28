//
//  MockURLSession.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import Foundation
@testable import HatchWorksChallenge

final class MockURLSession: URLSessionProtocol {
    
    var requestedURLs: [URL] = []
    var requestCount: Int { requestedURLs.count }
    var lastURL: URL? { requestedURLs.last }
    
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    // MARK: - Override
    func data(from url: URL) async throws -> (Data, URLResponse) {
        requestedURLs.append(url)
        
        if let error = mockError {
            throw error
        }
        
        guard let mockData, let mockResponse else {
            throw NSError(domain: "MockURLSession", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock not configured"])
        }
        return (mockData, mockResponse)
    }
    
    func reset() {
        mockData = nil
        mockResponse = nil
        mockError = nil
        requestedURLs.removeAll()
    }
    
    func setupSuccess(data: Data, statusCode: Int = 200, url: URL? = nil) {
        mockData = data
        let responseURL = url ?? URL(string: "https://dragonball-api.com/api/mock")!
        
        mockResponse = HTTPURLResponse(url: responseURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        mockError = nil
    }
    
    func setupFailure(error: Error) {
        mockData = nil
        mockResponse = nil
        mockError = error
    }
    
    func setupInvalidResponse() {
        mockData = Data()
        mockResponse = URLResponse()
        mockError = nil
    }
    
    func setupHTTPError(statusCode: Int) {
        mockData = Data()
        mockResponse = HTTPURLResponse(url: .init(string: "https://dragonball-api.com/api/")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        mockError = nil
    }
}
