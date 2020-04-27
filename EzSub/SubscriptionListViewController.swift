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
    var id: String { get }
    var payedThisMonth: Bool { get set }
}

struct FixedSubscription: Subscription {
    let type: SubscriptionType = .fixed
    let name: String
    let amount: Double
    let billingDay: Int
    let id: String
    var payedThisMonth: Bool
    
}

struct DynamicSubscription: Subscription {
    let type: SubscriptionType = .dynamic
    let amount: Double = 0
    let name: String
    let billingDay: Int
    let id: String
    var payedThisMonth: Bool
}

class SubscriptionListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var subscriptionListTableView: UITableView!
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    
    let fixedSubscriptionCellId = "fixed"
    let dynamicSubscriptionCellId = "dynamic"
    
    var subscriptions: [Subscription] = []
    
    var parseObjects: [String: PFObject] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriptionListTableView.delegate = self
        subscriptionListTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        subscriptions = []
        var total:Float = 0
        
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
                    let amount_f = (amount as? NSNumber)?.floatValue ?? 0
                    let payedThisMonth = subscription["payedThisMonth"]
                    self.subscriptions.append(FixedSubscription(name: name as! String, amount: amount as! Double, billingDay: billingDay as! Int, id: subscription.objectId!, payedThisMonth: payedThisMonth as! Bool))
                    
                    total = total + amount_f
                    
                    self.parseObjects[subscription.objectId!] = subscription
                    
                    self.totalAmountLabel.text = String(format: "$%.2f", total)
                    
                })
            }
            group.leave()
        }
        
        let dynamicQuery = PFQuery(className: "DynamicSubscription")
        dynamicQuery.whereKey("user", equalTo: PFUser.current())
        
        dynamicQuery.findObjectsInBackground { (dynamicSubscriptions, error) in
            if (dynamicSubscriptions != nil) {
                dynamicSubscriptions?.forEach({ (subscription) in
                    let name = subscription["name"]
                    let billingDay = subscription["billingDay"]
                    let payedThisMonth = subscription["payedThisMonth"]
                    
                    if (!(payedThisMonth as! Bool)) {
                        self.subscriptions.append(DynamicSubscription(name: name as! String, billingDay: billingDay as! Int, id: subscription.objectId!, payedThisMonth: payedThisMonth as! Bool))
                        
                        self.parseObjects[subscription.objectId!] = subscription
                    }
                    
                    
                    
                })
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.subscriptions.sort { (sub1, sub2) -> Bool in
                if (sub1.payedThisMonth && !sub2.payedThisMonth) {
                    return false
                } else if (!sub1.payedThisMonth && sub2.payedThisMonth) {
                    return true
                }
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
        
        let calendar = Calendar.current
        let date = Date()
        let dayOfMonth = calendar.component(.day, from: date)
        
        let daysDueIn = subscription.billingDay - dayOfMonth
        
        if (subscription.type == .fixed) {
            print("FIXED CELL")
            let cell = subscriptionListTableView.dequeueReusableCell(withIdentifier: fixedSubscriptionCellId) as! FixedSubscriptionCell
            cell.subscriptionName.text = subscription.name
            cell.subscriptionAmount.text = "$\(subscription.amount)"
            
            if (subscription.payedThisMonth) {
                cell.dueDateLabel.text = "Due next month"
            } else {
                if (daysDueIn < 0) {
                    cell.dueDateLabel.text = "Past due"
                } else if (daysDueIn == 0) {
                    cell.dueDateLabel.text = "Today"
                } else if (daysDueIn == 1){
                    cell.dueDateLabel.text = "\(daysDueIn) day"
                } else {
                    cell.dueDateLabel.text = "\(daysDueIn) days"
                }
            }
            
            return cell
        } else {
            print("DYNAMIC CELL")
            let cell = subscriptionListTableView.dequeueReusableCell(withIdentifier: dynamicSubscriptionCellId) as! DynamicSubscriptionCell
            cell.subscriptionName.text = subscription.name
            
            if (subscription.payedThisMonth) {
                cell.dueDateLabel.text = "Due next month"
            } else {
                if (daysDueIn < 0) {
                    cell.dueDateLabel.text = "Past due"
                } else if (daysDueIn == 0) {
                    cell.dueDateLabel.text = "Today"
                } else if (daysDueIn == 1){
                    cell.dueDateLabel.text = "\(daysDueIn) day"
                } else {
                    cell.dueDateLabel.text = "\(daysDueIn) days"
                }
            }
            
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            parseObjects[subscriptions[indexPath.row].id]?.deleteInBackground()
            let amount = subscriptions[indexPath.row].amount
            subscriptions.remove(at: indexPath.row)
            var totalAmount = Double(totalAmountLabel.text!.replacingOccurrences(of: "$", with: ""))
            totalAmount! -= amount
            
            totalAmountLabel.text = String(format: "$%.2f", totalAmount!)
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fixedSubscriptionDetail") {
            if let vc: FixedSubscriptionDetailViewController = segue.destination as? FixedSubscriptionDetailViewController {
                
                let subscription = sender as? FixedSubscription
                if subscription != nil {
                    vc.navigationItem.title = subscription?.name
                    vc.subscription = subscription
                }
            }
        } else if (segue.identifier == "dynamicSubscriptionDetail") {
            if let vc: DynamicSubscriptionDetailViewController = segue.destination as? DynamicSubscriptionDetailViewController {
                
                let subscription = sender as? DynamicSubscription
                if subscription != nil {
                    vc.navigationItem.title = subscription?.name
                    vc.subscription = subscription
                }
            }
        }
    }
}
