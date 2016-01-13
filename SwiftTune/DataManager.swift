//
//  DataManager.swift
//  SwiftTune
//
//  Created by Buwaneka Galpoththawela on 11/3/15.
//  Copyright © 2015 Buwaneka Galpoththawela. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    static let sharedInstance = DataManager()
    //MARK: Properties
    
    var baseURLString = "itunes.apple.com"
    var tunesArray = [Tunes]()
    
    
    //MARK: - Get Image
    
    
    func cleanStringForFileManager(dirtyString: String) -> String {
        let removedSlashString = dirtyString.stringByReplacingOccurrencesOfString("/", withString: "")
        let removedColonString = removedSlashString.stringByReplacingOccurrencesOfString(":",withString:"")
        return removedColonString
    }
    
    
    func fileIsLocal(filename:String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        return fileManager.fileExistsAtPath(getDocumentPathForFile(filename))
    }
    
    func getDocumentPathForFile(filename: String) -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return documentPath.stringByAppendingPathComponent(filename)
    }
    
    
    func getImageFromServer(localFilename: String, remoteFilename: String, indexPathRow: Int) {
        let remoteURL = NSURL(string: remoteFilename)
        let imageData = NSData(contentsOfURL: remoteURL!)
        let imageTemp :UIImage? = UIImage(data: imageData!)
        if let _ = imageTemp {
            imageData!.writeToFile(getDocumentPathForFile(localFilename),atomically:false)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name:"gotImageFromServer",object:nil,userInfo:nil))
        }
    }
    
    //MARK: - Get Data
    
    
    func parseTuneData(data:NSData){
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
            
            let tempDictArray = jsonResult.objectForKey("results") as! [NSDictionary]
            self.tunesArray.removeAll()
            for tuneDict in tempDictArray {
                let newTune = Tunes()
                newTune.artistName = tuneDict.objectForKey("artistName") as! String
                newTune.trackName = tuneDict.objectForKey("trackName") as! String
                newTune.artworkUrl100 = tuneDict.objectForKey("artworkUrl100") as! String
                if let uCollectionName = tuneDict.objectForKey("collectionName") as? String {
                    newTune.collectionName = uCollectionName
                }
                self.tunesArray.append(newTune)
                print("TrackName:\(newTune.trackName)")
            }
            dispatch_async(dispatch_get_main_queue()){
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "receivedDataFromServer", object: nil))
            }
        } catch {
            print("JSON Parsing Error")
        }
        
    }
    
    
    func getDataFromServer() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        defer{
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        let url = NSURL(string: "http://\(baseURLString)/search?term=madonna")
        let urlRequest = NSMutableURLRequest(URL: url!,cachePolicy: .ReloadIgnoringLocalCacheData,timeoutInterval:30.0)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(urlRequest){ (data, response,error) ->  Void in
            if data != nil {
                print("got data")
               self.parseTuneData(data!)
            }else {
                print("No Data")
            }
            
        }
        task.resume()

    }

}
