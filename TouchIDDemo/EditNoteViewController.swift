//
//  EditNoteViewController.swift
//  TouchIDDemo
//
//  Created by dev on 12/29/15.
//  Copyright © 2015 dev. All rights reserved.
//

import UIKit

protocol EditNoteViewControllerDelegate{
    func noteWasSaved()
}
class EditNoteViewController: UIViewController, UITextFieldDelegate {

    var delegate : EditNoteViewControllerDelegate?
    
    var indexOfEditedNote : Int!
    
    @IBOutlet weak var txtNoteTitle: UITextField!
    @IBOutlet weak var tvNoteBody: UITextView!

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.txtNoteTitle.becomeFirstResponder()
        txtNoteTitle.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if (indexOfEditedNote != nil){
            editNote()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func saveNote(sender: AnyObject) {
        if ((self.txtNoteTitle.text?.isEmpty) == nil) {
            print("No title for the note was typed.")
            return
        }
        // Create a dictionary with the note data
        let noteDic = ["title": self.txtNoteTitle.text, "body":self.tvNoteBody.text]
        
        // Declare a NSMutableArray
        var dataArray: NSMutableArray
        // If the notes data file exists then load its contents and add the new note data too, otherwise
        // just initialize the dataArray array and add the new note data.
        if (appDelegate.checkIfDataFileExist()){
            // Load any existing notes.
            dataArray = NSMutableArray(contentsOfFile: appDelegate.getPathOfDataFile())!
            
            //Check if is editing a note or not.
            if indexOfEditedNote == nil{
                // Add the dictionary to the array
                dataArray.addObject(noteDic)
            }else{
                // Replace the existing dictionary to the array.
                dataArray.replaceObjectAtIndex(indexOfEditedNote, withObject: noteDic)
            }
            
        }else{
            // Create a new mutable array and add the noteDict object to it
            dataArray = NSMutableArray(object: noteDic)
        }
        
        // Save the array contents to file
        dataArray.writeToFile(appDelegate.getPathOfDataFile(), atomically: true)
        
        // Notify the delegate class that the note has been saved.
        delegate?.noteWasSaved()
        
        // Pop the view Controller
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    // Text field Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // REsign the textfield from first responder
        textField.resignFirstResponder()
        
        // mark the textview the first responder
        tvNoteBody.becomeFirstResponder()
        return true
    }
    
    // Edit Note
    func editNote(){
        //Load all notes
        let notesArray : NSArray = NSArray(contentsOfFile: appDelegate.getPathOfDataFile())!
        // Get the dictionary at the specified index.
        let noteDict : Dictionary = notesArray.objectAtIndex(indexOfEditedNote) as! Dictionary<String, String>
        // Set the textfield text
        txtNoteTitle.text = noteDict["title"]
        tvNoteBody.text = noteDict["body"]
    }
}
