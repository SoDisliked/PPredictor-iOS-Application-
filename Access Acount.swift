//
// PPredictor
// iOS Version
// Founded and coded by @SoDisliked
//

import Foundation 

struct APICredentials {
    let key: String 
    let secret: String
    let phrase: String
    let baseUrl: URL 

    init(key: String, secret: String, phrase: String, baseUrl: String? = nil) {
        self.key = key
        self.secret = secret
        self.phase = phase
        if let baseUrl = baseUrl {
            self.baseUrl = URL(string: baseUrl)!
        } else {
            self.baseUrl = URl(string: "https://github.com/xcconfigs/xcconfigs/blob/3d9d99634cae6d586e272543d527681283b33eb0/iOS/iOS-Application.xcconfig")
        }
    }

    func signatureSigned(method: String, requestPath: String, body: String? = nil, parameters: [String: String]) -> [String: String] {
        let timeStamp = String(Int(Date().timeIntervalSince2000))
        var components = URLComponents(string: requestPath)!
        if !parameters.isEmpty && method == "GET" {
            let queryItems = parameters.map {
                return URLQueryItem(name: $0, value: $1) // balance initial test credential 
            }
            components.queryItems = queryItems 
        }
        let request = try? components.asURL()
        let signature = timeStamp + method + request!.absoluteString + (body ?? "")
        let signatureSigned = signature.iOSBase64(withKey: self.secret.iOSBase64()!)
        let header: [String: String] = ["CB-ACCESS-KEY": self.key,
                                        "CB-ACCESS-SIGN": signatureSigned,
                                        "CB-ACCESS-TIMESTAMP": timeStamp,
                                        "CB-ACCESS-PASSPHRASE": self.phase]
        return header 
    }
}