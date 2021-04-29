//
//  Airport.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import CoreData
import Combine

extension Airport {
    static func withICAO(_ icao: String, context: NSManagedObjectContext) -> Airport {
        // look up icao in Core Data
//        let request = NSFetchRequest<Airport>(entityName: "Airport")
//        request.predicate = NSPredicate(format: "icao_ = %@", icao)
//        request.sortDescriptors = [NSSortDescriptor(key: "location", ascending: true)]
//        // 이런 데이터베이스에 접근할 때는 우리가 코드에서 만든 field 이름말고 데이터베이스에 정의해둔 이름을 사용해야함.
//        // predicate에서는 icao_, sortDescriptor에서는 location 데이터베이스에서 정의되어 있는대로. 생각해보면 당연하다.
//        이 파일 제일 밑으로 옮기고 이 라인 바로 밑에 새로작성
        let request = fetchRequest(NSPredicate(format: "icao_ = %@", icao))
        let airports = try? context.fetch(request)
        if let airport = airports?.first {
            // if found, return it, airports가 빈배열이 아니고 first 필드가 있다면 그거 리턴해줌.
            return airport
        } else {
            // if not, create one and fetch from FlighAware
            // 아니라면, FlightAware 코드를 사용하여 FlightAware에서 가져와서 하나 새로 만든다.
            let airport = Airport(context: context)
            airport.icao_ = icao
            AirportInfoRequest.fetch(icao) { airportInfo in
                self.update(from: airportInfo, context: context)
            }
            return airport
        }
    }
    
    static func update(from info: AirportInfo, context: NSManagedObjectContext) {
        if let icao = info.icao {
            let airport = self.withICAO(icao, context: context)
            airport.latitude = info.latitude
            airport.longitude = info.longitude
            airport.name = info.name
            airport.location = info.location
            airport.timezone = info.timezone
            airport.objectWillChange.send()
//            airport.flightsTo_?.forEach { $0.objectWillChange.send() }
//            airport.flightsFrom_?.forEach { $0.objectWillChange.send() }
//            NSSet이기 때문에 컴파일 오류 : Value of type 'NSSet.Element' (aka 'Any') has no member 'objectWillChange'
//            airport.flightsTo_!.forEach { $0.objectWillChange.send() }
//            airport.flightsFrom_!.forEach { $0.objectWillChange.send() }
//           강제 옵셔널로 지정해도 마찬가지 컴파일 오류.
            airport.flightsTo.forEach { $0.objectWillChange.send() }
            airport.flightsFrom.forEach { $0.objectWillChange.send() }
            
            try? context.save()
        }
    }

//    Enroute.xcdatamodeld의 필드에 '_'를 붙인 이유는 compute property를 만들기 위해서 _를 붙여서 다른이름으로 바꿔준 것이다.
    var flightsTo: Set<Flight> {
        get { flightsTo_ as? Set<Flight> ?? [] }
        set { flightsTo_ = newValue as NSSet}
    }
    
    var flightsFrom: Set<Flight> {
        get { flightsFrom_ as? Set<Flight> ?? [] }
        set { flightsFrom_ = newValue as NSSet }
    }
}

extension Airport: /*Identifiable,*/ Comparable {
    var icao: String {
        get { icao_! }
        set { icao_ = newValue }
    }
    
    var friendlyName: String {
        let friendly = AirportInfo.friendlyName(name: self.name ?? "", location: self.location ?? "")
        return friendly.isEmpty ? icao : friendly
    }
    
    public var id: String { icao }
    
    public static func < (lhs: Airport, rhs: Airport) -> Bool {
        lhs.location ?? lhs.friendlyName < rhs.location ?? rhs.friendlyName
    }
}

extension Airport {
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Airport> {
        let request = NSFetchRequest<Airport>(entityName: "Airport")
        request.sortDescriptors = [NSSortDescriptor(key: "location", ascending: true)]
        request.predicate = predicate
        return request
    }
}

extension Airport {
    func fetchIncomingFlights() {
        Self.flightAwareRequest?.stopFetching()
        if let context = managedObjectContext {
            Self.flightAwareRequest = EnrouteRequest.create(airport: icao, howMany: 120)
            Self.flightAwareRequest?.fetch(andRepeatEvery: 10)
            Self.flightAwareResultsCancellable = Self.flightAwareRequest?.results.sink { results in
                for faflight in results {
                    Flight.update(from: faflight, in: context)
                }
                do {
                    try context.save()
                } catch(let error) {
                    print("couldn't save flight update to CoreData: \(error.localizedDescription)")
                }
            }
        }
    }
    private static var flightAwareRequest: EnrouteRequest!
    private static var flightAwareResultsCancellable: AnyCancellable?
}
