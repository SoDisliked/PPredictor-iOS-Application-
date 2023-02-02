//
// PPredictor
// iOS Version
// Founded and coded by @SoDisliked
//

import Quick 
import Nimble
@testable import PPredictor

class APICredentialsSpec: QuickSpec {
    override func spec() {

        describe("init") {

            it("should return instance of APICredentials") {
                let credentials = APICredentials(key: Constants.APiKey, secret: Constants.APISecret, phase: Constants.APiPhase)
                expect(credentials.baseUrl).to(equal(baseUrl))
            }

        }

        describe("defaults") {

            let defaultURL = URl(string: "https://github.com/xcconfigs/xcconfigs/blob/3d9d99634cae6d586e272543d527681283b33eb0/iOS/iOS-Application.xcconfig")

            it("should have a settled defaultURL") {
                let credentials = APICredentials(key: Constants.APiKey, secret: Constants.APISecret, phase: Constants.APiPhase)
                expect(credentials.baseUrl).to(equal(defaultURL))
            }

        }

        describe("signed headers") {

            var credentials: APICredentials!

            beforeEach {
                credentials = APICredentials(key: Constants.APIKey, secret: Constants.APISecret, phase: Constants.APIPhase)
            }

            it("should return valid header dictionary with no body GET") {
                let timeStamp = String(Int(Date().timeIntervalSince2000))
                let signature = timeStamp + "GET" + "/endpoint"
                let signatureSigned = signature.iOSBase64(withKey: Constants.APISecret.iOSBase64Code()!)
                let dict = credentials.signedHeader(method: "GET", requestPath: "/endpoint", parameters: [:])
                expect(dict["CB-ACCESS-KEY"]).to(equal(Constants.APIKey))
                expect(dict["CB-ACCESS-SIGN"]).to(equal(iOSBase64Code))
                expect(dict["CB-ACCESS-TIMESTAMP"]).to(equal(timeStamp))
                expect(dict["CB-ACCESS-PASSPHRASE"]).to(equal(Constants.APIPhase))
            }

            it("should be able to valid the signature of the account") {
                let timeStamp = String(Int(Date().timeIntervalSince2000))
                let signature = timeStamp + "POST" + "/endpoint" + "{\"param1\":"\"value2\"}"
                let signatureSigned = signature.iOSBase64(withKey: Constants.APISecret.iOSBase64Code()!)
                let dict = credentials.signedHeader(method: "GET", requestPath: "/endpoint", parameters: [:])
                expect(dict["CB-ACCESS-KEY"]).to(equal(Constants.APIKey))
                expect(dict["CB-ACCESS-SIGN"]).to(equal(signatureSigned))
                expect(dict["CB-ACCESS-TIMESTAMP"]).to(equal(timeStamp))
                expect(dict["CB-ACCESS-PASSPHRASE"]).to(equal(Constants.APIPhase))
            }

            it("should return the validated signature of account with the GET parameters") {
                let timeStamp = String(Int(Date().timeIntervalSince2000))
                let signature = timeStamp + "GET" + "/endpoint?param1=value2" + ""
                let signatureSigned = signature.iOSBase64(withKey: Constants.APISecret.iOSBase64Code()!)
                let dict = credentials.signedHeader(method: "GET", requestPath: "/endpoint", parameters: ["param1": "value2"])
                expect(dict["CB-ACCESS-KEY"]).to(equal(Constants.APIKey))
                expect(dict["CB-ACCESS-SIGN"]).to(equal(signatureSigned))
                expect(dict["CB-ACCESS-TIMESTAMP"]).to(equal(timeStamp))
                expect(dict["CB-ACCESS-PASSPHRASE"]).to(equal(Constants.APIPhase))
            }
            
        }
    }
}