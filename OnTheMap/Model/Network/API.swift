

import Foundation

class API {
    
    private static var studentInfo = StudentInfo()
    private static var sessionId: String?
    
    static func postSession(username: String, password: String, completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("Supplied url is invalid")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var errString: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode >= 200 && statusCode < 300 {
                    
                    let newData = data?.subdata(in: 5..<data!.count)
                    if let json = try? JSONSerialization.jsonObject(with: newData!, options: []),
                        let dictionary = json as? [String:Any],
                        let sessionDictionary = dictionary["session"] as? [String: Any],
                        let accountDictionary = dictionary["account"] as? [String: Any]  {
                        
                        self.studentInfo.Studentkey = accountDictionary["key"] as? String
                        
                        self.getUserInfo(completion: { err in
                            
                        })
                        self.sessionId = sessionDictionary["id"] as? String
                        
                       
                    } else {
                        errString = "parsing problem"
                    }
                } else {
                    errString = "User name or passowrd are incorrect"
                }
            } else {
                errString = "Internet Problem"
            }
            DispatchQueue.main.async {
                completion(errString)
            }
             
        }
        
        
        task.resume()
    }
    
    static func deleteSession( completion: @escaping (String?)->Void) {
        var request = URLRequest(url: URL(string: APIConstants.SESSION)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    static func getUserInfo(completion: @escaping (Error?)->Void) {
        var errorS: String?
        let request = URLRequest(url: URL(string: APIConstants.PUBLIC_USER + "\(studentInfo.Studentkey!)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                if statusCode >= 200 && statusCode < 300 { //Response is ok
                    
                    let newData = data?.subdata(in: 5..<data!.count)
                    if let json = try? JSONSerialization.jsonObject(with: newData!, options: [.allowFragments]),

                        let Dictionary = json as? [String: Any]{
                        self.studentInfo.StudentfirstName = Dictionary["first_name"] as? String
                        self.studentInfo.StudentlastName = Dictionary["last_name"] as? String
                        
                    } else {
                        errorS = "parsing problem"
                    }
                } else {
                    errorS = "User name or password are not correct"
                }
            } else {
                errorS = "Internet connection problem"
            }
            DispatchQueue.main.async {
                completion(errorS as? Error)
            }
             print(String(data: data!, encoding: .utf8)!)
        }
        task.resume()
    }
    
    
    static func postLocation(_ location: StudentLocationData, completion: @escaping (String?)->Void) {
        var studentLocations: [StudentLocationData] = []
        
        var request = URLRequest(url: URL(string: APIConstants.STUDENT_LOCATION)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
        request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(studentInfo.Studentkey!)\",  \"firstName\": \"\(studentInfo.StudentfirstName!)\", \"lastName\": \"\(studentInfo.StudentlastName!)\", \"mapString\": \"\(location.mapString!)\", \"mediaURL\": \"\(location.mediaURL!)\", \"latitude\": \(location.latitude!), \"longitude\": \(location.longitude!)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error as? String)
                return
            }
            print(String(data: data!, encoding: .utf8)!)
            
            print(request.httpBody!)
        }
        task.resume()
    }
    
        
        static func getStudentLocations(limit: Int = 100, skip: Int = 0, orderBy: SLParam = .updatedAt, completion: @escaping (StudentLocationsData?)->Void) {
            guard let url = URL(string: "\(APIConstants.STUDENT_LOCATION)?\(APIConstants.ParameterKeys.LIMIT)=\(limit)&\(APIConstants.ParameterKeys.SKIP)=\(skip)&\(APIConstants.ParameterKeys.ORDER)=-\(orderBy.rawValue)") else {
                completion(nil)
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                var studentLocations: [StudentLocationData] = []
                if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                    if statusCode >= 200 && statusCode < 300 { //Response is ok
                        
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                            let dict = json as? [String:Any],
                            let results = dict["results"] as? [Any] {
                            
                            for location in results {
                                let data = try! JSONSerialization.data(withJSONObject: location)
                                let studentLocation = try! JSONDecoder().decode(StudentLocationData.self, from: data)
                                studentLocations.append(studentLocation)
                            }
                           
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    completion(StudentLocationsData(studentLocationsdata: studentLocations))
                }
                
            }
            task.resume()
        }
        
    }
    

