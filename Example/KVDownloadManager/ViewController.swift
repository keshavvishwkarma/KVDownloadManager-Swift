//
//  ViewController.swift
//  KVDownloadManager
//
//  Created by Keshav on 7/15/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        let fileURL =  URL(string:"http://publications.gbdirect.co.uk/c_book/thecbook.pdf")!
        let fileURL =  URL(string:"https://www.tutorialspoint.com/swift/swift_tutorial.pdf")!

        let downloadTask  = KVDownloadTask(url: fileURL)
        KVDownloadManager.shared.addTask(downloadTask)

        // Adding progress to multiple object
        view.subviews.forEach {
            if $0 is KVCircularProgressView {
                let progressView = ($0 as! KVCircularProgressView)
                progressView.progress = 0.0

                // Here add delegates to get callback on the protocol DownloadableTask.
                downloadTask.addDelegate(progressView)
             // OR
                // downloadTask += progressView
            }
        }

    }

}

extension KVCircularProgressView: DownloadableTask { }

extension DownloadableTask where Self : KVCircularProgressView
{
    public func didUpdateDownloadingProgress(_ progress: Progress, totalSize : String)
    {
        print(#function, "  " + Int(progress.fractionCompleted*100).description + "%" + " Progress : " + progress.fractionCompleted.description)
        self.progress = CGFloat(progress.fractionCompleted)
        
        // self.circularLayer.setProgress(CGFloat(progress.fractionCompleted), animated: true)
        
    }
    
    public func didFinishDownloadingTask(_ task: KVDownloadTask, with error: Error?) {
        print(#function)
    }
}
