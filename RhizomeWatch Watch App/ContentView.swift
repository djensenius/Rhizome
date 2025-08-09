//
//  ContentView.swift
//  RhizomeWatch Watch App
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var cameraURL: String
    var rhizomeSchedule: Appointments?
    @State var inPlayroom = false
    @State private var whereWeAre = WhereWeAre()

    var body: some View {
        VStack {
            if inPlayroom {
                Text("🐕🎉 Rhizome is playing! 🎉🐕")
                    .padding([.bottom], 20)
            } else {
                Text("🐕 Rhizome is not in the playroom 🐕")
                    .padding([.bottom], 20)
            }
            Button {
                whereWeAre.deleteKeyChainPasword()
                NotificationCenter.default.post(
                    name: Notification.Name.logout,
                    object: nil,
                    userInfo: ["logout": true]
                )
            } label: {
                Text("Logout")
            }
        }
        .onAppear(perform: parseSchedule)
    }

    func parseSchedule() {
        if rhizomeSchedule != nil && rhizomeSchedule?.daycare != nil && rhizomeSchedule?.daycare.count ?? 0 > 0 {
            for daycare in rhizomeSchedule!.daycare {
                let startDate = Date(timeIntervalSince1970: TimeInterval((daycare.date / 1000) - (60 * 60)))
                let endDate = Date(timeIntervalSince1970: TimeInterval((daycare.pickupDate / 1000) + (60 * 60)))
                if Date.now  > startDate && Date.now < endDate {
                    inPlayroom = true
                }
            }
        }
    }
}

#Preview {
    ContentView(cameraURL: "")
}
