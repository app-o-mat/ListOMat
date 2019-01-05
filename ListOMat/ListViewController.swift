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

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PopupTextFieldViewDelegate, PopupTextFieldViewViewController {

    @IBOutlet weak var tableView: UITableView!

    var popupTextField: PopupTextFieldView? = nil

    weak var delegate: ListViewControllerDelegate?

    func configureView() {
        // Update the user interface for the detail item.
        if let list = list {
            self.title = list.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        popupTextField = Bundle.main.loadNibNamed("PopupTextFieldView", owner: self, options: [:])?.first as? PopupTextFieldView
        popupTextField!.delegate = self

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addListTapped(_:)))
        navigationItem.rightBarButtonItem = addButton

        self.tableView.dataSource = self
        self.tableView.delegate = self

        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        dismissPopupTextField()
        super.viewWillDisappear(animated)
    }

    @objc
    func addListTapped(_ sender: Any) {
        guard let mainView = self.view.superview else { return }
        guard let popupTextField = self.popupTextField, addPopupTextField(mainView: mainView, popupTextField: popupTextField) else { return }

        navigationItem.rightBarButtonItem?.isEnabled = false
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(addListCancelTapped(_:)))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc
    func addListCancelTapped(_ sender: Any) {
        dismissPopupTextField()
    }

    func dismissPopupTextField() {
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem = nil

        guard let popupTextField = self.popupTextField else { return }
        dismiss(popupTextField: popupTextField)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let listItem = list?.items[indexPath.row]
        cell.textLabel!.text = listItem?.name
        cell.accessoryType = (listItem?.done ?? false) ? .checkmark : .none
        return cell
    }

    func onTextEntered(text: String) {
        guard var list = list else { return }

        addListItem(to: &list, name: text, at: list.items.count)
        self.list = list
        self.delegate?.listDidChange(list: list)

        let indexPath = IndexPath(row: list.items.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        dismissPopupTextField()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard var list = list else { return }

        if editingStyle == .delete {
            removeListItem(from: &list, at: indexPath.row)
            self.list = list
            self.delegate?.listDidChange(list: list)

            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var list = list else { return }
        dismissPopupTextField()
        
        toggleDoneListItem(from: &list, at: indexPath.row)
        self.list = list
        self.delegate?.listDidChange(list: list)

        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    var list: List? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

