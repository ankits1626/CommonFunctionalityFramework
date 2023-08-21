//
//  JoeAppInterface.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 20/08/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation


public struct JoyeAppInterfaceInputModel{
    var networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var mediaCoordinator : CFFMediaCoordinatorProtocol
    var themeManager : CFFThemeManagerProtocol?
    var mainAppCoordinator : CFFMainAppInformationCoordinator?
    
    public init (networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, mediaCoordinator : CFFMediaCoordinatorProtocol, themeManager : CFFThemeManagerProtocol?, mainAppCoordinator : CFFMainAppInformationCoordinator?){
        self.networkRequestCoordinator = networkRequestCoordinator
        self.mediaCoordinator = mediaCoordinator
        self.themeManager = themeManager
        self.mainAppCoordinator = mainAppCoordinator
    }
}

/**
 this is the interface for Joye app integration
 */
public class JoyeAppInterface{
    let inputModel: JoyeAppInterfaceInputModel
    var mainAppCoordinator :CFFMainAppInformationCoordinator{
        return inputModel.mainAppCoordinator!
    }
    
    public init(_ inputModel: JoyeAppInterfaceInputModel){
        self.inputModel = inputModel
    }
    
    public func launchJoyeApp(_ completion: @escaping ((String?, String?) -> Void)){
        debugPrint("<<<<<<< launch joye app")
        if !mainAppCoordinator.getJoyAppUrl().isEmpty {
            let diffInDays = Calendar.current.dateComponents([.day], from: mainAppCoordinator.getJoyAppUrlDate(), to: Date()).day
            if let day = diffInDays {
                if day > 0 {
                    authenticateJoySdk(completion)
                }else{
                    completion(mainAppCoordinator.getJoyAppUrl(), nil)
//                    self.JoyAppWebViewController(webUrl: mainAppCoordinator.getJoyAppUrl())
                }
            }
        }else{
            authenticateJoySdk(completion)
        }
    }
    
    private func authenticateJoySdk(_ completion: @escaping ((String?, String?) -> Void)) {
        AuthenticateJoySDKWorker(networkRequestCoordinator: inputModel.networkRequestCoordinator).postBulkStepData(orgRequestBody: mainAppCoordinator.getJoyeAppRequestBody()) { (result) in
        DispatchQueue.main.async {[weak self] in
          switch result{
          case .Success(let fetchedResult):
              self?.mainAppCoordinator.saveJoyAppUrl(url: fetchedResult.url)
              self?.mainAppCoordinator.saveJoyAppUrlDate(timeStamp: Date())
              completion(fetchedResult.url, nil)
            break
          case .Failure(let error) :
              completion(nil, error.localizedDescription)
          case .SuccessWithNoResponseData:
              completion(nil, "Error: Joye app response with no data")
          }}
      }
    }
    
}
