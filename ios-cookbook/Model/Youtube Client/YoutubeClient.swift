//
//  YoutubeClient.swift
//  ios-cookbook
//
//  Created by Jae Paek on 11/27/20.
//

import Foundation

class YoutubeClient {
    static var maxPage:Int = 10
    
    enum Endpoints {
        static let base = "https://youtube.googleapis.com/youtube/v3/search"
        static let videoBase = "https://www.youtube.com/embed/"
        static let partParam = "?part=snippet"
        static let apiKeyParam = "&key=\(YoutubeClient.getApiKey())"
        static let resultsParam = "&maxResults=25"
        static let typeParam = "&type=video"
        
        case search(String)
        
        var stringValue: String {
            switch self {
            case .search(let recipeName):
                let queryTerm = (recipeName + " recipe").replacingOccurrences(of: " ", with: "+")
                return Endpoints.base + Endpoints.partParam + Endpoints.apiKeyParam +  Endpoints.resultsParam + Endpoints.typeParam + "&q=\(queryTerm)"
            default:
                return ""
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    static func getApiKey() -> String {
        guard let apiKeyPath = Bundle.main.path(forResource: "YoutubeInfo", ofType: "plist") else {
            return ""
        }
        
        let apiKeyUrl = URL(fileURLWithPath: apiKeyPath)
        
        let apiKeyContent = try! Data(contentsOf: apiKeyUrl)
        
        guard let apiKeyMap = try! PropertyListSerialization.propertyList(from: apiKeyContent, options: .mutableContainers, format: nil) as? [String: String] else {
            return ""
        }
        return apiKeyMap["API_KEY"] ?? ""
    }
    
//    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseThpe: ResponseType.Type, completion: @escaping(ResponseType?, Error?) -> Void) -> URLSessionDataTask {
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data else {
//                DispatchQueue.main.async {
//                    completion(nil, error)
//                }
//                return
//            }
//            let decoder = JSONDecoder()
//            do {
//                let responseObject = try decoder.decode(ResponseType.self, from: newData)
//                DispatchQueue.main.async {
//                    completion(responseObject, nil)
//                }
//            } catch {
//                do {
//                    let errorResponse = try decoder.decode(FlickrResponse.self, from: newData) as Error
//                    DispatchQueue.main.async {
//                        completion(nil, errorResponse)
//                    }
//                } catch {
//                    DispatchQueue.main.async {
//                        completion(nil, error)
//                    }
//                }
//            }
//        }
//        task.resume()
//
//        return task
//    }
    
    class func getSearchResult(recipeName: String, completion: @escaping([YoutubeReponse]?, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.search(recipeName).url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            var searchResults: [YoutubeReponse]? = [YoutubeReponse]()
            if let results = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(results)
                if let items = results["items"] as? [[String:Any]] {
                    items.forEach{ item in
                        if let id = (item["id"] as? [String: String])?["videoId"] {
                            if let snippet = item["snippet"] as? [String: Any] {
                                let title = snippet["title"] as? String
                                let description = snippet["description"] as? String
                                var imageUrl: String? = nil
                                if let thumbnails = snippet["thumbnails"] as? [String: Any] {
                                    if let defaultEntry = thumbnails["default"] as? [String: Any] {
                                        imageUrl = defaultEntry["url"] as? String
                                    }
                                    
                                }
                                searchResults?.append(YoutubeReponse(videoId: id, title: title, description: description, imageUrl: imageUrl))
                            } else {
                                searchResults?.append(YoutubeReponse(videoId: id, title: nil, description: nil, imageUrl: nil))
                            }
                        }
                        
                    }
                }
            }
            DispatchQueue.main.async {
                completion(searchResults, nil)
            }
            
        }
        task.resume()
    }
    
    class func downloadThumbnailImage(path: String?, completion: @escaping (Data?, Error?) -> Void) {
        if let path = path {
            let task = URLSession.shared.dataTask(with: URL(string: path)!) { data, response, error in
                DispatchQueue.main.async {
                    completion(data, error)
                }
            }
            task.resume()
        } else {
            completion(nil, nil)
        }
    }
}
