//
//  AssemblerTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-28.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class AssemblerTests: XCTestCase {
    
    func testDefaultAssembler() {
        let rover = Rover()
        
        let assembler = DefaultAssembler(accountToken: "giberish")
        assembler.assemble(container: rover)
        
        let httpFactory = rover.resolve(HTTPPlugin.self)!
        XCTAssertEqual(httpFactory.authorizers.count, 2)
        
        let eventsManager = rover.resolve(EventsPlugin.self)!
        XCTAssertEqual(eventsManager.contextProviders.count, 8)
    }    
}
