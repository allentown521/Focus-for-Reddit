//
//  SearchContributionLoader.swift
//  Slide for Reddit
//
//  Created by Carlos Crane on 1/11/17.
//  Copyright © 2017 Haptic Apps. All rights reserved.
//

import Foundation
import reddift
import XLPagerTabStrip
import RealmSwift

class SearchContributionLoader: ContributionLoader {
    var query: String
    var sub: String
    var color: UIColor
    var canGetMore = true
    
    init(query: String, sub: String){
        self.query = query
        self.sub = sub
        color = ColorUtil.getColorForUser(name: sub)
        paginator = Paginator()
        content = []
        indicatorInfo = IndicatorInfo(title: "Searching")
    }
    
    
    var paginator: Paginator
    var content: [Object]
    var delegate: ContentListingViewController?
    var indicatorInfo: IndicatorInfo
    var paging = false
    
    func getData(reload: Bool) {
        if(delegate != nil){
            do {
                if(reload){
                    paginator = Paginator()
                }
                print("Subredd it is \(sub)")
                try delegate?.session?.getSearch(Subreddit.init(subreddit: sub), query: query, paginator: paginator, sort: .relevance, completion: { (result) in
                    switch result {
                    case .failure:
                        self.delegate?.failed(error: result.error!)
                    case .success(let listing):
                        
                        if(reload){
                            self.content = []
                        }
                        var baseContent = listing.children.flatMap({$0})
                        for item in baseContent {
                            if(item is Comment){
                                self.content.append(RealmDataWrapper.commentToRComment(comment: item as! Comment))
                            } else {
                                self.content.append(RealmDataWrapper.linkToRSubmission(submission: item as! Link))
                            }
                        }
                        self.paginator = listing.paginator
                        DispatchQueue.main.async{
                            self.delegate?.doneLoading()
                        }
                    }
                })
            } catch {
                print(error)
            }
            
        }
    }
}
