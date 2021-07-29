//
//  CalendarVM.swift
//  Test
//
//  Created by Ahmad Mohammadi on 7/29/21.
//

import Foundation
import Combine

class CalendarVM: ObservableObject {
    
    @Published private var startDate: Date?
    @Published private var endDate: Date?
    @Published var result = ""
    @Published var navBarStatus: NavBarStatus = NavBarStatus.None
    
    @Published var holidays = Holidays()
    
    private var cancelable = Set<AnyCancellable>()
    
    init() {
        startObserver()
    }
    
    func setStartDate(_ startDate: Date) {
        self.startDate = startDate
    }
    
    func setEndDate(_ endDate: Date) {
        self.endDate = endDate
    }
    
    private func startObserver() {
        Publishers.CombineLatest($startDate, $endDate).receive(on: DispatchQueue.main).sink {[weak self] _startDate, _endDate in
            guard let `self` = self else {
                return
            }
            
            if _startDate == nil || _endDate == nil {
                return
            }
            
            if self.holidays.count == 0 {
                return
            }
            
            self.result = "Number of Bussiness Days: \(self.bussinessDaysCount(start: _startDate!, end: _endDate!))"
            
        }.store(in: &cancelable)
        
    }
    
    private func bussinessDaysCount(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        var businessDays = 0
        var date = nextDay(in: calendar, date: start)!
        while date < end {
            if !calendar.isDateInWeekend(date) && !isHoliday(date: date) {
                businessDays += 1
            }

            guard let nextDay = nextDay(in: calendar, date: date) else {
                fatalError("Failed to instantiate a next day")
            }

            date = nextDay
        }

        return businessDays
    }
    
    private func nextDay(in calendar: Calendar, date: Date) -> Date? {
        return calendar.date(byAdding: .day, value: 1, to: date)
    }
    
    func fetchHolidays() {
        navBarStatus = .Loading
        NetworkManager
            .shared
            .getHolidays()
            .subscribe(on: DispatchQueue.global(qos:.userInteractive))
            .receive(on: DispatchQueue.main)
            .sink {[weak self] (_result) in
                guard let `self` = self else {
                    return
                }
                
                switch _result {
                case .failure(let err):
                    self.navBarStatus = .Error(message: err.localizedDescription)
                case .finished:
                    self.navBarStatus = .None
                    break
                }
                
            } receiveValue: {[weak self] (data) in
                guard let `self` = self else {
                    return
                }
                self.holidays = data
            }.store(in: &cancelable)
        
    }
    
    private func isHoliday(date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let readableDate = formatter.string(from: date)
        
        for holiday in holidays {
            if String(holiday.date) == readableDate {
                return true
            }
        }
        return false
        
    }
    
}
