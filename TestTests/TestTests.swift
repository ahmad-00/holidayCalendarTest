//
//  TestTests.swift
//  TestTests
//
//  Created by Ahmad Mohammadi on 7/29/21.
//

import XCTest
@testable import Test

class TestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCalculator() throws {
        let vm = CalendarVM()
        guard let holidays = getHolidaysFromTestData() else {
            XCTAssertTrue(false, "Unable to load holidays json data")
        }
        vm.holidays = holidays
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let startDate = formatter.date(from: "2021/10/01")!
        let endDate = formatter.date(from: "2021/10/15")!
        
        vm.setStartDate(startDate)
        vm.setEndDate(endDate)
        
        XCTAssertEqual(vm.result, "Number of Bussiness Days: 8")
        
    }
    
    private func getHolidaysFromTestData() -> Holidays?{
        
        guard let path = Bundle.main.path(forResource: "holidays", ofType: "json") else {
            return nil
        }
        guard let jsonData = try? String(contentsOfFile: path).data(using: .utf8) else {
                return nil
        }
        
        guard let decodedData = try? JSONDecoder().decode(Holidays.self, from: jsonData) else {
            return nil
        }
        
        return decodedData
        
    }
    
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
