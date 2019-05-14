//
//  DocumentBrowserViewController.swift
//  Timeline
//
//  Created by Samuel Lichlyter on 11/8/18.
//  Copyright © 2018 Samuel Lichlyter. All rights reserved.
//

import UIKit
import SafariServices

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
         browserUserInterfaceStyle = .dark
         view.tintColor = .orange
        
        let openBrowserButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openTimeline))
        additionalTrailingNavigationBarButtonItems.append(openBrowserButton)
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func openTimeline() {
        let url = URL(string: "https://takeout.google.com/settings/takeout/custom/location_history")!
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil
        
        // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .move)
        } else {
            importHandler(nil, .none)
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        let alertController = UIAlertController(title: "Import Failed", message: "Your document failed to import with the following error: " + (error?.localizedDescription)!, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okayAction)
        show(alertController, sender: nil)
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyBoard.instantiateViewController(withIdentifier: "navController")
        let documentViewController = navController.children[0] as! DocumentArcGISMapViewController
        documentViewController.document = Document(fileURL: documentURL)
        present(navController, animated: true, completion: nil)
        
//        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "ArcGISMap") as! DocumentArcGISMapViewController
//        documentViewController.document = Document(fileURL: documentURL)
//
//        present(documentViewController, animated: true, completion: nil)
    }
}

