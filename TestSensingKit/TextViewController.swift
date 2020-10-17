//
//  ViewController.swift
//  CoreLocationTest
//
//  Created by Ксения Шкуренко on 11.10.2020.
//

import UIKit

class TextViewController: UIViewController {

    @IBOutlet weak var dataTextView: UITextView!
    
    @IBAction func updateButtonDidTap(_ sender: Any) {
        dataTextView.text = readDataFromFile()
    }
    
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        do {
            let documentDirURL = try FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirURL.appendingPathComponent("Test").appendingPathExtension("txt")
            try "".write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            dataTextView.text = readDataFromFile()
        } catch (let error) {
            print(error.localizedDescription)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataTextView.text = readDataFromFile()
        
    }

    func readDataFromFile() -> String? {
        do {
            let documentDirURL = try FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirURL.appendingPathComponent("Test").appendingPathExtension("txt")
            return try String(contentsOf: fileURL)
        } catch (let error) {
            print(error.localizedDescription)
        }
        return nil
    }
    
}

