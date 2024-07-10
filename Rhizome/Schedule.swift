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
    @State private var login = UserDefaults.standard.string(forKey: "login")
    @State private var date = Date()
    @State private var pickupDate = Date()
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            if schedule != nil && schedule?.daycare != nil && !(schedule?.daycare.isEmpty ?? true) {
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
                Text("Daycare")
                    .font(.title)
                    .padding([.bottom], 20)
                Text("No daycare scheduled")
            }
            Spacer()
            #if !os(tvOS)
            if login == "rhizome" {
                VStack {
                    Text("Schedule")
                        .font(.title)
                        .padding([.bottom], 20)
                    DatePicker(
                        "Start Date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    ).onChange(of: date) { _, newValue in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        let currentTime = formatter.string(from: pickupDate)
                        formatter.dateFormat = "YYYY-MM-DD"
                        let newDate = formatter.string(from: newValue)
                        formatter.dateFormat = "YYYY-MM-DD HH:mm"
                        pickupDate = formatter.date(from: "\(newDate) \(currentTime)")!
                    }
                    DatePicker(
                        "End Date",
                        selection: $pickupDate,
                        displayedComponents: [.date, .hourAndMinute]
                    ).onChange(of: pickupDate) { _, newValue in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        let currentTime = formatter.string(from: date)
                        formatter.dateFormat = "YYYY-MM-DD"
                        let newDate = formatter.string(from: newValue)
                        formatter.dateFormat = "YYYY-MM-DD HH:mm"
                        date = formatter.date(from: "\(newDate) \(currentTime)")!
                    }
                    Button {
                        showAlert = true
                    } label: {
                        Text("Schedule appointment")
                    }
                    .padding([.top, .bottom])
                    .alert(
                        "Confirm appointment for \n \(date.formatted(date: .abbreviated, time: .omitted))",
                        isPresented: $showAlert) {
                        Button("Confirm", role: .destructive) {
                            scheduleDaycare(date: date, pickupDate: pickupDate)
                            showAlert = false
                        }
                        Button("Cancel", role: .cancel) { showAlert = false }
                            .padding([.top, .bottom])
                    }
                }.padding()
                Spacer()
            }
            #endif
            Text("Other news")
                .font(.title)
                .padding([.bottom], 20)
            Text(news)
                .padding([.bottom], 20)
                .task {
                    if newsUrl != nil {
                        URLSession.shared.dataTask(with: URLRequest(url: URL(string: newsUrl!)!)) { data, _, _ in
                            if let data = data {
                                let string = String(decoding: data, as: UTF8.self)
                                DispatchQueue.main.async {
                                    news = LocalizedStringKey(stringLiteral: string)
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

    func scheduleDaycare(date: Date, pickupDate: Date) {
        let json = [
            "dropoff": date.timeIntervalSince1970 * 1000,
            "pickup": pickupDate.timeIntervalSince1970 * 1000
        ]
        let password = WhereWeAre.getPassword()
        if password != nil {
            queryFlux(password: password!, method: "post", body: json)
        }
    }
}
