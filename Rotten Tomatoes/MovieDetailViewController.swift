//
//  MovieDetailViewController.swift
//  Rotten Tomatoes
//
//  Created by Jaimin Shah on 5/7/15.
//  Copyright (c) 2015 Janki Chauhan. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var mpaaRatingLabel: UILabel!


    var newString:[String]!
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.alpha = 0.6;
        self.navigationController?.navigationBar.tintColor = UIColor.orangeColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]

        let movieTitle = movie["title"] as? String
        let movieYear = movie["year"] as! NSNumber
        let movieCRating = movie.valueForKeyPath("ratings.critics_score") as! NSNumber
        let movieARating =  movie.valueForKeyPath("ratings.audience_score") as! NSNumber
        
        self.title = movieTitle
        
        titleLabel.text = movieTitle! + " (" + movieYear.stringValue + ") "
        synopsisLabel.text = movie["synopsis"] as? String
        ratingsLabel.text = "Critics Score: " + movieCRating.stringValue + " Audience Score: " + movieARating.stringValue
        mpaaRatingLabel.text = movie["mpaa_rating"] as? String
        
        let stringUrl: String =  movie.valueForKeyPath("posters.thumbnail") as! String
        
         newString = stringUrl.componentsSeparatedByString("dkpu1ddg7pbsk")

        println(newString[0])
        
        let url = NSURL(string: "http://dkpu1ddg7pbsk"+newString[1])!
        
        posterView.setImageWithURL(url)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
