//
//  NetworkService.swift
//  MyApp
//
//  Network layer for API communication

import Foundation

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data?,
        headers: [String: String]?
    ) async throws -> T
}

// MARK: - Network Service Implementation
class NetworkService: NetworkServiceProtocol {

    private let baseURL: String
    private let session: URLSession

    init(
        baseURL: String = AppConstants.API.baseURL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {

        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = AppConstants.API.timeout

        // Set headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Set body
        request.httpBody = body

        // Log request in debug mode
        #if DEBUG
        print("🌐 \(method.rawValue) \(url.absoluteString)")
        #endif

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        #if DEBUG
        print("📡 Response: \(httpResponse.statusCode)")
        #endif

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            #if DEBUG
            print("❌ Decoding error: \(error)")
            #endif
            throw NetworkError.decodingError
        }
    }

    // MARK: - Convenience Methods

    func get<T: Decodable>(endpoint: String) async throws -> T {
        try await request(endpoint: endpoint, method: .get, body: nil, headers: nil)
    }

    func post<T: Decodable, U: Encodable>(endpoint: String, body: U) async throws -> T {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(body)
        return try await request(endpoint: endpoint, method: .post, body: data, headers: nil)
    }

    func delete<T: Decodable>(endpoint: String) async throws -> T {
        try await request(endpoint: endpoint, method: .delete, body: nil, headers: nil)
    }
}

// MARK: - Mock Network Service for Testing
class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: Any?
    var shouldThrowError = false
    var errorToThrow: NetworkError = .unknown

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data?,
        headers: [String : String]?
    ) async throws -> T {

        if shouldThrowError {
            throw errorToThrow
        }

        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError
        }

        return response
    }
}
