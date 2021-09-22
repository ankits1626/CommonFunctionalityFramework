//
//  GifFetcher.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 10/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

public enum FetchedGifNextPageState {
    case Initial
    case NextAvailable(String)
    case EndOfLIst
}

public struct FetchedGifModel{
    public var fetchedRawGifs : [String : Any]?
    public var error : String?
    public var nextPageState : FetchedGifNextPageState
    
    public init(fetchedRawGifs : [String : Any]?, error : String?, nextPageState : FetchedGifNextPageState) {
        self.fetchedRawGifs = fetchedRawGifs
        self.error = error
        self.nextPageState = nextPageState
    }
}

typealias GifFetcherHandler = (APICallResult<FetchedGifModel>) -> Void

class GifFetcher  {
    typealias ResultType = FetchedGifModel
    var commonAPICall : CommonAPICall<GifFetchDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func fetchGifs(nextPageState : FetchedGifNextPageState,searchKey: String? ,completionHandler: @escaping GifFetcherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: GifFetchRequestGenerator(
                    nextPageState: nextPageState,
                    searchkey: searchKey,
                    networkRequestCoordinator: networkRequestCoordinator
                ),
                dataParser: GifFetchDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class GifFetchRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    private var nextPageState : FetchedGifNextPageState
    private var searchkey : String?
    
    init( nextPageState : FetchedGifNextPageState, searchkey: String?, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.nextPageState = nextPageState
        self.searchkey = searchkey
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            var initialUrl = "https://api.tenor.com/v1/trending?key=LIVDSRZULELA&limit=20"
            if let unwrappedSearchKey = searchkey{
                initialUrl = "https://api.tenor.com/v1/search?q=\(unwrappedSearchKey)&key=LIVDSRZULELA&limit=20"
                if let encodedUrl = initialUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                   initialUrl = encodedUrl
                }else{  
                    return nil
                }
            }
            switch nextPageState {
            case .Initial:
                break
            case .NextAvailable(let key):
                initialUrl = initialUrl+"&pos=\(key)"
            case .EndOfLIst:
                return nil
            }
            print("?????????? \(initialUrl)")
            return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url: URL(string: initialUrl),
                method: .GET,
                httpBodyDict: nil
            )
        }
    }
}

class GifFetchDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = FetchedGifModel
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        var nextPageState : FetchedGifNextPageState!
        if let next  = fetchedData["next"] as? String{
            if Int(next) == 0 {
                nextPageState = .EndOfLIst
                print("<<<<<<<< end of list")
            }else{
                nextPageState = .NextAvailable(next)
            }
        }else{
            nextPageState = .EndOfLIst
        }
        
        return APICallResult.Success(
            result: FetchedGifModel(
                fetchedRawGifs: fetchedData,
                error: nil,
                nextPageState: nextPageState
            )
        )
    }
}
