SEPageViewWithNavigationBar
===========================

SEPageViewWithNavigationBar is a subclass of UIViewController which contains UIPageViewController and changes navigation bar title during the swipe pages, like in Twitter app. Written in **Swift**, requires **iOS 7** or later.

![gif](https://github.com/ifau/SEPageViewWithNavigationBar/blob/master/Readme/1.gif?raw=true)

#Usage

##From code

Just create instance of SEPageViewWithNavigationBar and set view controllers to `viewControllers` property. Note that ***SEPageViewWithNavigationBar should be embedded in UINavigationController***.

```swift
let storyboard = UIStoryboard(name: "Main", bundle: nil)
let vc1 = storyboard.instantiateViewControllerWithIdentifier("vc1")
let vc2 = storyboard.instantiateViewControllerWithIdentifier("vc2")
let vc3 = storyboard.instantiateViewControllerWithIdentifier("vc3")

let pagedViewController = SEPageViewWithNavigationBar()
pagedViewController.viewControllers = [vc1, vc2, vc3]
    
self.window?.rootViewController = UINavigationController(rootViewController: pagedViewController)
```

##Using storyboard

1) Drag a UIViewController into storyboard.

2) Place it in the hierarchy that contains UINavigationController.

3) Set custom class to `SEPageViewWithNavigationBar` in Identity Inspector.

4) Add custom segues in chain between this UIViewController and those that should be pages.

5) Set custom class to `SEPageViewSegue` and identity to `SEPage` in Attributes Inspector for each segue.

![storyboard setup](https://github.com/ifau/SEPageViewWithNavigationBar/blob/master/Readme/3.png?raw=true)

#Configuration

SEPageViewWithNavigationBar allows you to change the following properties:

* `titleLabelFont : UIFont`
	
	Font of title label, __default__ is __UIFont.systemFontOfSize(16)__.
	
* `titleLabelTextColor : UIColor`
	
	Color of title label, __default__ is __UIColor.whiteColor()__.

* `pageIndicatorTintColor : UIColor`
	
	Tint color of page indicator, __default__ is __UIColor(white: 1.0, alpha: 0.4)__.
	
* `currentPageIndicatorTintColor : UIColor`
	
	Tint color of current page indicator, __default__ is __UIColor.whiteColor()__.

#Customization

By default navigation bar title displays current view controller title. Actually, navigation bar title view in SEPageViewWithNavigationBar is UICollectionView, so you can define your own UICollectionViewCell and customize it as you need, using following function:

`setCustomTitle(cellClass cellClass: AnyClass, delegateCallback: ((titleCell: UICollectionViewCell, currentPage: Int) -> (UICollectionViewCell)))`

For example, if you need image near title label:

```swift
class MyCustomCell: UICollectionViewCell
{
    var textLabel : UILabel!
    var imageView : UIImageView!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        textLabel.textColor = UIColor.whiteColor()
        self.contentView.addSubview(textLabel)
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(imageView)
        
        let space1 = UIView()
        space1.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(space1)
        
        let space2 = UIView()
        space2.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(space2)
        
        let views = ["textLabel" : textLabel, "imageView" : imageView, "space1" : space1, "space2" : space2]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[space1(>=0)][imageView]-4-[textLabel][space2(==space1)]|", options: .DirectionLeftToRight, metrics: nil, views: views))
        self.contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: textLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    convenience init()
    {
        self.init(frame:CGRectZero)
    }
}
```


```swift
self.window?.rootViewController = UINavigationController(rootViewController: pagedViewController)
        
pagedViewController.setCustomTitle(cellClass: MyCustomCell.self) { (titleCell: UICollectionViewCell, pageIndex: Int) -> (UICollectionViewCell) in
                
    let cell = titleCell as! MyCustomCell
            
    let titles = ["Explore", "Favorites", "Random"]
    let images = [UIImage(named: "Explore"), UIImage(named: "Favorites"), UIImage(named: "Random")]
            
    cell.textLabel.text = titles[pageIndex]
    cell.imageView.image = images[pageIndex]
            
    return cell
}
```

Result:

![custom title](https://github.com/ifau/SEPageViewWithNavigationBar/blob/master/Readme/2.png?raw=true)

#Installation

##Manual

Simply drag `SEPageViewWithNavigationBar.swift` to your project.

##Cocoapods

Add following line to your `Podfile`:

	pod "SEPageViewWithNavigationBar"

#License

	The MIT License (MIT)

	Copyright (c) 2015 Seliverstov Evgeney

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.