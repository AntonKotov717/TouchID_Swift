//
//  ViewController.swift
//  TouchIDDemo
//
//  Created by dev on 12/29/15.
//  Copyright © 2015 dev. All rights reserved.
//

import UIKit
import LocalAuthentication


class ViewController: UIViewController, UIAlertViewDelegate, UITableViewDataSource,UITableViewDelegate, EditNoteViewControllerDelegate {

    @IBOutlet weak var tblNote: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var dataArray: NSMutableArray!
    var noteIndexToEdit:Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        authenticateUser()
        tblNote.delegate = self
        tblNote.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func authenticateUser(){
        // Get the local authentication context
        let context : LAContext = LAContext()
        
        // Delare a NSError variable
        var error : NSError?
        
        // Set the reason string that will appear on the autentiation alert
        let reasonString = "Authentication is needed to access your notes."
        
        //Check if the device can evaluate the policy
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error){
            
            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if success {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.loadData()
                    })
                }else{
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    print(evalPolicyError?.localizedDescription)
                    
                    switch evalPolicyError!.code{
                    case LAError.SystemCancel.rawValue:
                        print("Authentication was cancelled by the system")
                        break
                    case LAError.UserCancel.rawValue:
                        print("Authentication was cancelled by the user")
                        break
                    case LAError.UserFallback.rawValue:
                        print("User selected to enter custom password")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                        break
                    default:
                        print("Authentication failed")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                        break
                        
                    }

                }
            })]
        }else{
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error!.code{
            case LAError.TouchIDNotEnrolled.rawValue:
                print("TouchID is not enrolled.")
                break
            case LAError.PasscodeNotSet.rawValue:
                print("A passcode has not been set")
                break
            default:
                // THe LAError. TouchIDNotAvailable case.
                print("TouchID not available")
                break
            }
            // Optionally the error description can be displayed on the console.
            print(error?.localizedDescription)
            
            // Show the custom alert view to allow users to enter the password.
            self.showPasswordAlert()
            
        }
    }
    
    func showPasswordAlert(){
        let passwordAlert : UIAlertView = UIAlertView(title: "TouchIDDemo", message: "Please type your password", delegate: self, cancelButtonTitle: "Cansel", otherButtonTitles: "Okey")
        
        passwordAlert.alertViewStyle = UIAlertViewStyle.SecureTextInput
        passwordAlert.show()
        
    }
    
    
    // AlertView Delegate func
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1{
            if ((alertView.textFieldAtIndex(0)!.text?.isEmpty) != nil){
                if(alertView.textFieldAtIndex(0)!.text == "appcoda"){
                    loadData()
                }else{
                    showPasswordAlert()
                }
            }else{
                showPasswordAlert()
            }
        }
    }
    
    // Load Data
    func loadData(){
        if (appDelegate.checkIfDataFileExist()){
            self.dataArray = NSMutableArray(contentsOfFile: appDelegate.getPathOfDataFile())
            self.tblNote.reloadData()
        }else{
            print("File does not exist");
        }
    }
    
    // Table View Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataArray != nil{
            return dataArray.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCell")! as UITableViewCell
        
        let currentNote = self.dataArray.objectAtIndex(indexPath.row) as! Dictionary<String, String>
        cell.textLabel!.text = currentNote["title"]
        
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    // Mark EditNoteViewController Delegate
    func noteWasSaved() {
        // Load the data and reload the tableView
        loadData()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "idSegueEditNote"){
            let editNoteViewController : EditNoteViewController = segue.destinationViewController as! EditNoteViewController
            editNoteViewController.delegate = self
            if (noteIndexToEdit != nil) {
                editNoteViewController.indexOfEditedNote = noteIndexToEdit
                noteIndexToEdit = nil
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        noteIndexToEdit = indexPath.row
        performSegueWithIdentifier("idSegueEditNote", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            dataArray.removeObjectAtIndex(indexPath.row)
            
            //Save the array to disk
            dataArray.writeToFile(appDelegate.getPathOfDataFile(), atomically: true)
            
            // Reload the tableView
            tblNote.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}

