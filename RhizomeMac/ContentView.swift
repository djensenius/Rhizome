//
//  ContentView.swift
//  RhizomeMac
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var cameras: [CameraFeed]
    var rhizomeSchedule: Appointments?
    @State var inPlayroom = false
    @State var path = [Int]()
    @State private var whereWeAre = WhereWeAre()

    var showRhizome: some View {
        HStack {
            VStack {
                if inPlayroom {
                    Text("🐕🎉 Rhizome is playing! 🎉🐕")
                        .font(Theme.Fonts.headerLarge())
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding([.bottom], 20)
                } else {
                    Text("🐕 See if Rhizome is playing! 🐕")
                        .font(Theme.Fonts.headerLarge())
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding([.bottom], 20)
                }
                Button(inPlayroom ? "Watch Rhizome" : "Check to see") {
                    path = [1]
                }
                .buttonStyle(.rhizomePrimary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    var body: some View {
        NavigationStack(path: $path) {
            HStack {
                showRhizome
            }.navigationDestination(for: Int.self) { selection in
                if selection == 1 {
                    VideoPlayerView(cameras: cameras)
                }
            }
        }
        .onAppear(perform: parseSchedule)
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
                inPlayroom = false
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
                inPlayroom = false
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
                inPlayroom = false
                return
            }

            // Check if nowToronto is between 7am and 7pm
            inPlayroom = nowToronto >= sevenAM && nowToronto <= sevenPM
        }
    }
}
