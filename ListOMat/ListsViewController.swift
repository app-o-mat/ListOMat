//
//  ListsViewController.swift
//  ListOMat
//
//  Created by Louis Franco on 2/11/18.
//  Copyright © 2018 App-o-Mat. All rights reserved.
//

import UIKit
import Intents

class ListsViewController: UITableViewController, ListViewControllerDelegate, PopupTextFieldViewDelegate, PopupTextFieldViewViewController {

    var listViewController: ListViewController? = nil
    var lists = loadLists()
    var listIndex: Int = 0

    var popupTextField: PopupTextFieldView? = nil

    private var notification: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        popupTextField = Bundle.main.loadNibNamed("PopupTextFieldView", owner: self, options: [:])?.first as? PopupTextFieldView
        popupTextField?.delegate = self

        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addListTapped(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            listViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ListViewController
        }

        INPreferences.requestSiriAuthorization { (status) in }

        notification = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) {
            [weak self] notification in

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.lists = loadLists()
                self.tableView.reloadData()
            }
        }
    }

    deinit {
        if let notification = notification {
            NotificationCenter.default.removeObserver(notification)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        dismissPopupTextField()
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func addListTapped(_ sender: Any) {
        guard
            let mainView = self.view.superview,
            let popupTextField = self.popupTextField,
            addPopupTextField(mainView: mainView, popupTextField: popupTextField)
        else {
                return
        }

        navigationItem.rightBarButtonItem?.isEnabled = false
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(addListCancelTapped(_:)))
        navigationItem.leftBarButtonItem = cancelButton
    }

    func onTextEntered(text: String) {
        ListOMat.addList(to: &lists, name: text, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        dismissPopupTextField()
    }

    @objc
    func addListCancelTapped(_ sender: Any) {
        dismissPopupTextField()
    }

    func dismissPopupTextField() {
        guard let popupTextField = self.popupTextField else { return }
        dismiss(popupTextField: popupTextField)
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showList" {
            if let indexPath = tableView.indexPathForSelectedRow {
                listIndex = indexPath.row
                let controller = (segue.destination as! UINavigationController).topViewController as! ListViewController
                controller.delegate = self
                controller.list = lists[listIndex]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let list = self.lists[indexPath.row]
        cell.textLabel?.text = list.name
        cell.detailTextLabel?.text = list.completedString
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeList(from: &lists, at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    func deleteAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in

            guard let self = self else {
                completionHandler(false)
                return
            }
            removeList(from: &self.lists, at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
    }

    func copyList(at index: Int) -> List {
        let l = ListOMat.copyList(from: &self.lists, atIndex: index, toIndex: 0)

        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        return l
    }

    func resetList(at index: Int) -> List {
        let l = ListOMat.resetList(from: &self.lists, atIndex: index)

        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        return l
    }

    func show(error: Error?) {
        guard let error = error else { return }
        print(error.localizedDescription)
    }

    @available(iOS 12, *)
    func donateCopyListInteraction(listName: String) {
        let copyListInteraction = CopyListIntent()
        copyListInteraction.list = listName
        copyListInteraction.suggestedInvocationPhrase = "Copy \(listName)"
        let interaction = INInteraction(intent: copyListInteraction, response: nil)
        interaction.donate { [weak self] (error) in
            self?.show(error: error)
        }
    }

    func copyAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: "Copy") { [weak self]
            (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in

            let name = self?.lists[indexPath.row].name
            if let _ = self?.copyList(at: indexPath.row), let name = name {
                if #available(iOS 12, *) {
                    self?.donateCopyListInteraction(listName: name)
                }
            }
            completionHandler(true)
        }
    }

    @available(iOS 12, *)
    func donateResetListInteraction(listName: String) {
        let resetListInteraction = ResetListIntent()
        resetListInteraction.list = listName
        resetListInteraction.suggestedInvocationPhrase = "Reset \(listName)"
        let interaction = INInteraction(intent: resetListInteraction, response: nil)
        interaction.donate { [weak self] (error) in
            self?.show(error: error)
        }
    }

    func resetAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: "Reset") { [weak self]
            (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in

            let name = self?.lists[indexPath.row].name
            if let _ = self?.resetList(at: indexPath.row), let name = name {
                if #available(iOS 12, *) {
                    self?.donateResetListInteraction(listName: name)
                }
            }
            completionHandler(true)
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            deleteAction(forRowAt: indexPath),
            copyAction(forRowAt: indexPath),
            resetAction(forRowAt: indexPath),
            ])
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        dismissPopupTextField()
        return indexPath
    }

    func listDidChange(list: List) {
        self.lists[listIndex] = list
        self.tableView.reloadRows(at: [IndexPath(row: listIndex, section: 0 )], with: .automatic)
        save(lists: lists)
    }

}

