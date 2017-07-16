//
//  DownloadManager.swift
//  KVDownloadManager
//
//  Created by Keshav on 7/12/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import Foundation

open class KVDownloadManager: NSObject
{
    static let shared = KVDownloadManager()
    
    // Create URLSession here, to set self as delegate
    lazy var session: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    fileprivate var tasks :[URL:KVDownloadTask] = [:]
    
    // Get local file path: download task stores tune here;
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    public func taskFor(_ url: URL) -> KVDownloadTask? {
        return tasks[url]
    }
    
    @discardableResult public func addTask(_ task: KVDownloadTask ) -> KVDownloadTask {
        tasks[task.url] = task
        task.startDownload()
        return task
    }
    
    @discardableResult public func removeTask(by url: URL) -> KVDownloadTask? {
        guard let downloadTask = tasks[url]  else { return nil }
        downloadTask.cancelDownload()
        tasks[url] = nil
        return downloadTask
    }
    
}

// MARK: - URLSessionDelegate

extension KVDownloadManager: URLSessionDownloadDelegate {
    
    /* Sent periodically to notify the delegate of download progress. */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // 1
        guard let sourceURL = downloadTask.originalRequest?.url, let download = tasks[sourceURL] else { return }
        download.progress.totalUnitCount = totalBytesExpectedToWrite
        download.progress.completedUnitCount = totalBytesWritten
        // 2
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        // 3
        DispatchQueue.main.async {
            download.invoke { $0.didUpdateDownloadingProgress(download.progress, totalSize: totalSize) }
        }
        
    }
    
    // Stores downloaded file
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 1
        guard let sourceURL = downloadTask.originalRequest?.url, let download = tasks[sourceURL] else { return }
        self.removeTask(by: sourceURL)
        
        // 2
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        }
        catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        // 4
        DispatchQueue.main.async {
            download.invoke { $0.didFinishDownloadingTask(download, with: nil) }
        }
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        // 1
        guard let error = error, let sourceURL = task.originalRequest?.url, let download = tasks[sourceURL] else { return }
        print(error.localizedDescription, (error as NSError).code)
        DispatchQueue.main.async {
            download.invoke { $0.didFinishDownloadingTask(download, with: error) }
        }
    }
    
    public func urlSession( _ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64){
        guard let sourceURL = downloadTask.originalRequest?.url, let download = tasks[sourceURL] else { return }
        download.progress.totalUnitCount = expectedTotalBytes
        download.progress.completedUnitCount = fileOffset
    }

    
}


