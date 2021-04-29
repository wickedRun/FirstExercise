//
//  FlightsEnrouteView.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import CoreData

struct FlightSearch {
    var destination: Airport
    var origin: Airport?
    var airline: Airline?
    var inTheAir: Bool = true
}

extension FlightSearch {
    var predicate: NSPredicate {
        var format = "destination_ = %@"
        var args: [NSManagedObject] = [destination]
        // NSManagedObject란 Flight, Airline, Airport의 super class이다.
        // 그래서 데이터베이스에 만든 것들에 어레이를 만들고 싶다면 NSManagedObject 타입을 사용하면 된다.
        if origin != nil {
            format += " and origin_ = %@"
            args.append(origin!)
        }
        if airline != nil {
            format += " and airline_ = %@"
            args.append(airline!)
        }
        if inTheAir { format += " and departure != nil" }
        return NSPredicate(format: format, args)
    }
}

struct FlightsEnrouteView: View {
    @Environment(\.managedObjectContext) var context
    
    @State var flightSearch: FlightSearch
    
    var body: some View {
        NavigationView {
            FlightList(flightSearch)
                .navigationBarItems(leading: simulation, trailing: filter)
        }
    }
    
    @State private var showFilter = false
    
    var filter: some View {
        Button("Filter") {
            self.showFilter = true
        }
        .sheet(isPresented: $showFilter) {
            FilterFlights(flightSearch: self.$flightSearch, isPresented: self.$showFilter)
                .environment(\.managedObjectContext, self.context)
            // Context in environment is not connected to a persistant store coordinator 오류로 인해 Sheet에도 환경 추가.
            // sheet라는 새로운 UI에 똑같은 환경을 주기 위한 것이다. SceneDelegate에서 환경을 설정해준것처럼 sheet에도 설정해줌.
        }
    }
    
    // if no FlightAware credentials exist in Info.plist
    // then we simulate data from KSFO and KLAS (Las Vegas, NV)
    // the simulation time must match the times in the simulation data
    // so, to orient the UI, this simulation View shows the time we are simulating
    var simulation: some View {
        let isSimulating = Date.currentFlightTime.timeIntervalSince(Date()) < -1
        return Text(isSimulating ? DateFormatter.shortTime.string(from: Date.currentFlightTime) : "")
    }
}

struct FlightList: View {
//    @ObservedObject var flightFetcher: FlightFetcher  // FlightFetcher가 아닌 Core Data를 이용하기 때문에 주석 처리.
    @FetchRequest var flights: FetchedResults<Flight>
    // @FetchRequest라는 property wrapper를 사용하면 이 변수가 항상 데이터베이스에서 값을 FetchResult를 contain하게 만든다.
    // 자동 업데이트가 된다는 말.

    init(_ flightSearch: FlightSearch) {
//        self.flightFetcher = FlightFetcher(flightSearch: flightSearch)    // FlightFetcher가 아닌 Core Data를 이용하기 때문에 주석 처리.
//        let request = NSFetchRequest<Flight>(entityName: "Flight")
//        request.predicate = NSPredicate(format: "destination_ = %@", flightSearch.destination)
//        request.sortDescriptors = [NSSortDescriptor(key: "arrival", ascending: true)]
//        이 부분 또한 Flight.swift 파일에 extension으로 작성.
//        let predicate = flightSearch.predicate    // 한줄로 하기 위해 주석처리.
//        let request = Flight.fetchRequest(NSPredicate(format: "destination_ = %@", flightSearch.destination)) // predicate의 변화하기 위해서 주석처리.
//        extension으로 FlightSearch에 predicate이란 computed property를 추가했고 이 변수는 predicate를 리턴하는 변수이다.
        let request = Flight.fetchRequest(flightSearch.predicate)
        _flights = FetchRequest(fetchRequest: request)
    }

//    var flights: [FAFlight] { flightFetcher.latest }  // FlightFetcher가 아닌 Core Data를 이용하기 때문에 주석 처리.
    
    var body: some View {
        List {
            ForEach(flights, id: \.ident) { flight in
                FlightListEntry(flight: flight)
            }
        }
        .navigationBarTitle(title)
    }
    
    private var title: String {
        let title = "Flights"
        if let destination = flights.first?.destination.icao {
            return title + " to \(destination)"
        } else {
            return title
        }
    }
}

struct FlightListEntry: View {
//    @ObservedObject var allAirports = Airports.all
//    @ObservedObject var allAirlines = Airlines.all
//    Anymore useless.
    
//    var flight: FAFlight
    @ObservedObject var flight: Flight

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
            Text(arrives).font(.caption)
            Text(origin).font(.caption)
        }
            .lineLimit(1)
    }
    
    var name: String {
        return "\(flight.airline.friendlyName) \(flight.number)"
    }

    var arrives: String {
        let time = DateFormatter.stringRelativeToToday(Date.currentFlightTime, from: flight.arrival)
        if flight.departure == nil {
            return "scheduled to arrive \(time) (not departed)"
        } else if flight.arrival < Date.currentFlightTime {
            return "arrived \(time)"
        } else {
            return "arrives \(time)"
        }
    }

    var origin: String {
        return "from " + (flight.origin.friendlyName)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        FlightsEnrouteView(flightSearch: FlightSearch(destination: "KSFO"))
//    }
//}
