//
//  Constants.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 27/08/24.
//

import Foundation

struct Constants {
    
    static let baseUrl = "https://jsonplaceholder.typicode.com"
    
    struct Parameters {
        static let userId = "userId"
    }
    
    struct Titles {
        static let posts = "POSTS"
        static let login = "LOGIN"
        static let favouritePosts = "FAVOURITE POSTS"
    }
    
    struct CellIdentifier {
        static let postTableViewCell = "PostTableViewCell"
    }
    
    struct VCIdentifier {
        static let postViewController = "PostViewController"
        static let favouritePostViewController = "FavouritePostViewController"
        static let tabbarViewController = "TabbarViewController"
    }
    
    struct StoryBoardName {
        static let main = "Main"
    }
    
    struct NibName {
        static let postTableViewCell = "PostTableViewCell"
    }
    
    enum HttpHeaderField: String {
        case authentication = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
    }
    
    enum ContentType: String {
        case json = "application/json"
    }
}
