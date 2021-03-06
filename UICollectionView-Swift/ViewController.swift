//
//  ViewController.swift
//  UICollectionView-Swift
//
//  Created by Gazolla on 05/06/14.
//  Copyright (c) 2014 Gazolla. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UIGestureRecognizerDelegate {

    lazy var collectionView:UICollectionView = {
        var cv = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.bounces = true
        cv.alwaysBounceVertical = true
        cv.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        cv.registerClass(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        cv.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        return cv
    }()
    
    lazy var flowLayout:UICollectionViewFlowLayout = {
        var flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)
        return flow
    }()
    
    lazy var items:NSMutableArray = {
        var it:NSMutableArray = NSMutableArray()
        return it
    }()
    
    lazy var addButton:UIBarButtonItem = {
        var btn:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTapped")
        return btn
    }()
    
    lazy var addAlert:UIAlertView = {
        var alert = UIAlertView()
        alert.delegate = self
        alert.title = "Enter Input"
        alert.addButtonWithTitle("Done")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.addButtonWithTitle("Cancel")
        return alert
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CollectionView on Swift"
        self.items.addObjectsFromArray(["My Card"])
        self.navigationItem.rightBarButtonItem = self.addButton
        self.view.addSubview(self.collectionView)
        self.navigationController?.hidesBarsWhenVerticallyCompact = true
    }
    
    var previousScrollViewYOffset:CGFloat = 0.0
    
    func addTapped() {
        self.addAlert.show()
    }
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        if (buttonIndex == 0){
            let textField = alertView.textFieldAtIndex(0)
            self.collectionView.performBatchUpdates({
                        let resultsSize = self.items.count
                        self.items.addObject(textField!.text)
                        let size = resultsSize + 1
                        var arrayWithIndexPaths = NSMutableArray()
                        var i = 0
                        for (i = resultsSize; i < resultsSize + 1; i++) {
                                    arrayWithIndexPaths.addObject(NSIndexPath(forRow: i, inSection: 0))
                        }
                        self.collectionView.insertItemsAtIndexPaths(arrayWithIndexPaths as [AnyObject])
                },
                completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        let width:CGFloat = self.view.bounds.size.width*0.98;
        let height:CGFloat = 150.0;

        return CGSizeMake(width, height)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.flowLayout.invalidateLayout()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCollectionViewCell
        
        cell.setCardText(self.items[indexPath.row] as! String)
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1).CGColor
        cell.layer.cornerRadius = 4
        cell.backgroundColor = UIColor.whiteColor()
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentSize.height > (self.view.bounds.height*0.8)) {
            var frame = self.navigationController?.navigationBar.frame
            let size = frame!.size.height - 21;
            let framePercentageHidden = ((20 - frame!.origin.y) / (frame!.size.height - 1));
            let scrollOffset = scrollView.contentOffset.y;
            let scrollDiff = scrollOffset - self.previousScrollViewYOffset;
            let scrollHeight = scrollView.frame.size.height;
            let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
            
            if (scrollOffset <= -scrollView.contentInset.top) {
                frame!.origin.y = 20
            } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
                frame!.origin.y = -size
            } else {
                frame!.origin.y = min(20, max(-size, frame!.origin.y - scrollDiff))
            }
            
            self.navigationController?.navigationBar.frame = frame!
            updateBarButtonItems(1 - framePercentageHidden)
            self.previousScrollViewYOffset = scrollOffset
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        stoppedScrolling()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate){
            stoppedScrolling()
        }
    }
    
    func stoppedScrolling(){
        let frame = self.navigationController?.navigationBar.frame
        if (frame!.origin.y < 20) {
             animateNavBarTo(-(frame!.size.height - 21))
        }
    }
    
    func updateBarButtonItems(alpha:CGFloat){
        if let left = self.navigationItem.leftBarButtonItems {
            for item:UIBarButtonItem in left as! [UIBarButtonItem] {
                if let view = item.customView {
                    view.alpha = alpha
                }
            }
        }
        
        if let right = self.navigationItem.rightBarButtonItems {
            for item:UIBarButtonItem in  right as! [UIBarButtonItem]{
                if let view = item.customView {
                    view.alpha = alpha
                }
            }
        }

        let black = UIColor.blackColor() // 1.0 alpha
        let semi = black.colorWithAlphaComponent(alpha)
        var nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: semi]

        self.navigationController?.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor.colorWithAlphaComponent(alpha)

    }
    
    func animateNavBarTo(y:CGFloat){
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var frame = self.navigationController?.navigationBar.frame
            let alpha:CGFloat = (frame!.origin.y >= y ? 0 : 1)
            frame!.origin.y = y
            self.navigationController?.navigationBar.frame=frame!
            self.updateBarButtonItems(alpha)
        })
    }
}
