
import UIKit

class ActivityIndicator: UIView {
    
    var spinner: UIView?
    
    func showLoading(onView: UIView) {
        let spinnerView = UIView(frame: onView.bounds)
        spinnerView.backgroundColor = .gray
        spinnerView.backgroundColor = spinnerView.backgroundColor?.withAlphaComponent(0.1)
        let ai = UIActivityIndicatorView(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        spinner = spinnerView
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.spinner?.removeFromSuperview()
            self.spinner = nil
        }
    }
}
