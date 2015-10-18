//
//  SEPageViewWithNavigationBar.swift
//  PageViewWithNavigationBar
//
//  https://github.com/ifau/SEPageViewWithNavigationBar
//
//  Created by Seliverstov Evgeney on 15/08/15.
//  Copyright (c) 2015 Seliverstov Evgeney. All rights reserved.
//

import UIKit

let SEStoryboardSegueIdentifier = "SEPage"
let SESegueDoneNotification = "kSESegueDoneNotification"

class SEPageViewWithNavigationBar: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBInspectable var pageIndicatorTintColor : UIColor = UIColor(white: 1.0, alpha: 0.4)
    {
        didSet
        {
            if titleView != nil
            {
                titleView.pageControl.pageIndicatorTintColor = pageIndicatorTintColor
            }
        }
    }
    
    @IBInspectable var currentPageIndicatorTintColor : UIColor = UIColor.whiteColor()
    {
        didSet
        {
            if titleView != nil
            {
                titleView.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
            }
        }
    }
    
    var titleLabelFont : UIFont = UIFont.systemFontOfSize(16)
    {
        didSet
        {
            if titleView != nil
            {
                titleView.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: currentPage, inSection: 0)])
            }
        }
    }
    
    @IBInspectable var titleLabelTextColor : UIColor = UIColor.whiteColor()
    {
        didSet
        {
            if titleView != nil
            {
                titleView.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: currentPage, inSection: 0)])
            }
        }
    }
    
    var viewControllers : [UIViewController] = []
    
    private var currentPage : Int = 0
    private var pageViewController : UIPageViewController!
    private var titleView : SENavigationBarView!
    
    private var customTitleCell : ((titleCell: UICollectionViewCell, pageIndex: Int) -> (UICollectionViewCell))?
    private var customTitleCellClass: AnyClass?
    
    // MARK: - Initialization
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "segueDone:", name: SESegueDoneNotification, object: nil)
        
        if viewControllerCanPerformSegue(self, segueIdentifier: SEStoryboardSegueIdentifier)
        {
            self.performSegueWithIdentifier(SEStoryboardSegueIdentifier, sender: self)
        }
        else
        {
            initialize()
        }
    }
    
    func segueDone(notification: NSNotification)
    {
        let segue = notification.object as! SEPageViewSegue
        viewControllers.append(segue.destinationViewController)
        
        if viewControllerCanPerformSegue(segue.destinationViewController, segueIdentifier: SEStoryboardSegueIdentifier)
        {
            segue.performNextSegue()
        }
        else
        {
            initialize()
        }
    }
    
    private func initialize()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SESegueDoneNotification, object: nil)
        
        if viewControllers.count > 0
        {
            pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
            pageViewController.dataSource = self
            pageViewController.delegate = self
            
            pageViewController.setViewControllers([viewControllers[0]], direction: .Forward, animated: false, completion: nil)
            
            // self.addChildViewController(pageViewController)
            self.view.addSubview(pageViewController.view)
            // pageViewController.didMoveToParentViewController(self)
            
            for view in pageViewController.view.subviews
            {
                if let scrollView = view as? UIScrollView
                {
                    scrollView.delegate = self
                }
            }
            
            if self.navigationController != nil
            {
                let barframe = self.navigationController!.navigationBar.frame
                let titleframe = CGRect(x: 0, y: 0, width: barframe.size.width - 88, height: barframe.size.height)
                
                titleView = SENavigationBarView(frame: titleframe)
                titleView.pageControl.numberOfPages = viewControllers.count
                titleView.pageControl.currentPage = 0
                titleView.pageControl.pageIndicatorTintColor = pageIndicatorTintColor
                titleView.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
                titleView.collectionView.delegate = self
                titleView.collectionView.dataSource = self
                self.navigationItem.titleView = titleView
                
                if customTitleCell != nil && customTitleCellClass != nil
                {
                    titleView.collectionView.registerClass(customTitleCellClass!, forCellWithReuseIdentifier: "customHeaderCell")
                }
            }
        }
    }
    
    // MARK: - UIPageViewController delegate
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        if let index = viewControllers.indexOf(viewController)
        {
            return index + 1 == viewControllers.count ? nil : viewControllers[(index + 1)]
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        if let index = viewControllers.indexOf(viewController)
        {
            return index - 1 < 0 ? nil : viewControllers[(index - 1)]
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        let currentViewController = pageViewController.viewControllers!.last!
        
        if let currentIndex = viewControllers.indexOf(currentViewController)
        {
            currentPage = currentIndex
            titleView.pageControl.currentPage = currentIndex
        }
    }
    
    // MARK: - UIScrollView delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if !(scrollView is UICollectionView) && titleView != nil
        {
            let allScrollViewContentSize = CGFloat(viewControllers.count) * self.view.frame.size.width
            let currentScrollViewContentOffset = (CGFloat(currentPage) * self.view.frame.size.width) + (scrollView.contentOffset.x - self.view.frame.size.width)
            let scrollPercent = currentScrollViewContentOffset * 100 / allScrollViewContentSize

            titleView.collectionView.contentOffset = CGPoint(x: titleView.collectionView.contentSize.width * scrollPercent / 100, y: 0.0)
        }
    }
    
    // MARK: - UICollectionView delegate
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if customTitleCell != nil
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("customHeaderCell", forIndexPath: indexPath) 
            return customTitleCell!(titleCell: cell, pageIndex: indexPath.row)
        }
        else
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("headerCell", forIndexPath: indexPath) as! SENavigationBarTitleCell
            let viewController = viewControllers[indexPath.row]
            
            cell.label.text = viewController.title == nil ? "" : viewController.title
            cell.label.font = titleLabelFont
            cell.label.textColor = titleLabelTextColor
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return collectionView.frame.size
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return viewControllers.count
    }
    
    // MARK: - Other
    
    func setCustomTitle(cellClass cellClass: AnyClass, delegateCallback: ((titleCell: UICollectionViewCell, currentPage: Int) -> (UICollectionViewCell)))
    {
        customTitleCellClass = cellClass
        customTitleCell = delegateCallback
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval)
    {
        if let _titleView = self.navigationItem.titleView
        {
            let barframe = self.navigationController!.navigationBar.frame
            let titleframe = CGRect(x: 0, y: 0, width: barframe.size.width - 88, height: barframe.size.height)
            
            _titleView.frame = titleframe
        }
    }
    
    func viewControllerCanPerformSegue(viewController: UIViewController, segueIdentifier: String) -> Bool
    {
        let templates : NSArray? = viewController.valueForKey("storyboardSegueTemplates") as? NSArray
        let predicate : NSPredicate = NSPredicate(format: "identifier=%@", segueIdentifier)
        
        let filteredtemplates = templates?.filteredArrayUsingPredicate(predicate)
        return filteredtemplates?.count > 0
    }
}

private class SENavigationBarView: UIView
{
    var collectionView : UICollectionView!
    var pageControl : UIPageControl!
    var fadeMask : CAGradientLayer!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialization()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialization()
    }
    
    private func initialization()
    {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerClass(SENavigationBarTitleCell.self, forCellWithReuseIdentifier: "headerCell")
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.scrollEnabled = false
        self.addSubview(collectionView)
        
        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pageControl)
        
        let views = ["collectionView" : collectionView, "pageControl": pageControl]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[pageControl]-0-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-[pageControl(==8)]-2-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views))
        
        fadeMask = CAGradientLayer()
        fadeMask.colors = [UIColor(white: 1.0, alpha: 0.0).CGColor, UIColor(white: 1.0, alpha: 1.0).CGColor, UIColor(white: 1.0, alpha: 1.0).CGColor, UIColor(white: 1.0, alpha: 0.0).CGColor];
        fadeMask.locations = [0.0, 0.2, 0.8, 1.0]
        fadeMask.startPoint = CGPoint(x: 0, y: 0)
        fadeMask.endPoint = CGPoint(x: 1, y: 0)
        self.layer.mask = fadeMask
    }
    
    override func layoutSubviews()
    {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.invalidateLayout()
        
        super.layoutSubviews()
        
        let offset = CGFloat(pageControl.currentPage) * collectionView.frame.size.width
        collectionView.contentOffset = CGPoint(x: offset, y: 0.0)
        fadeMask.frame = self.bounds
    }
}

private class SENavigationBarTitleCell: UICollectionViewCell
{
    var label : UILabel!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        self.contentView.addSubview(label)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[label]-0-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: ["label" : label]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[label]-0-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: ["label" : label]))
    }
    
    convenience init()
    {
        self.init(frame:CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("This class does not support NSCoding")
    }
}

class SEPageViewSegue : UIStoryboardSegue
{
    override func perform()
    {
        NSNotificationCenter.defaultCenter().postNotificationName(SESegueDoneNotification, object: self);
    }
    
    func performNextSegue()
    {
        destinationViewController.performSegueWithIdentifier(SEStoryboardSegueIdentifier, sender: sourceViewController)
    }
}