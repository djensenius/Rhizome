//
//  Login.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-18.
//

import Foundation

struct LoginRequest: Encodable {
    let password: String
}

// MARK: - RhizomeData
struct RhizomeData: Codable {
    let timestamp: String
    let news: String
    let photos: [String]
}

// MARK: - RhizomeSchedule
struct RhizomeSchedule: Codable {
    let timestamp: String
    let appointments: Appointments?
    let rawData: RawData?

    enum CodingKeys: String, CodingKey {
        case timestamp, appointments
        case rawData = "raw_data"
    }
}

// MARK: - Appointments
struct Appointments: Codable {
    let daycare: [AppointmentsDaycare]
}

// MARK: - AppointmentsDaycare
struct AppointmentsDaycare: Codable, Identifiable {
    let status, service: String
    let date, pickupDate: Int
    let timezone, accountId, locationId: String
    let petexec: Petexec
    let dogName: String
    let updatedAt: UpdatedAt
    let id: String
}

// MARK: - Petexec
struct Petexec: Codable {
    let execid, daycareid, serviceid, userid: Int
    let petid: Int
}

// MARK: - UpdatedAt
struct UpdatedAt: Codable {
}

// MARK: - RawData
struct RawData: Codable {
    let daycare: [RawDataDaycare]
}

// MARK: - RawDataDaycare
struct RawDataDaycare: Codable {
    let daycareid: Int
    let title: String
    let signedin: Bool
    let userid: Int
    let owner: String
    let petid: Int
    let petname: String
    let breedid: Int
    let breed, petdesc: String
    let services: [Service]
    let start, end, pickuptime, dropofftime: String
    let pickuplocation, dropofflocation: String
    let petnap, petlunch, petbreakfast, petdinner: Int
    let status, notes: String
    let allday: Bool
    let playareaid: Int
    let playarea, type: String
}

// MARK: - Service
struct Service: Codable {
    let serviceid: Int
    let servicename, price: String
}

struct LoginResponse: Decodable {
    let cameraURL: String
    let rhizomeSchedule: RhizomeSchedule
    let rhizomeData: RhizomeData
}

struct FluxObject {
    let name: String
    let object: LoginResponse
    let userInfo: [String: Bool]
}

class LoginViewModel: ObservableObject {
    @Published var password: String = ""

    func login() {
        LoginAction(
            parameters: LoginRequest(
                password: password
            )
        ).call()
    }
}

struct LoginAction {
    var parameters: LoginRequest

    func call() {
        queryFlux(password: parameters.password)
    }
}
