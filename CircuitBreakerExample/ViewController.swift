//
//  ViewController.swift
//  CircuitBreakerExample
//
//  Created by Alex Drozhak on 9/14/17.
//  Copyright © 2017 93Hz. All rights reserved.
//

import UIKit

enum SampleRequest: Int {
    case success = 200
    case badRequest = 400
    case notFound  = 404
    case internalServerError = 500
}

extension SampleRequest {
    static var all: [SampleRequest] {
        return [.success, .badRequest, .notFound, .internalServerError]
    }
}

extension SampleRequest: ResourceType {
    var baseUrl: String {
        return "https://httpbin.org/status/"
    }
    
    var path: String {
        return "\(rawValue)"
    }
}

class ViewController: UIViewController {
    
    fileprivate let baseProvider = BaseResourceProvider<SampleRequest>()
    fileprivate let circuitBreakerProvider = CircuitBreakerProvider<SampleRequest>()

    override func viewDidLoad() {
        super.viewDidLoad()
        textView?.text = String()
    }
    
    fileprivate func call(for resource: SampleRequest) {
        guard let switcher = breakerSwitch, let textView = textView else {
            fatalError("Something wrong with UI layout")
        }
        
        let completion: ResourceResultCompletion = { [weak self] result in
            DispatchQueue.main.async {
                textView.text.append("\n\(result)")
                self?.scrollTextViewIfNeeded(textView)
            }
        }
        
        if switcher.isOn {
            circuitBreakerProvider.request(resource: resource, with: completion)
        } else {
            baseProvider.request(resource: resource, with: completion)
        }
    }
    
    fileprivate func scrollTextViewIfNeeded(_ textView: UITextView) {
        let contentHeight = textView.contentSize.height
        let frameHeight = textView.frame.size.height
        if contentHeight > frameHeight {
            textView.setContentOffset(CGPoint(x: 0, y: contentHeight - frameHeight),
                                      animated: true)
        }
    }
    
    @IBOutlet fileprivate weak var textView: UITextView?
    @IBOutlet fileprivate weak var breakerSwitch: UISwitch?
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SampleRequest.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SomeCell", for: indexPath)
        cell.textLabel?.text = "Request \(SampleRequest.all[indexPath.row].rawValue)"
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        call(for: SampleRequest.all[indexPath.row])
    }
}
