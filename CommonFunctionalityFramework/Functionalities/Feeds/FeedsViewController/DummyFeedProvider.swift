//
//  DummyFeedProvider.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

class DummyFeedProvider {
    static func getDummyFeeds() -> [RawFeed]{
        return [
            RawFeed([
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit3", "department" : "Only media"],
                "images" : ["1","2"],
                "videos" : ["1"],
                "post_type" : 1,
                "comments" : 100,
                "claps" : 8,
                "isClappedByMe": 1
            ]),
            RawFeed([
                "title" : "No media",
                "description" : "Description of the first post1",
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit", "department" : "IT"],
                "images" : [],
                "videos" : [],
                "post_type" : 1,
                "comments" : 1,
                "claps" : 0,
                "isClappedByMe": 1
            ]),
            RawFeed([
                "title" : "1 image",
                "description" : "Description of the first post2",
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit2", "department" : "IT2"],
                "images" : ["1"],
                "videos" : [],
                "post_type" : 1,
                "comments" : 10,
                "claps" : 1,
                "isClappedByMe": 1
            ]),
            RawFeed([
                "title" : "1 video",
                "description" : "Description of the first post3",
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit3", "department" : "IT3"],
                "images" : [],
                "videos" : ["1"],
                "post_type" : 1,
                "comments" : 100,
                "claps" : 8,
                "isClappedByMe": 1
            ]),
            RawFeed([
                "title" : "1 image 1 Video",
                "description" : "Description of the first post3",
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit3", "department" : "IT3"],
                "images" : ["1"],
                "videos" : ["1"],
                "post_type" : 1,
                "comments" : 100,
                "claps" : 8,
                "isClappedByMe": 1
            ]),
            RawFeed([
                "title" : "2 image 1 Video",
                "description" : "Description of the first post3",
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit3", "department" : "IT3"],
                "images" : ["1","2"],
                "videos" : ["1"],
                "post_type" : 1,
                "comments" : 100,
                "claps" : 8,
                "isClappedByMe": 1
            ]),
        ]
}
}
