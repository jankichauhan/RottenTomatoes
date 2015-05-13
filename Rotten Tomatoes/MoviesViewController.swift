//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Jaimin Shah on 5/7/15.
//  Copyright (c) 2015 Janki Chauhan. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.alpha = 0.6;
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.tintColor = UIColor.orangeColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.orangeColor()]

        SVProgressHUD.show()
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us")!
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (respone:NSURLResponse!, data:NSData!, error: NSError!) ->
            Void in
            let json = NSJSONSerialization.JSONObjectWithData(
                data, options: nil, error: nil) as? NSDictionary
            if let json = json{
                self.movies = json["movies"] as? [NSDictionary]
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
           // println(json)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        
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
        
        if let movies = movies{
            return movies.count
        }
        else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell = tableView.dequeueReusableCellWithIdentifier(
            "MoviesCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        
        let movie = movies![indexPath.row]
        let movieDetailController = segue.destinationViewController as! MovieDetailViewController
        movieDetailController.movie = movie
        
    }


}
