//
//  FloatingMenuOptions.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import KUIPopOver

struct FloatingMenuOption {
    var title : String
    var action : (()-> Void)
}

class FloatingMenuOptions: UIViewController, KUIPopOverUsable {
    var contentSize: CGSize {
        return CGSize(width: 92, height: max(44, 44 * options.count))
    }
    var arrowDirection: UIPopoverArrowDirection = .none
    var options : [FloatingMenuOption]
    init( options : [FloatingMenuOption]) {
        self.options = options
        super.init(nibName: "FloatingMenuOptions", bundle: Bundle(for: FloatingMenuOptions.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBOutlet private weak var listTable : UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setupTableView()
    }
    private func setupTableView(){
        listTable?.register(
            UINib(nibName: "FloatingMenuOptionTableViewCell", bundle: Bundle(for: FloatingMenuOptionTableViewCell.self)),
            forCellReuseIdentifier: "FloatingMenuOptionTableViewCell"
        )
    }
}

extension FloatingMenuOptions : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FloatingMenuOptionTableViewCell") as! FloatingMenuOptionTableViewCell
        cell.optionTile?.text = options[indexPath.row].title
        cell.optionTile?.font = UIFont.Button
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        options[indexPath.row].action()
        dismissPopover(animated: true)
    }
}
