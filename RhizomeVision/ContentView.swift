//
//  ContentView.swift
//  RhizomeVision
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI
import AVKit
import RealityKit
import RealityKitContent

struct ContentView: View {
    var cameraURL: String
    var rhizomeSchedule: Appointments?
    @State var path = [Int]()

    var body: some View {
        NavigationStack(path: $path) {
            HStack {
                VStack {
                    Text("🐕 See if Rhizome is playing! 🐕")
                        .font(Theme.Fonts.headerLarge())
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding([.bottom], 20)
                    Button("Check to see") {
                        path.append(1)
                    }
                    .buttonStyle(.rhizomePrimary)
                }
            }
            .navigationDestination(for: Int.self) { selection in
                if selection == 1 {
                    VideoPlayerView(cameraURL: cameraURL) {
                        path = []
                    }
                }
            }
        }.onAppear(perform: parseSchedule)
    }

    func parseSchedule() {
        if rhizomeSchedule != nil && rhizomeSchedule?.nextReservation != nil {
            let dateString = rhizomeSchedule!.nextReservation.startDate
            let torontoTimeZone = TimeZone(identifier: "America/Toronto")!

            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, M/d/yyyy h:mm a"
            formatter.timeZone = torontoTimeZone

            // Parse the date
            guard let parsedDate = formatter.date(from: dateString) else {
                print("Failed to parse date")
                // showVideo = false
                return
            }
            var calendar = Calendar.current
            calendar.timeZone = torontoTimeZone

            // Get today's date in Toronto
            let now = Date()
            let nowToronto = now.addingTimeInterval(
                TimeInterval(
                    torontoTimeZone.secondsFromGMT(for: now) - TimeZone.current.secondsFromGMT(for: now)
                )
            )

            // Extract day, month, year components from both parsed and now
            let parsedComponents = calendar.dateComponents([.year, .month, .day], from: parsedDate)
            let nowComponents = calendar.dateComponents([.year, .month, .day], from: nowToronto)

            // Check if it's the same calendar date
            guard parsedComponents.year == nowComponents.year,
                  parsedComponents.month == nowComponents.month,
                  parsedComponents.day == nowComponents.day
            else {
                // showVideo = false
                return
            }

            // Build 7am and 7pm dates on that day
            var sevenAMComponents = parsedComponents
            sevenAMComponents.hour = 7
            sevenAMComponents.minute = 0

            var sevenPMComponents = parsedComponents
            sevenPMComponents.hour = 19
            sevenPMComponents.minute = 0

            guard let sevenAM = calendar.date(from: sevenAMComponents),
                  let sevenPM = calendar.date(from: sevenPMComponents)
            else {
                print("Failed to build 7am/7pm dates")
                // showVideo = false
                return
            }

            // Check if nowToronto is between 7am and 7pm
            if nowToronto >= sevenAM && nowToronto <= sevenPM {
                // showVideo = true
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(cameraURL: "")
}
