//
//  ListViewController.swift
//  ListOMat
//
//  Created by Louis Franco on 2/11/18.
//  Copyright © 2018 App-o-Mat. All rights reserved.
//

import UIKit

protocol ListViewControllerDelegate: class {
    func listDidChange(list: List)
}

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: ListViewControllerDelegate?

    func configureView() {
        // Update the user interface for the detail item.
        if let list = list {
            self.title = list.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton

        self.tableView.dataSource = self
        self.tableView.delegate = self

        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = list?.items[indexPath.row]
        cell.textLabel!.text = object?.name
        return cell
    }

    @objc
    func insertNewObject(_ sender: Any) {
        guard var list = list else { return }

        addListItem(to: &list, name: "Item \(list.items.count)", at: 0)
        self.list = list
        self.delegate?.listDidChange(list: list)

        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    var list: List? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

