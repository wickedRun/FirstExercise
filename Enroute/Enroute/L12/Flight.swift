//
//  Flight.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import CoreData
import Combine

extension Flight {
//    ??을 사용해서 nil 되면 안되는 것에 기본 값을 넣어준다. 
    var arrival: Date {
        get { arrival_ ?? Date(timeIntervalSinceReferenceDate: 0) }
        set { arrival_ = newValue }
    }
    var ident: String {
        get { ident_ ?? "Unknown" }
        set { ident_ = newValue }
    }
    var destination: Airport {
        get { destination_! }   // TODO: protect against nil before shipping?
        set { destination_ = newValue }
    }
    var origin: Airport {
        get { origin_! }    // TODO: maybe protect against when app ships?
        set { origin_ = newValue }
    }
    var airline: Airline {
        get { airline_! }   // TODO: maybe protect against when app ships?
        set { airline_ = newValue }
    }
    var number: Int {
        Int(String(ident.drop(while: { !$0.isNumber }))) ?? 0
    }
}

extension Flight {
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Flight> {
        let request = NSFetchRequest<Flight>(entityName: "Flight")
        request.sortDescriptors = [NSSortDescriptor(key: "arrival", ascending: true)]
        request.predicate = predicate
        return request
    }
}

extension Flight {
    @discardableResult
    static func update(from faflight: FAFlight, in context: NSManagedObjectContext) -> Flight {
        let request = fetchRequest(NSPredicate(format: "ident_ = %@", faflight.ident))
        let results = (try? context.fetch(request)) ?? []
        let flight = results.first ?? Flight(context: context)
        flight.ident = faflight.ident
        flight.origin = Airport.withICAO(faflight.origin, context: context)
        flight.destination = Airport.withICAO(faflight.destination, context: context)
        flight.arrival = faflight.arrival
        flight.departure = faflight.departure
        flight.filed = faflight.filed
        flight.aircraft = faflight.aircraft
        flight.airline = Airline.withCode(faflight.airlineCode, in: context)
        flight.objectWillChange.send()
        return flight
    }
}
