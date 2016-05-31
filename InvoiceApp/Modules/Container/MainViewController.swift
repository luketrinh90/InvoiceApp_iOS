//
//  MainViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/9/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    private var activeViewController: UIViewController? {
        didSet {
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    private func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMoveToParentViewController(nil)
            inActiveVC.view.removeFromSuperview()
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }
    
    private func updateActiveViewController() {
        if let activeVC = activeViewController {
            // call before adding child view controller's view as subview
            addChildViewController(activeVC)
            
            //iOS 9 still uses 49 points for the Tab Bar (and 64 points for a navigation bar)
            activeVC.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            
            self.view.addSubview(activeVC.view)
            
            UIView.transitionWithView(self.view, duration: 0.3, options: .TransitionCrossDissolve, animations: { _ in
                // call before adding child view controller's view as subview
                activeVC.didMoveToParentViewController(self)
                }, completion: nil)
        }
    }
    
    @objc func onRequestForNavigation(notification: NSNotification){
        let notificationInfo:String = notification.object as! String
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch notificationInfo {
        case NotificationConstants.ViewController.InvoiceViewController:
            let vc = storyboard.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.InvoiceViewController)
            activeViewController = vc
            break
        default:
            break
        }
    }
    
    /* Core class */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(MainViewController.onRequestForNavigation(_:)),
            name: NotificationConstants.Navigation.kNotificationRequestNavigation,
            object: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.InvoiceViewController)
        activeViewController = vc
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hidden = true
    }
}
