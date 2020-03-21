//
//  LikeListViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 21/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class LikeListViewController: UIViewController {
    @IBOutlet private weak var clapsTableView : UITableView?
    var isLikedByUsers : [ClappedByUser]{
        return DummyFeedProvider.getDummyLikeList()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setupTableView()
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
            targetCell.userName?.text = user.getUserName()
            targetCell.userName?.font = .Body2
            targetCell.departmentName?.text = user.getDepartmentName()
            targetCell.departmentName?.font = .Caption1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
}
