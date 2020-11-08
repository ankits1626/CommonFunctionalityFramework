//
//  LikeListViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 21/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class LikeListViewController: UIViewController {
    var containerTopBarModel : GenericContainerTopBarModel?{
        didSet{
            setupContainerTopbar()
        }
    }
    
    @IBOutlet private weak var clapsTableView : UITableView?
    var isLikedByUsers : [ClappedByUser] = [ClappedByUser]()
    weak var requestCoordinator: CFFNetwrokRequestCoordinatorProtocol?
    let  feedIdentifier: Int64
    private var fetchedLikeList : FetchedLikesModel?
    private weak var mediaFetcher: CFFMediaCoordinatorProtocol?
    
    init(feedIdentifier: Int64, requestCoordinator: CFFNetwrokRequestCoordinatorProtocol?, mediaFetcher: CFFMediaCoordinatorProtocol?) {
        self.feedIdentifier = feedIdentifier
        self.requestCoordinator = requestCoordinator
        self.mediaFetcher = mediaFetcher
        super.init(nibName: "LikeListViewController", bundle: Bundle(for: LikeListViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setupTableView()
        fetchUsers()
    }
    
    private func setupContainerTopbar(){
        containerTopBarModel?.title?.text = "CLAPS"
    }
    
    private func fetchUsers(){
        if let unwrappedrequestCoordinator = requestCoordinator{
            PostLikeListFetcher(networkRequestCoordinator: unwrappedrequestCoordinator).fetchLikeList(
            feedIdentifier: feedIdentifier, nextPageUrl: fetchedLikeList?.nextPageUrl) { (result) in
                switch result{
                case .Success(result: let result):
                    var likeList = [ClappedByUser]()
                    if let results = result.fetchedLikes?["results"] as? [[String : Any]]{
                        results.forEach { (aRawLike) in
                            if let userInfo = aRawLike["user_info"] as? [String : Any]{
                                likeList.append(ClappedByUser(userInfo))
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {[weak self] in
                        self?.fetchedLikeList = result
                        self?.isLikedByUsers = likeList
                        self?.clapsTableView?.reloadData()
                    }
                case .SuccessWithNoResponseData:
                    fallthrough
                case .Failure(error: _):
                    print("<<<<<<< error while fetching like list")
                }
            }
        }
    }
    
    private func setupTableView(){
        clapsTableView?.tableFooterView = UIView()
        clapsTableView?.register(
            UINib(nibName: "LikedByTableViewCell", bundle: Bundle(for: LikedByTableViewCell.self)),
            forCellReuseIdentifier: "LikedByTableViewCell"
        )
    }
    
    @IBAction private func backButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
}

extension LikeListViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLikedByUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "LikedByTableViewCell")!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let user = isLikedByUsers[indexPath.row]
        if let targetCell = cell as? LikedByTableViewCell{
            targetCell.userName?.text = user.getAuthorName()
            targetCell.userName?.font = .Body2
            targetCell.departmentName?.text = user.getAuthorDepartmentName()
            targetCell.departmentName?.font = .Caption1
            targetCell.departmentName?.textColor = .getSubTitleTextColor()
            if let profileImageEndpoint = user.getAuthorProfileImageUrl(){
                mediaFetcher?.fetchImageAndLoad(targetCell.profileImage, imageEndPoint: profileImageEndpoint)
            }else{
                targetCell.profileImage?.image = nil
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
}
