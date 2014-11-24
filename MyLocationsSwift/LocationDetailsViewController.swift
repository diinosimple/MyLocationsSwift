//
//  LocationDetailsViewController.swift
//  MyLocationsSwift
//
//  Created by Iino Daisuke on 2014/11/08.
//  Copyright (c) 2014年 Iino Daisuke. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    @IBOutlet weak var descriptionTextView:UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    //if no photo is picked yet, image is nil, so this must be an optional.
    var image: UIImage?
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var descriptionText = ""
    var categoryName = "No Category"
    
    var managedObjectContext: NSManagedObjectContext!
    
    var date = NSDate()
    
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDesctiption
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    
    var observer: AnyObject! /*This will hold a reference to the observer, which is necessary to unregister it later.*/
    
    @IBAction func done() {
        let hudView = HudView.hudInView(navigationController!.view,
            animated: true)
                    
        var location: Location
        
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = NSEntityDescription.insertNewObjectForEntityForName(
            "Location", inManagedObjectContext: managedObjectContext) as Location
            location.photoID = nil
        }
        
        println("NEEntityDescription")
        
        location.locationDesctiption = descriptionText
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        //This code is only performed if image is not nil, in other words, when the user has picked a photo.
        if let image = image {
            /*
            You need to get a new ID and assign it to the Location’s photoID property, but only if you’re adding a photo to a Location that didn’t already have one. If a photo existed, you simply keep the same ID and overwrite the existing JPEG file.
            */
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID()
            }
            /*
            The UIImageJPEGRepresentation() function converts the UIImage into the JPEG format and returns an NSData object. NSData is an object that represents a blob of binary data, usually the contents of a file.
            */
            let data = UIImageJPEGRepresentation(image, 0.5)
            
            //Here you save the NSData object to the path given by the photoPath property.
            var error: NSError?
            if !data.writeToFile(location.photoPath, options: .DataWritingAtomic,
                error:&error) {
                    println("Error writing file: \(error)")
            }
        }
        
        
        var error: NSError?
        if !managedObjectContext.save(&error) {
            fatalCoreDataError(error)
            return
        }
        
        afterDelay(0.6, {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        println("CategoryName in LocationDetailsViewController = \(categoryName)")
        categoryLabel.text = categoryName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        descriptionTextView.textColor = UIColor.whiteColor()
        descriptionTextView.backgroundColor = UIColor.blackColor()
        addPhotoLabel.textColor = UIColor.whiteColor()
        addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        if let location = locationToEdit {
            title = "Edit Location"
            /*
            If the Location that you’re editing has a photo, this calls showImage() to display it in the photo cell.
            */
            
            if location.hasPhoto {
                if let image = location.photoImage {
                    showImage(image)
                }
            }
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        categoryLabel.text = ""
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = formatDate(date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                    action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        /* you want to dismiss alert action sheet, image picker or keyboard when home button is pressed
        to do so, you need to listen for background notification */
        listenForBackgroundNotification()
        
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        descriptionTextView.frame.size.width = view.frame.size.width - 30
    }
    
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var line = ""
        line.addText(placemark.subThoroughfare)
        line.addText(placemark.thoroughfare, withSeparator: " ")
        line.addText(placemark.locality, withSeparator: ", ")
        line.addText(placemark.administrativeArea, withSeparator: ", ")
        line.addText(placemark.postalCode, withSeparator: " ")
        line.addText(placemark.country, withSeparator: ", ")
        return line
    }
    
    func formatDate(date: NSDate) -> String {
            return dateFormatter.stringFromDate(date)
    }
    
    /*
    showImage() puts the image into the image view, makes the image view visible and gives it the proper 
    dimensions.It also hides the Add Photo label because you don’t want it to overlap the image view.
    */
    
    func showImage(image: UIImage){
        imageView.image = image
        imageView.hidden = false
        imageView.frame = CGRect(x:10, y:10, width:260, height:260)
        addPhotoLabel.hidden = true
    }
    
    /*
    Apple recommends that apps remove any alert or action sheet from the screen when the user presses the Home button to put the app in the background. We want to dismiss the action sheet if that is currently showing. We want to do the same for the image picker.
    iOS sends out "going to the background" notifications through NSNotificationCenter that you can make the view controller listen to.  We will listen for the UIApplicationDidEnterBackgroundNotification.
    */
    func listenForBackgroundNotification() {
        println("********** ListenForBackgroundNotification()")
        /*
        Add an observer for UIApplicationDidEnterBackgroundNotification. 
        When this notification is received, NSNotificationCenter will call the closure.
        */
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()){ [weak self] notificaton in
            
            /*
            The image picker and action sheet are both presented as modal view controllers that lie on top of everything else. If such a modal view controller is active, UIViewController’s presentedViewController property has a reference to that modal view controller.
            So if presentedViewController is not nil you call dismissViewControllerAnimated() to close the modal screen. This has no effect on the category picker; that does not use a modal but a push segue.
            */
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }
                
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
    deinit {
        println("************ deinit \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
            case (0,0):
                return 88
            case (1,_):
            /*
            If there is no image, then the height for the Add Photo cell is 44 points just like a regular cell. But if there is an image, it’s a lot higher: 280 points. That is 260 points for the image view plus 10 points margin on the top and bottom.
            */
            /*
                if imageView.hidden {
                    return 44
                } else {
                    return 280
                }
            */
                return imageView.hidden ? 44 : 280
            case (2,2):
                addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
                addressLabel.sizeToFit()
                addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
                return addressLabel.frame.size.height + 20
            default:
                return 44
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    override func tableView(tableView: UITableView,
                willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
                return indexPath
        } else {
                return nil
        }
    }
    
    override func tableView(tableView: UITableView,
                didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            
            /*
            This first deselects the Add Photo row.
            Without this, Add Photo cell remains selected (dark gray background) when you
            cancel the action sheet. That doesn’t look so good.
            */
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            /*
            Add Photo is the first row in the second section. When it’s tapped, you call the
            pickPhoto() method
            */
            pickPhoto()
        }
    }
    
    /*
    The “willDisplayCell” delegate method is called just before a cell becomes visible. Here you can do some last-minute customizations on the cell and its contents.
    */
    override func tableView(tableView: UITableView,
        willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.blackColor()
        cell.textLabel.textColor = UIColor.whiteColor()
        cell.textLabel.highlightedTextColor = cell.textLabel.textColor
        
        if let detailLabel = cell.detailTextLabel {
            detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
            detailLabel.highlightedTextColor = detailLabel.textColor
        }
        let selectionView = UIView(frame: CGRect.zeroRect)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
        
        if indexPath.row == 2 {
            let addressLabel = cell.viewWithTag(100) as UILabel
            addressLabel.textColor = UIColor.whiteColor()
            addressLabel.highlightedTextColor = addressLabel.textColor
        }
    }
    
}

extension LocationDetailsViewController: UITextViewDelegate {
        func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
            descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
            //println("Text Changing")
            return true
        }
        
        func textViewDidEndEditing(textView: UITextView) {
            //println("Text Edit Ended")
            descriptionText = textView.text
        }
}



extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /*
    First you check whether the camera is available. 
    When it is, you show an action sheet to let the user choose between the camera and the Photo Library
    */
    
    func pickPhoto() {
        /*
        You’re using UIImagePickerController’s isSourceTypeAvailable() method to check whether there’s a camera present. 
        If not, you call choosePhotoFromLibrary() as that is the only option then. 
        But when the device does have a camera you show a UIAlertController on the screen.
        */
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        /*
        An action sheet works very much like an alert view, except that it slides in from the bottom of the screen.
        */
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        /*
        The choices in the action sheet are provided by UIAlertAction objects. 
        The handler: parameter determines what happens when you press the alert action’s button in the action sheet.
        
        This gives handler: a closure that calls the corresponding method from the extension. 
        You use the _ wildcard to ignore the parameter that is passed to this closure (which is a reference to the UIAlertAction itself).
        */
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { _ in self.takePhotoWithCamera()})
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: { _ in self.choosePhotoFromLibrary()})
        alertController.addAction(chooseFromLibraryAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /*
    The UIImagePickerController is a view controller like any other.
    But it comes with UIKit and it takes care of the entire process of taking new photos and picking them
    from the user’s photo library.
    All you need to do is create a UIImagePickerController instance, set its properties to configure the
    picker, set its delegate, and then present it.
    When the user closes the image picker screen, the delegate methods will let you know what happened.
    */

    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        /*
        With ".allowsEditing" setting enabled, the user can do some quick editing on the photo 
        before making his final choice.
        */
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /*
    The imagePickerController() is the method that gets called when the user has selected a photo in the image picker.
    You can tell by the notation [NSObject : AnyObject] that the info parameter is a dictionary. 
    Whenever you see [ A : B ] you’re dealing with a dictionary that has keys of type “A” and values of type “B”.
    The info dictionary contains a variety of data describing the image that the user picked. You use the
    UIImagePickerControllerEdittedImage key to retrieve a UIImage object that contains the image 
    from after the Move and Scale operatoin.
    */
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        image = info[UIImagePickerControllerEditedImage] as UIImage?
        
        if let image = image {
            showImage(image)
        }
        /*
        The table view cell doesn’t automatically resize to fit that image view. 
        As a result, the photo overlaps the cells below it.you need to refresh 
        the table view and sets the photo row to the proper hight.
        */
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}