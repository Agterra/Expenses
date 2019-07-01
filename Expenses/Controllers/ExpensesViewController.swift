//
//  ViewController.swift
//  Expenses
//
//  Created by Agterra on 01/07/2019.
//  Copyright © 2019 Agterra. All rights reserved.
//

import UIKit
import CoreData

class ExpensesViewController: UIViewController {
    
    var items = [String : [Expense]]()
    var expensesTableView: UITableView!
    private var cellReuseIdentifier: String = "expenseCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.setupNavigation()
        self.setupConstraints()
        self.fetchExpenses()
    }
    
    private func setupViews() {
        let expensesTableView = UITableView(frame: .zero)
        expensesTableView.delegate = self
        expensesTableView.dataSource = self
        self.expensesTableView = expensesTableView
        
        self.view.addSubview(self.expensesTableView)
        
        self.items = [String : [Expense]]()
    }
    
    private func setupNavigation() {
        self.navigationItem.title = "My expenses"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                 target: self,
                                                                 action: #selector(addExpenseAction))
    }
    
    private func setupConstraints() {
        self.expensesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.expensesTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.expensesTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.expensesTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.expensesTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }
    
    @objc private func addExpenseAction() {
        let alertController = UIAlertController(title: "Add expense",
                                                message: "Enter your expense's details",
                                                preferredStyle: .alert)
        alertController.addTextField { (titleTextField) in
            titleTextField.placeholder = "Title"
        }
        
        alertController.addTextField { (amountTextField) in
            amountTextField.placeholder = "Amount"
            amountTextField.keyboardType = .numbersAndPunctuation
        }
        
        let okAction = UIAlertAction(title: "OK",
                                     style: .default) { (action) in
                                        let titleField = alertController.textFields?.first
                                        let amountField = alertController.textFields?.last
                                        
                                        self.addExpense(title: titleField!.text!,
                                                        amount: (amountField!.text! as NSString).floatValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController,
                     animated: true,
                     completion: nil)
    }
}

extension ExpensesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive,
                                          title: "Delete") { (action, index) in
                                            self.deleteItem(index: index)
        }
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView(frame: self.expensesTableView.rect(forSection: section))
        sectionView.backgroundColor = .white
        sectionView.layer.borderColor = UIColor.gray.cgColor
        sectionView.layer.cornerRadius = 2.0
        sectionView.layer.borderWidth = 1.0
        
        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .center
        stackView.spacing = 10.0
        stackView.axis = .horizontal
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = Array(self.items.keys)[section]
        titleLabel.font = UIFont(name: Settings.headerFontFamily,
                                 size: Settings.headerFontSize)
        stackView.addArrangedSubview(titleLabel)
        
        let totalLabel = UILabel(frame: .zero)
        totalLabel.text = "total:"
        totalLabel.font = UIFont(name: Settings.fontFamily,
                                 size: Settings.fontSize)
        stackView.addArrangedSubview(totalLabel)
        
        let itemsKey = Array(self.items.keys)[section]
        let items = self.items[itemsKey]
        var total: Float = 0.0
        items?.forEach({ (item) in
            total += item.amount
        })
        
        let amountLabel = UILabel(frame: .zero)
        if total < 0 {
            amountLabel.textColor = Settings.redColor
            amountLabel.text = "\(total) €"
        } else {
            amountLabel.textColor = Settings.greenColor
            amountLabel.text = "+ \(total) €"
        }
        amountLabel.font = UIFont(name: Settings.headerFontFamily,
                                  size: Settings.headerFontSize)
        stackView.addArrangedSubview(amountLabel)
        
        sectionView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: sectionView.topAnchor),
            stackView.leftAnchor.constraint(equalTo: sectionView.leftAnchor,
                                            constant: 20),
            stackView.rightAnchor.constraint(equalTo: sectionView.rightAnchor,
                                             constant: -20),
            stackView.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor)
            ])
        
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}

extension ExpensesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(self.items.keys)[section]
        if let number = self.items[key]?.count {
            return number
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = Array(self.items.keys)[indexPath.section]
        let currentTitle = self.items[key]![indexPath.row].title
        let currentAmount = self.items[key]![indexPath.row].amount
        let cell = ExpenseTableViewCell(title: currentTitle!,
                                        and: currentAmount,
                                        style: .default,
                                        reuseIdentifier: self.cellReuseIdentifier)
        return cell
    }
    
    
}

// CoreData related tasks
extension ExpensesViewController {
    private func fetchExpenses() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = delegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Expense>(entityName: "Expense")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            self.items = [String : [Expense]]()
            let result = try context.fetch(fetchRequest)
            result.forEach { (item) in
                var newExpenses = [Expense]()
                let key = "\(item.month ?? "NaN")/\(item.year ?? "NaN")"
                if let expenses = self.items[key] {
                    newExpenses = expenses
                }
                newExpenses.append(item)
                self.items.updateValue(newExpenses, forKey: key)
            }
            self.expensesTableView.reloadData()
        } catch {
            print("Error while fetching expenses")
        }
    }
    
    private func addExpense(title: String, amount: Float) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = delegate.persistentContainer.viewContext
        let expenseItem = NSEntityDescription.insertNewObject(forEntityName: "Expense",
                                                              into: context) as! Expense
        expenseItem.amount = amount
        expenseItem.title = title
        let date = Date()
        expenseItem.date = date
        expenseItem.month = "\(Calendar.current.component(.month, from: date))"
        expenseItem.year = "\(Calendar.current.component(.year, from: date))"
        do {
            try context.save()
            self.fetchExpenses()
        } catch {
            fatalError("Failed to save context: \(error)")
        }
    }
    
    private func deleteItem(index: IndexPath) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = delegate.persistentContainer.viewContext
        let key = Array(self.items.keys)[index.section]
        let item = self.items[key]![index.row]
        context.delete(item)
        self.fetchExpenses()
    }
}
