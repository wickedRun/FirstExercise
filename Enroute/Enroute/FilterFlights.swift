//
//  FilterFlights.swift
//  Enroute
//
//  Created by CS193p Instructor on 5/12/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI

struct FilterFlights: View {
    @ObservedObject var allAirports = Airports.all
    @ObservedObject var allAirlines = Airlines.all

    @Binding var flightSearch: FlightSearch
    @Binding var isPresented: Bool
    
    @State private var draft: FlightSearch
    
    // draft의 초기값으로 flightSearch를 넣고 싶지만 초기화가 진행된 상태가 아니라서 init 메서드 안에서 넣어준다.
    // 초기화 되기 전 (init 안이니까 초기화 되기 전.)에는 projectedValue, wrappedValue를 사용할 수 없다.
    init(flightSearch: Binding<FlightSearch>, isPresented: Binding<Bool>) {
        _flightSearch = flightSearch
        _isPresented = isPresented
        _draft = State(wrappedValue: flightSearch.wrappedValue)
        // self.draft = flightSearch 하고 싶지만 안되고 위 방법으로 해야한다. 왜냐하면 self.draft와 flightSearch는 타입이 다르기 때문에.
    }
    
    var body: some View {
        NavigationView {
            // NavigationView가 있고 From으로 되있을 경우 해당 목록을 tap 해서 다음 navigate된 뷰에서 선택할 수 있지만 NavigationView가 없으면 tap 자체가 안된다.
            Form {
                Picker("Destination", selection: $draft.destination) {
                    // ForEach가 뷰 목록을 제공하는 가장 쉬운 방법.
                    // allAirports.codes를 얻기 위해 ViewModel 위에 써줌.
                    ForEach(allAirports.codes, id: \.self) { airport in
                        Text("\(self.allAirports[airport]?.friendlyName ?? airport)").tag(airport)
                        // Tag를 이용해서 Binding 아이템에 선택된 것을 넣어준다.
                        // Tag에 들어와야 할 것은 Binding 아이템이 바운즈하는 것과 같은 유형이여야 한다.
                        // Tag된 것은 리스트에서도 나오고 선택한 후에 오른쪽에도 나온다. 리스트에서는 체크되어 있다.
                    }
                }
//                .pickerStyle(WheelPickerStyle())  // 이렇게 하면 휠로 선택 가능.
                Picker("Origin", selection: $draft.origin) {
                    // selection 과 tag안에 들어갈 값은 같은 타입이여야한다. 그래서 String?.none을 넣은것이다.
                    Text("Any").tag(String?.none)   // 이렇게 하면 Any도 list에 들어가게 된다.
                    // 따지고보면 ForEach도 Text 여러개이니 똑같다.
                    ForEach(allAirports.codes, id: \.self) { (airport: String?) in
                        Text("\(self.allAirports[airport]?.friendlyName ?? airport ?? "Any")").tag(airport)
                        // 옵셔널체이닝으로 allAirports[airport]가 없으면 nil 있으면 friendlyName을 띄우는데 friendlyName이 없으면 airport(code 값)를 그대로 띄우고 그마저도 없으면 "Any"를 띄움.
                    }
                }
                Picker("Airline", selection: $draft.airline) {
                    Text("Any").tag(String?.none)
                    ForEach(allAirlines.codes, id: \.self) { (airline: String?) in
                        Text("\(self.allAirlines[airline]?.friendlyName ?? airline ?? "Any")").tag(airline)
                    }
                }
                Toggle(isOn: $draft.inTheAir) { Text("Enroute Only") }
            }
                .navigationBarTitle("Filter Flights")
                .navigationBarItems(leading: cancel, trailing: done)
        }
    }
    
    var cancel: some View {
        Button("Cancel") {
            self.isPresented = false
        }
    }
    var done: some View {
        Button("Done") {
            self.flightSearch = self.draft  // make the acutal changes
            self.isPresented = false
        }
    }
}

//struct FilterFlights_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterFlights()
//    }
//}
