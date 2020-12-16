//
//  ASMentionSelectorViewController.swift
//  MentionsPOC
//
//  Created by Ankit Sachan on 06/12/20.
//

import UIKit

struct ASTaggedUser {
    var firstName : String
    var lastName : String
    var displayName : String{
        get{
            if firstName.isEmpty && lastName.isEmpty{
                return "\(userId)"
            }else{
                return "\(firstName) \(lastName)"
            }
        }
    }
    var userId : Int
    var profileImage : String?
    var emailId: String
    
    init(_ rawUser: [String : Any]) {
        firstName = rawUser["first_name"] as? String ?? ""
        lastName = rawUser["last_name"] as? String ?? ""
        userId = rawUser["pk"] as? Int ?? -1
        emailId = rawUser["email"] as? String ?? ""
        profileImage = rawUser["profile_img"] as? String
    }
    
    func getTagMarkup() -> String {
        return "<tag><displayName>\(displayName.isEmpty ? emailId : displayName)</displayName><uid>\(userId)</uid><email_id>\(emailId)</email_id></tag>"
    }
}


protocol TagUserPickerDelegate : class {
    func didFinishedPickingUser(_ user: ASTaggedUser, replacementText: String)
}

typealias UserPickerCompletionBlock = (ASTaggedUser?) -> Void

class ASMentionSelectorViewController: UIViewController {
    
    var completion : UserPickerCompletionBlock?
    weak var pickerDelegate : TagUserPickerDelegate?
    var networkRequestCoordinator : CFFNetwrokRequestCoordinatorProtocol!
    var isAddedToParent = false
    private lazy var listFetcher: TagUserListProvider = {
        return TagUserListProvider(networkRequestCoordinator: networkRequestCoordinator)
    }()
    
    private var users : [ASTaggedUser]?
    private var searchKey : String?
    
    @IBOutlet private weak var userListTable : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setupTableView()
    }
    
    private func setupTableView(){
        userListTable?.register(
            UINib(
                nibName: "TagUserTableViewCell",
                bundle: Bundle(for: TagUserTableViewCell.self)),
            forCellReuseIdentifier: "TagUserTableViewCell"
        )
    }
    
    func searchForUser(_ key: String, displayRect: CGRect, parent: UIViewController?) {
        let keyboardHeight = KeyboardService.shared.measuredSize
        var y_cord = displayRect.origin.y + 25
        if displayRect.origin.y + 25 + 100 + 44 > keyboardHeight.origin.y{
            y_cord = displayRect.origin.y - 25 - 100
        }
        if !isAddedToParent{
            isAddedToParent =  true
            parent?.addChild(self)
            view.frame = CGRect(x: 30, y: y_cord, width: 200, height: 100)
            parent?.view.addSubview(view)
            didMove(toParent: parent)
        }else{
            view.frame = CGRect(x: 30, y: y_cord, width: 200, height: 100)
        }
        listFetcher.fetchUserList(key, shouldSearchOnlyDepartment: false) { [weak self](result) in
            DispatchQueue.main.async {
                if let unwrappedSelf = self{
                    switch result {
                    case .Success(result: let result):
                        if let users = result.users,
                           !users.isEmpty{
                            unwrappedSelf.searchKey = key
                            self?.users = users
                            unwrappedSelf.userListTable?.reloadData()
                        }else{
                            fallthrough
                        }
                    case .SuccessWithNoResponseData:
                        fallthrough
                    case .Failure(error: _):
                        if unwrappedSelf.isAddedToParent{
                            unwrappedSelf.dismissTagSelector {
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ASMentionSelectorViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagUserTableViewCell") as! TagUserTableViewCell
        cell.userDisplayName?.text = self.users?[indexPath.row].displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedUser = users?[indexPath.row],
           let searchKey = self.searchKey{
            pickerDelegate?.didFinishedPickingUser(selectedUser, replacementText: searchKey)
        }
        
    }
    
    func dismissTagSelector(_ completion :(() -> Void)) {
        isAddedToParent = false
        self.view.removeFromSuperview()
        self.removeFromParent()
        completion()
    }
}
