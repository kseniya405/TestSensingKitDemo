//
//  ShowFileDataViewController.swift
//  TestSensingKit
//
//  Created by Ксения Шкуренко on 11.10.2020.
//

import UIKit

class ShowFileDataViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton! {
        didSet{
            backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        }
    }
    @IBOutlet weak var dataTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataTextView.text =  "text" //readDataFromFile()
        
        if let text = readDataFromFile() {
            dataTextView.text = text
        } else {
            print("Error reading file")
        }
        // Do any additional setup after loading the view.
    }

    func readDataFromFile() -> String? {
        do {
            let documentDirURL = try FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirURL.appendingPathComponent("Test").appendingPathExtension("txt")
            let data = try String(contentsOf: fileURL)
            return data
        } catch (let error) {
            print(error.localizedDescription)
        }
        return nil
    }
    
    @objc func backButtonDidTap() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }


}
