//
//  KVDownloadTask.swift
//  KVDownloadManager
//
//  Created by Keshav on 7/12/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import Foundation

public protocol DownloadableTask {
    func didUpdateDownloadingProgress(_ progress: Progress, totalSize : String)
    func didFinishDownloadingTask(_ task: KVDownloadTask, with error: Error?)
}

public enum HTTPMethod : String, CustomStringConvertible {
    case get, post, patch, put, delete, options, head
    
    public var description : String {
        return self.rawValue.uppercased()
    }
    
}

open class KVDownloadTask: MulticastDelegator<DownloadableTask>, ProgressReporting {
    public var progress = Progress(totalUnitCount: 0)
    
    private(set) var resumeData: Data?
    private(set) var downloadTask: URLSessionDownloadTask
    
    let url: URL

    // MARK: Lifecycle
    init(url: URL) {
        self.url  = url
        self.downloadTask = KVDownloadManager.shared.session.downloadTask(with: url)
    }

    // MARK: Lifecycle
    init(request: URLRequest) {
        self.url  = request.url!
        self.downloadTask = KVDownloadManager.shared.session.downloadTask(with: request)
    }
    
    public func startDownload() {
        downloadTask.resume()
    }
    
    public func pauseDownload() {
        downloadTask.suspend()
    }

    public func cancelDownload() {
        downloadTask.cancel()
    }
    
//    public func resumeDownload(_ resumeData: Data? = nil) {
//        self.resumeData = resumeData
//        if let resumeData = resumeData {
//            downloadTask =  KVDownloadManager.shared.session.downloadTask(withResumeData: resumeData)
//        }
//        downloadTask.resume()
//    }

    

}

// To make the optional protocol
extension DownloadableTask {
    public func didFinishDownloadingTask(_ task: KVDownloadTask, with error: Error?) { }
}
