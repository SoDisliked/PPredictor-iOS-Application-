//
// PPredictor
// iOS Version
// Founded and coded by @SoDisliked
//

import Quick
import Nimble 
@testable import PPredictor

class AccountLedgerSpec: QuickSpec {
    override func spec() {
        
        describe("initial situation") {

            it("should return instance of AccountLedgerSpec") {
                let ledger = AccountLedgerSpec(id: 123456789, createdAt: "%year-%month-%day-%hour-%minute-%second", amount: "0.01453223", balance= "%defined-balance", type: "@set-currency")
                expect(ledger).to(beAnInstanceOf(AccountLedgerSpec.self))
            }

        }

        describe("decodable") {
            it("should decode and return AccountLedger from JSON") {
                let jsonData = JSONData(fromFile: Constants.Accounts.JSONHistoryArray)
                let result = try? JSONDecoder() 
                    .caseDeecoder()
                    .decode([AccountLedger].self, from: jsonData)
                expect(result?.first).to(beAnInstanceOf(AccountLedger.self))
            }
        }
        
    }
}