//
//  Schedule.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-24.
//

import SwiftUI

struct Schedule: View {
    var newsUrl: String?
    var schedule: Appointments?
    @State var news: LocalizedStringKey = ""

    var body: some View {
        ScrollView {
            if schedule != nil && schedule?.daycare != nil {
                Text("Daycare Schedule")
                    .font(.title)
                    .padding([.bottom], 20)
                ForEach(schedule!.daycare) { daycare in
                    Text((parseDate(timestamp: TimeInterval(daycare.date / 1000), timezone: daycare.timezone)) +
                       " - " +
                        (parseDate(
                            timestamp: TimeInterval(daycare.pickupDate / 1000),
                            timezone: daycare.timezone,
                            showDate: false))
                    )
                        .padding([.bottom], 20)
                }
            } else {
                Text("No Daycare Appointments Scheduled")
                    .font(.title)
                    .padding([.bottom], 20)
            }
            Spacer()
            Text("Other news")
                .font(.title)
                .padding([.bottom], 20)
            Text(news)
                .padding([.bottom], 20)
                .task {
                    if newsUrl != nil {
                        URLSession.shared.dataTask(
                            with: URLRequest(url: URL(string: newsUrl!)!)) { @Sendable data, _, _ in
                                if let data = data {
                                    let string = String(data: data, encoding: .utf8)
                                    DispatchQueue.main.async { @MainActor in
                                        news = LocalizedStringKey(stringLiteral: string!)
                                    }
                                }
                        }.resume()
                    }
                }
        }
    }

    func parseDate(timestamp: TimeInterval, timezone: String, showDate: Bool = true) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: timezone)
        if showDate == true {
            dateFormatter.dateStyle = .long
        } else {
            dateFormatter.dateStyle = .none
        }
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
