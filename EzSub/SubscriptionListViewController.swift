//
//  SubscriptionListViewController.swift
//  EzSub
//
//  Created by Alex Geier on 4/5/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse

protocol Subscription {
    var type: SubscriptionType { get }
    var name: String { get }
    var amount: Double { get }
    var billingDay: Int { get }
}

struct FixedSubscription: Subscription {
    let type: SubscriptionType = .fixed
    let name: String
    let amount: Double
    let billingDay: Int
}

struct DynamicSubscription: Subscription {
    let type: SubscriptionType = .dynamic
    let amount: Double = 0
    let name: String
    let billingDay: Int
}

class SubscriptionListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var subscriptionListTableView: UITableView!
    
    let fixedSubscriptionCellId = "fixed"
    let dynamicSubscriptionCellId = "dynamic"
    
    var subscriptions: [Subscription] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriptionListTableView.delegate = self
        subscriptionListTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        subscriptions = []
        
        let group = DispatchGroup()

        group.enter()
        group.enter()
        
        let fixedQuery = PFQuery(className: "FixedSubscription")
        fixedQuery.whereKey("user", equalTo: PFUser.current())
        
        fixedQuery.findObjectsInBackground { (fixedSubscriptions, error) in
            if (fixedSubscriptions != nil) {
                fixedSubscriptions?.forEach({ (subscription) in
                    let name = subscription["name"]
                    let amount = subscription["amount"]
                    let billingDay = subscription["billingDay"]
                    
                    self.subscriptions.append(FixedSubscription(name: name as! String, amount: amount as! Double, billingDay: billingDay as! Int))
                })
                
                group.leave()
            }
        }
        
        let dynamicQuery = PFQuery(className: "DynamicSubscription")
        dynamicQuery.whereKey("user", equalTo: PFUser.current())
        
        dynamicQuery.findObjectsInBackground { (dynamicSubscriptions, error) in
            if (dynamicSubscriptions != nil) {
                dynamicSubscriptions?.forEach({ (subscription) in
                    let name = subscription["name"]
                    let billingDay = subscription["billingDay"]
                    
                    self.subscriptions.append(DynamicSubscription(name: name as! String, billingDay: billingDay as! Int))
                })
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.subscriptions.sort { (sub1, sub2) -> Bool in
                if (sub1.billingDay == sub2.billingDay) {
                    return sub1.name < sub2.name
                }
                return sub1.billingDay < sub2.billingDay
            }
            self.subscriptionListTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subscription = subscriptions[indexPath.row]
        if (subscription.type == .fixed) {
            let cell = subscriptionListTableView.dequeueReusableCell(withIdentifier: fixedSubscriptionCellId) as! FixedSubscriptionCell
            cell.subscriptionName.text = subscription.name
            cell.subscriptionAmount.text = "$\(subscription.amount)"
            
            return cell
        } else {
            let cell = subscriptionListTableView.dequeueReusableCell(withIdentifier: dynamicSubscriptionCellId) as! DynamicSubscriptionCell
            cell.subscriptionName.text = subscription.name
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subscription = subscriptions[indexPath.row]
        if (subscription.type == .fixed) {
            performSegue(withIdentifier: "fixedSubscriptionDetail", sender: subscription)
        } else {
            performSegue(withIdentifier: "dynamicSubscriptionDetail", sender: subscription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fixedSubscriptionDetail") {
            if let vc: FixedSubscriptionDetailViewController = segue.destination as? FixedSubscriptionDetailViewController {
                // TODO: sender is nil, so navigation bar title isn't being set
                vc.navigationItem.title = (sender as? Subscription)?.name
            }
        } else if (segue.identifier == "dynamicSubscriptionDetail") {
            if let vc: DynamicSubscriptionDetailViewController = segue.destination as? DynamicSubscriptionDetailViewController {
                // TODO: sender is nil, so navigation bar title isn't being set
                vc.navigationItem.title = (sender as? Subscription)?.name
            }
        }
    }
}
