//
//  DVDViewController.swift
//  Rotten Tomatoes
//
//  Created by Jaimin Shah on 5/14/15.
//  Copyright (c) 2015 Janki Chauhan. All rights reserved.
//

import UIKit

class DVDViewController: UIViewController , UITableViewDataSource, UITableViewDelegate,UISearchResultsUpdating {
   
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]!
    var refreshControl: UIRefreshControl!
    var searchController: UISearchController!
    var filteredData: [NSDictionary]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.alpha = 0.6;
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.tintColor = UIColor.orangeColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.orangeColor()]
        
        self.tabBarController?.tabBar.alpha = 0.85;
        self.tabBarController?.tabBar.barTintColor = UIColor.blackColor()
        self.tabBarController?.tabBar.tintColor = UIColor.orangeColor()
        
        self.checkInternet(false, completionHandler:
            {(internet:Bool) -> Void in
                println(internet)
                if (!internet)
                {
                    self.title = "Network Error"
                }
                else
                {
                    
                    SVProgressHUD.show()
                    let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us")!
                    let request = NSURLRequest(URL: url)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (respone:NSURLResponse!, data:NSData!, error: NSError!) ->
                        Void in
                        let json = NSJSONSerialization.JSONObjectWithData(
                            data, options: nil, error: nil) as? NSDictionary
                        if let json = json{
                            self.movies = json["movies"] as? [NSDictionary]
                            self.filteredData = json["movies"] as? [NSDictionary]
                            
                            //    println(self.movies)
                            self.tableView.reloadData()
                            SVProgressHUD.dismiss()
                        }
                    }
                    
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    
                    self.searchController = UISearchController(searchResultsController: nil)
                    self.searchController.searchResultsUpdater = self
                    self.searchController.dimsBackgroundDuringPresentation = false
                    
                    self.searchController.searchBar.sizeToFit()
                    self.tableView.tableHeaderView = self.searchController.searchBar
                    
                    self.definesPresentationContext = true
                    
                    self.refreshControl = UIRefreshControl()
                    self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
                    self.tableView.insertSubview(self.refreshControl, atIndex: 0)
                    
                    
                }
                
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if let movies = filteredData{
            return movies.count
        }
        else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell = tableView.dequeueReusableCellWithIdentifier(
            "MoviesCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredData![indexPath.row]
        let movieRating = movie["mpaa_rating"] as? String
        let movieSynopsis = movie["synopsis"] as? String
        cell.tileLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movieRating! + ": " + movieSynopsis!
        let stringUrl: String =  movie.valueForKeyPath("posters.thumbnail") as! String
        let newString = stringUrl.componentsSeparatedByString("dkpu1ddg7pbsk")
        
        let url = NSURL(string: "http://dkpu1ddg7pbsk"+newString[1])!
        //print(url)
        cell.posterView.setImageWithURL(url)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        if(!searchText.isEmpty){
            filteredData.removeAll(keepCapacity: true)
            if let movies = movies{
                for movie in movies{
                    
                    let stringMatch = (movie["title"] as? String)!.rangeOfString(searchText,options: .CaseInsensitiveSearch)
                    if(stringMatch != nil){
                        filteredData.append(movie)
                    }
                }
            }
        }else{
            filteredData.removeAll(keepCapacity: true)
            if let movies = movies{
                for movie in movies{
                    filteredData.append(movie)
                }
            }
            
        }
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        
        let movie = filteredData![indexPath.row]
        let movieDetailController = segue.destinationViewController as! MovieDetailViewController
        movieDetailController.movie = movie
        
    }
    
    func checkInternet(flag:Bool, completionHandler:(internet:Bool) -> Void)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let url = NSURL(string: "http://www.google.com/")
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        NSURLConnection.sendAsynchronousRequest(request, queue:NSOperationQueue.mainQueue(), completionHandler:
            {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                let rsp = response as? NSHTTPURLResponse
                
                completionHandler(internet:rsp?.statusCode == 200)
        })
    }
    
    
    
}
