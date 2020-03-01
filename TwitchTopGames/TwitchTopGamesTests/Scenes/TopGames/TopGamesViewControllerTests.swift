//
//  TopGamesViewControllerTests.swift
//  TwitchTopGames
//
//  Created by mazza on 20/09/19.
//  Copyright (c) 2019 fbassi. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import TwitchTopGames
import XCTest

class TopGamesViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: TopGamesViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupTopGamesViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupTopGamesViewController() {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        sut = storyboard.instantiateViewController(withIdentifier: "TopGamesViewController") as? TopGamesViewController
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: Test doubles
    
    class TopGamesBusinessLogicSpy: TopGamesBusinessLogic {
        var getTopGamesCalled = false
        func getTopGames(request: TopGames.Get.Request) {
            getTopGamesCalled = true
        }
    }
    
    // MARK: Tests
    
    func testDisplayTopGamesWithNilViewModel() {
        // Given
        let viewModel: TopGames.Get.ViewModel? = nil
        
        // When
        loadView()
        sut.displayTopGames(viewModel: viewModel)
        
        // Then
        XCTAssertEqual(sut.tableView?.dataSource == nil, true, "displayTopGames(viewModel:nil) should display table view placeholder")
    }
    
    func testDisplayTopGamesWithValidViewModelShouldInitializeTableViewDataSource() {
        // Given
        let gameUrl = URL(string: "https://static-cdn.jtvnw.net/ttv-boxart/Grand%20Theft%20Auto%20V-272x380.jpg")
        let games =
            [TopGames.Get.ViewModel.DisplayedGame(gameName: "Game 01", popularity: 1000, localizedName: "Game 01", gameImageUrl: gameUrl!)]
        let viewModel = TopGames.Get.ViewModel(totalPages: 1, displayedGames: games)
        
        // When
        loadView()
        sut.displayTopGames(viewModel: viewModel)
        
        // Then
        XCTAssertEqual(sut.tableView?.dataSource != nil, true, "displayTopGames(viewModel:nil) should display table view placeholder")
    }
}