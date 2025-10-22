//
//  UserRepository.swift
//  MyApp
//
//  User data persistence and management

import Foundation
import Combine

// MARK: - Stored/User DTO Model
struct StoredUser: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var createdAt: Date
    var totalGoals: Int
    var currentStreak: Int
    var totalPoints: Int

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        createdAt: Date = Date(),
        totalGoals: Int = 0,
        currentStreak: Int = 0,
        totalPoints: Int = 0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = createdAt
        self.totalGoals = totalGoals
        self.currentStreak = currentStreak
        self.totalPoints = totalPoints
    }
}

// MARK: - Mapping between SwiftData User and StoredUser
extension StoredUser {
    init(from user: AppUser) {
        self.id = user.id
        self.name = "\(user.firstName) \(user.lastName)".trimmingCharacters(in: .whitespaces)
        self.email = user.email
        self.createdAt = user.createdAt
        self.totalGoals = user.goals.count
        self.currentStreak = 0
        self.totalPoints = 0
    }
}

extension AppUser {
    // Update a SwiftData User instance from a StoredUser
    func apply(from stored: StoredUser) {
        let parts = stored.name.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        if let first = parts.first {
            self.firstName = String(first)
        }
        if parts.count > 1 {
            self.lastName = String(parts[1])
        }
        self.email = stored.email
        self.updatedAt = Date()
    }
}

// MARK: - User Repository Protocol
protocol UserRepositoryProtocol {
    func getCurrentUser() async throws -> StoredUser?
    func saveUser(_ user: StoredUser) async throws
    func updateUser(_ user: StoredUser) async throws
    func deleteUser() async throws
}

// MARK: - User Repository Implementation
class UserRepository: UserRepositoryProtocol {

    private let userDefaultsKey = "currentUser"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getCurrentUser() async throws -> StoredUser? {
        guard let data = userDefaults.data(forKey: userDefaultsKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(StoredUser.self, from: data)
    }

    func saveUser(_ user: StoredUser) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)
        userDefaults.set(data, forKey: userDefaultsKey)
    }

    func updateUser(_ user: StoredUser) async throws {
        try await saveUser(user)
    }

    func deleteUser() async throws {
        userDefaults.removeObject(forKey: userDefaultsKey)
    }
}

// MARK: - Mock Repository for Testing
class MockUserRepository: UserRepositoryProtocol {
    var mockUser: StoredUser?
    var shouldThrowError = false

    func getCurrentUser() async throws -> StoredUser? {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return mockUser
    }

    func saveUser(_ user: StoredUser) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        mockUser = user
    }

    func updateUser(_ user: StoredUser) async throws {
        try await saveUser(user)
    }

    func deleteUser() async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        mockUser = nil
    }
}
