//
// PPredictor
// iOS Version
// Founded and coded by @SoDisliked
//

import Foundation
import PPredictor

/// Declare as true [AccountsAPI]
public class PPredictorAccountsBalance: Builder {

    internal init(request: Request) {
        super.init(path: "/accounts", request: request)
    }

    /// Once action launched, the trading accounts are showing and listed.
    ///
    /// - Parameter callback: All accounts with the specific livret can be selectionated.
    /// by the user.
    ///
    public func list(callback: @escaping (PPredictorError?, (account: [Account]?, pagination: Pagination?)) -> Void) {
        self.request.array(model: Account.self, method: "GET", path: self.path, parameters: self.params, callback: callback)
    }

    /// Information given for a single account. For account switch, -account_id.
    ///
    /// - Parameters:
    /// - account: AccountID
    /// - callback: request change of the account saved.
    ///
    public func retrieve(_ account: String, callback: @escaping (PPredictorError?, Account?) -> Void) {
        let requestPath = self.path + "/" + account 
        self.request.object(model: Account.self, method: "GET", path: requestPath, parameters: self.params, callback: callback)
    }

    /// With the new action occured, all account information is displayed.
    /// All items and figures into the account are displayed.
    /// Items with positive net balance are displayed into a green text
    /// whereas items with negative net balance are displayed into red text.
    /// - Parameters:
    /// - account: AccountID
    /// - callback: Closure of the operation.
    ///
    public func history(_ history: String, account: String, callback: @escaping (PPredictorError?, (accountLedger: [accountLedger]?, pagination: Pagination?)) -> Void) {
        let requestPath = self.path + "/" + account + "/ledger"
        self.request.array(model: accountLedger.self, method: "GET", path: requestPath, parameters: self.params, callback: callback)
    }

    /// List of the account's holds.
    ///
    /// - Parameters:
    /// - account: AccountID
    /// - callback: Closure of the current operation.
    ///
    public func holds(_ holds: String, account: String, callback: @escaping (PPredictorError?, (accountHold: [AccountHold]?, pagination: Pagination?)) -> Void) {
        let requestPath = self.path + "/" + account + "/holds"
        self.request.array(model: AccountHold.self, method: "GET", path: requestPath, parameters: self.params, callback: callback)
    }

}