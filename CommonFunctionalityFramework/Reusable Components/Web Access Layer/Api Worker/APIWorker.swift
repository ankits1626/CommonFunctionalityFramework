//
//  APIWorker.swift
//  SKOR
//
//  Created by Rewardz on 09/09/17.
//  Copyright © 2017 Nikhil. All rights reserved.
//

import UIKit
import Security
import CommonCrypto

public enum HTTPMethod: String {
    case DELETE = "DELETE"
    case GET = "GET"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
    case PATCH = "PATCH"
    case POST = "POST"
    case PUT = "PUT"
}

let UNAUTHORIZED = 401

/*extension Int {
 public var isOK : Bool{
 if 200 ... 299 ~= self {
 return true
 }
 return false
 }
 }*/

typealias ApiCallCompletionHandler<T> = (APICallResult<T>) -> Void
public let REQUEST_TIME_OUT = 40

public protocol BaseURLProviderProtocol {
    func baseURLString() -> String?
}
public protocol TokenProviderProtocol {
    func fetchAccessToken() -> String?
    func getDeviceSelectedLanguage() -> String
    func fetchUserAgent() -> String
}
protocol DeviceInfoProviderProtocol {
    func getDeviceInfo() -> String
}
protocol RequestSynthesizer {
    func synthesizeRequest(apiRequest : URLRequest , httpBody: Data?) -> URLRequest
}
protocol CommonAPIProtocol {
    associatedtype ParserType : DataParserProtocol
    var apiRequestProvider : APIRequestGeneratorProtocol {get}
    var dataParser : ParserType{get}
    func callAPI(completionHandler: @escaping (APICallResult<ParserType.ResultType>) -> Void)
}
public protocol DataParserProtocol {
    associatedtype ExpectedRawDataType
    associatedtype ResultType
    func parseFetchedData(fetchedData : ExpectedRawDataType) -> APICallResult<ResultType>
}

public protocol APIRequestGeneratorProtocol {
    var urlBuilder : ParameterizedURLBuilder{get set}
    var requestBuilder : APIRequestBuilderProtocol{get set}
    var apiRequest : URLRequest? {get}
}


public enum APICallResult<ResultType>{
    case Success (result : ResultType)
    case SuccessWithNoResponseData
    case Failure (error : APIError)
}

public enum APIError : Error , Equatable{
    case CannotFetch
    case UnexpectedResult
    case ResponseError (statusCode : Int , errorMessage : String?)
    case Others (String)
  case notFound
    
    public func displayableErrorMessage() -> String {
        switch self {
        case .CannotFetch:
            return NSLocalizedString("Unable to fetch", comment: "")
        case .Others(let error):
            return error
        case .ResponseError(let statusCode, let errorMessage):
            if let unwrappedError = errorMessage{
                return unwrappedError
            }else{
                return HTTPURLResponse.localizedString(forStatusCode: statusCode)
            }
        case .UnexpectedResult:
            return NSLocalizedString("Unexpected response is received.", comment: "")
        case .notFound:
          return "Not Found"//.localized
      }
    }
    
    func errorStatusCode() -> Int? {
        switch self {
        case .ResponseError(let statusCode, _):
            return statusCode
        default:
            return nil
        }
    }
}

public func ==(lhs: APIError, rhs: APIError) -> Bool{
    switch (lhs, rhs) {
    case (.CannotFetch, .CannotFetch) : return true
    case (.UnexpectedResult, .UnexpectedResult): return true
    case (.ResponseError(let a1, let b1), .ResponseError(let a2, let b2)) where ((a1 == a2) && (b1 == b2)): return true
    case (.Others(let a), .Others(let b)) where a == b: return true
    default: return false
    }
}

public protocol LogoutResponseHandler{
    func handleLogoutResponse()
}

public class CommonAPICall<P: DataParserProtocol> : CommonAPIProtocol {
    typealias ParserType = P
    var apiRequestProvider: APIRequestGeneratorProtocol
    var dataParser: P
    var logouthandler : LogoutResponseHandler
    private let sessionSecurityManager = SessionSecurityManager()
    
    public init(apiRequestProvider: APIRequestGeneratorProtocol, dataParser: P, logouthandler : LogoutResponseHandler) {
        self.apiRequestProvider = apiRequestProvider
        self.dataParser = dataParser
        self.logouthandler = logouthandler
    }
    
    private func logoutAppforAuthondicationError () {
        logouthandler.handleLogoutResponse()
    }

    public func callAPI(completionHandler: @escaping (APICallResult<P.ResultType>) -> Void)  {
        let session = URLSession(configuration: .ephemeral, delegate: sessionSecurityManager, delegateQueue: nil)
        if let urlRequest = apiRequestProvider.apiRequest{
            let apiTask = session.dataTask(with: urlRequest) { (data, response, error) in
                let apiCallResult : APICallResult<P.ResultType>!
                if let unwrappedError = error{
                    apiCallResult = APICallResult.Failure(error: APIError.Others(unwrappedError.localizedDescription))
                }else{
                    if let httpResponse = response as? HTTPURLResponse{
                        if httpResponse.statusCode.isUnauthorized{
                            self.logoutAppforAuthondicationError()
                            return // [TO:Do] this should not be return
                        }
                        if httpResponse.statusCode.isOK{
                            if let unwrappedData = data{
                                if let fetchedJSON  = (try? JSONSerialization.jsonObject(with: unwrappedData, options: .mutableLeaves)) as? P.ExpectedRawDataType{
                                    apiCallResult = self.dataParser.parseFetchedData(fetchedData: fetchedJSON)
                                }else if let responseStr = String(data: unwrappedData, encoding: String.Encoding.utf8)as? P.ExpectedRawDataType{
                                    apiCallResult = self.dataParser.parseFetchedData(fetchedData: responseStr)
                                }else{
                                    apiCallResult = APICallResult.Failure(error: APIError.UnexpectedResult)
                                }
                            }else{
                                apiCallResult = APICallResult.SuccessWithNoResponseData
                            }
                        }else{
                            var errorMessage : String?
                            if let unwrappedData = data{
                                if let fetchedJSON  = (try? JSONSerialization.jsonObject(with: unwrappedData, options: .mutableLeaves)){
                                    if let dictionary = fetchedJSON as? NSArray {
                                        if let errorDetail = dictionary[0]as? String{
                                            errorMessage = errorDetail
                                        }
                                    }
                                    else if let dictionary = fetchedJSON as? NSDictionary {
                                        if let errorvalues = dictionary.allValues.first as? NSArray
                                        {
                                            let errorkey = dictionary.allKeys.first as? String ?? ""
                                            let value = errorvalues[0]as? String ?? ""
                                            errorMessage = "\(errorkey): \(value)"
                                        }
                                    }
                                }
                            }
                            apiCallResult = APICallResult.Failure(error: APIError.ResponseError(statusCode: httpResponse.statusCode, errorMessage: errorMessage))
                        }
                        
                    }else{
                        apiCallResult = APICallResult.Failure(error: APIError.Others(NSLocalizedString("Unknown Response.", comment: "")))
                    }
                }
                completionHandler(apiCallResult)
            }
            apiTask.resume()
        }else{
            completionHandler(APICallResult.Failure(error: APIError.Others(NSLocalizedString("Invalid request", comment: ""))))
        }
    }
}

class SessionSecurityManager : NSObject, URLSessionDelegate {
    private let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    private func sha256(data : Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))

        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
        }


        return Data(hash).base64EncodedString()
    }

    private func publicKey(for certificate: SecCertificate) -> SecKey? {
        if #available(iOS 12.0, *) {
            return SecCertificateCopyKey(certificate)
        } else if #available(iOS 10.3, *) {
            return SecCertificateCopyPublicKey(certificate)
        } else {
            var possibleTrust: SecTrust?
            SecTrustCreateWithCertificates(certificate, SecPolicyCreateBasicX509(), &possibleTrust)
            guard let trust = possibleTrust else { return nil }
            var result: SecTrustResultType = .unspecified
            SecTrustEvaluate(trust, &result)
            return SecTrustCopyPublicKey(trust)
        }
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return
        }
        let localKeys = ["47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=",
                         "83cWakwMeZJYVKBUj1sAb6uyThrnGbq99waoeBZff1g=",
                         "fbT/gH90IH3fKlj7VF3NXnZlEawBvbxM9pBsnsVjcaI=",
                         "gRapsZTRzcmiMJZGJ3HImt/WzSORwmdo8PNZUK/2Dag="]

        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
           let serverPublicKey = publicKey(for: serverCertificate),
           let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil ){
            let data:Data = serverPublicKeyData as Data
            // Server Hash key
            let serverHashKey = sha256(data: data)
            // Local Hash Key
            if (localKeys.contains(serverHashKey)) {
                // Success! This is our server
                print("Public key pinning is successfully completed")
                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                return
            }else{
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }else{
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

}

//MARK:- Providers


public class DeviceInfoProvider: DeviceInfoProviderProtocol {
    public init(){}
    public func getDeviceInfo() -> String {
        
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        let appVersion = nsObject as! String
      
        let build: AnyObject? = Bundle.main.infoDictionary!["CFBundleVersion"] as AnyObject?
        let buildVersion = build as! String
      
        //OS Version
        let OSVersion = UIDevice.current.systemVersion
        
        //iOS Model and Make
        let deviceType = UIDevice.current.deviceType.rawValue
        return "iOS | " + deviceType + " | " + OSVersion + " | " + appVersion + " | " + buildVersion 
    }
}

extension Int {
    public var isOK : Bool {
        if 200 ... 299 ~= self {
            return true
        }
        return false
    }
    public var isUnauthorized : Bool {
        if 401 == self {
            return true
        }
        return false
    }
}
