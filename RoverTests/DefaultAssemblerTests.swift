//
//  APITests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-28.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class APITests: XCTestCase {
    
    func testAssembly() {
        let assembler = DefaultAssembler(accountToken: "giberish")
        assembler.assemble(container: Rover.shared)
        
        let httpPlugin = Rover.shared.resolve(HTTPPlugin.self)!
        XCTAssertEqual(httpPlugin.authorizers.count, 2)
        
        let eventsPlugin = Rover.shared.resolve(EventsPlugin.self)!
        XCTAssertEqual(eventsPlugin.contextProviders.count, 8)
    }
}
