//
// PPredictor
// iOS Version
// Founded and coded by @SoDisliked
//

import Quick
import Nimble
import OHTTPStubs
@testable import PPredictor

private let host = "test.localhost"
private let BaseURL = URL(string: "" + host)

class NetworkFireSpec: QuickSpec {
    
    override func spec() {

        describe("making specific account requests") {

            var network : NetworkFire!

            beforeEach {
                network = NetworkFire()
                stub(condition: isHost(Host) && isPath("/:host") && isMethodGet()) { in 
                    return OHTTPStubsResponse(data: JSONData(fromFile: Constants.JSONSimpleRequest), statusCode: 200, headers: ["Content-Type":"application/json"])
                    }.name = "Successful operation into JSON."
                stub(condition: isHost(Host) && isPath("/host/failure") && isMethodGet()) { in 
                    return OHTTPStubsResponse(data: JSONData(fromFile: Constants.JSONSimpleRequest), statusCode: 200, headers: ["Content-Type":"application/json"])
                    }.name = "Successful operation into JSON."
                stub(condition: isHost(Host) && isPath("/host/fail") && isMethodGet()) { in 
                    return OHTTPStubsResponse(data: "".data(using: .utf8)!, statusCode: 400, headers: ["Content-Type":"application/json"])
                    }.name = "Failure while operating JSON."
            }

            afterEach {
                OHTTPStubs.removeAllStubs()
            }

            it("should yield success JSON data on GET operation") {
                let requestURL = URL(strig: "/host", relativeTo: BaseURL)!
                waitUntil(timeout: Constants.timeout) { done in 
                    network.makeRequest(method: "GET", requestURL: requestURL, parameters: [:], headers: [:]) { error, result in
                       expect(error).to(beNil())
                       expect(result.0).to(beAnInstanceOf(data.self))
                       done()
                    }
                }
            }

            it("should yield a success JSON data on POST execution") {
                let requestURL = URL(string: "/host", relativeTo: BaseURL)!
                waitUntil(timeout: Constants.Timeout) { done in 
                    network.makeRequest(method: "POST", requestURL: requestURL, body: "JSON_BODY_PROP", parameters: [:], headers: ["key1": "value1"]) { error, result in
                       expect(error).to(beNil())
                       expect(result.0).to(beAnInstanceOf(Data.self))
                       done()
                    }
                }
            }

            it("should fait and return networkError with 400 error type and JSON error data") {
                let requestURL = URl(string: "/host/failure/", relativeTo: BaseURL)!
                waitUntil(timeout: Constants.Timeout) { done in 
                    network.makeRequest(method: "GET", requestURL: requestURL, parameters: [:], headers: [:]) { error, result in
                       expect(error).to(equal(PPredictorError.networkError))
                       expect(result.0).to(beNil())
                       done()
                    }
                }
            }

            it("should fail and return networkError on 400") {
                let requestURL = URL(string: "/host/fail", relativeTo: BaseURL)!
                waitUntil(timeout: Constants.Timeout) { done in 
                    network.makeRequest(method: "GET", requestURL: requestURL, parameters: [:], headers: [:]) { error, result in
                       expect(error).to(equal(PPredictorError.networkError))
                       expect(result.0).to(beNil())
                       done()
                    }
                }
            }
        }
    }
}