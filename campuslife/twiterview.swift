//
//  twiterview.swift
//  Swipe
//
//  Created by Computer Science on 3/4/16.
//  Copyright © 2016 Computer Science. All rights reserved.
//

import UIKit
import TwitterKit

class twiterview: TWTRTimelineViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let client = TWTRAPIClient()
        self.dataSource = TWTRUserTimelineDataSource(screenName: "LCSC", APIClient: client)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
