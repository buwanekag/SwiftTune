//
//  ViewController.swift
//  SwiftTune
//
//  Created by Buwaneka Galpoththawela on 11/3/15.
//  Copyright © 2015 Buwaneka Galpoththawela. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    var networkManager = NerworkManager.sharedInstance
    var dataManager = DataManager.sharedInstance
    @IBOutlet var tunesCollectiionView :UICollectionView!
    
    //MARK:
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
    return dataManager.tunesArray.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! TuneCollectionViewCell
        let currentTune = dataManager.tunesArray[indexPath.row]
        
        cell.artistNameLabel!.text = currentTune.artistName
        cell.trackNameLabel!.text = currentTune.trackName
        
        let localFilename = dataManager.cleanStringForFileManager(currentTune.artworkUrl100)
        if dataManager.fileIsLocal(localFilename){
            cell.artwORKImageView.image = UIImage (named: dataManager.getDocumentPathForFile(localFilename))
        }else {
            dataManager.getImageFromServer(localFilename, remoteFilename: currentTune.artworkUrl100, indexPathRow: indexPath.row)
            
        }
        
        
        return cell
        
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(100, 140)
    }
    
    
    
    
    //MARK: INTERACT
    
    @IBAction func searchButtonPressed(sender:UIBarButtonItem) {
        if networkManager.serverAvailable {
            dataManager.getDataFromServer()
            
        }else {
            print("server not available")
        }
    }
    func newDataReceived() {
        print("new data")
        tunesCollectiionView.reloadData()
    }
    func newImageReceived(note:NSNotification){
        print("new Image")
        tunesCollectiionView.reloadData()
    }

    
    
    //MARK: LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newDataReceived", name: "receivedDataFromServer", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newImageReceived:", name: "gotImageFromServer", object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

