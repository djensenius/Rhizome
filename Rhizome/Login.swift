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
/*
 "next_reservation": {
         "start_date": "Thursday, 8/14/2025 9:00 am",
         "type": "Daycare | Full Day",
         "first_name": "David",
         "r_id": "2833",
         "precheck_reservation_id": null
     },
 */
// MARK: - Appointments
struct Appointments: Codable {
    let nextReservation: AppointmentsDaycare

    private enum CodingKeys: String, CodingKey {
        case nextReservation = "next_reservation"
    }
}

// MARK: - AppointmentsDaycare
struct AppointmentsDaycare: Codable, Identifiable {
    let startDate: String
   let rId: Int
   let type: String

   var id: Int { rId }

   private enum CodingKeys: String, CodingKey {
       case startDate = "start_date"
       case rId = "r_id"
       case type
   }
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

// MARK: - CameraFeed
struct CameraFeed: Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
}

struct LoginResponse: Decodable {
    let cameraURL: String
    let romperURL: String?
    let gymURL: String?
    let rhizomeSchedule: RhizomeSchedule
    let rhizomeData: RhizomeData

    enum CodingKeys: String, CodingKey {
        case cameraURL, rhizomeSchedule, rhizomeData
        case romperURL
        case gymURL
    }

    var cameraFeeds: [CameraFeed] {
        var feeds = [CameraFeed(id: "toybox", name: "Toybox", url: cameraURL)]
        if let url = romperURL, !url.isEmpty {
            feeds.append(CameraFeed(id: "romper", name: "Romper", url: url))
        }
        if let url = gymURL, !url.isEmpty {
            feeds.append(CameraFeed(id: "gym", name: "Gym", url: url))
        }
        return feeds
    }
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
