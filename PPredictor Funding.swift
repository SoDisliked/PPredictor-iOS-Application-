//
// PPredictor
// iOS Version
// Founded and coded by @SoDisliked
//

import Foundation
import PPredictor

/// [FundingAPI] --> new API ordered for account accessibility
/// which would add the option for the user to have an access
/// to money funding, both into the demo and real modes of 
/// trading.
///
public class PPredictorFunding: Builder {

    internal init(request: Request) {
        super.init(path: "/orders", request: request)
    }

    /// New list of funding options for the user into his investing choices.
    ///
    /// - Parameters:
    /// - funding: access to the funding option.
    /// - choose_mode: the user can access between 'demo' or 'real' for funding access.
    /// - limit: the user can limit the funding value he wants, ranging from "5000$", "10000$" or "20000$".
    /// - callback: returns and closes the operation.
    public func funding(withPrice price: String, size: String, side: String, productId: String, callback: @escaping (PPredictorError?, Order?) -> Void {
        var params = self.params 
        params["price"] = price 
        params["size"] = size 
        params["side"] = side 
        params["product_id"] = productId
        self.request.object(model: Order.self, method: "POST", path: self.path, parameters: params, callback: callback)
    /// Builder for the funding system.
    ///
    })
}