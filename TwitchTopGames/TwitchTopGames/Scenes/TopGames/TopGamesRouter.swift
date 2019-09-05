//
//  TopGamesRouter.swift
//  TwitchTopGames
//
//  Created by mazza on 04/09/19.
//  Copyright (c) 2019 fbassi. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol TopGamesRoutingLogic {
    //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol TopGamesDataPassing {
    var dataStore: TopGamesDataStore? { get }
}

class TopGamesRouter: NSObject, TopGamesRoutingLogic, TopGamesDataPassing {
    weak var viewController: TopGamesViewController?
    var dataStore: TopGamesDataStore?
    
    // MARK: Routing
    
    //func routeToSomewhere(segue: UIStoryboardSegue?) {
    //  if let segue = segue {
    //    let destinationVC = segue.destination as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //  } else {
    //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //    navigateToSomewhere(source: viewController!, destination: destinationVC)
    //  }
    //}
    
    // MARK: Navigation
    
    //func navigateToSomewhere(source: TopGamesViewController, destination: SomewhereViewController) {
    //  source.show(destination, sender: nil)
    //}
    
    // MARK: Passing data
    
    //func passDataToSomewhere(source: TopGamesDataStore, destination: inout SomewhereDataStore) {
    //  destination.name = source.name
    //}
}
