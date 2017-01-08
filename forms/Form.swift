//
//  Form.swift
//  forms
//
//  Created by Ricky Joudrey on 1/7/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class Form: NSObject {
    var sections = [FormSection]()
}

extension UITableView {
    func configure(with form: Form) {
        for section in form.sections {
            for field in section.fields {
                field._configurator.registerCell(in: self)
            }
        }
        delegate = form
        dataSource = form
        reloadData()
    }
}

extension Form: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = sections[indexPath.section].fields[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: field._configurator.cellType.ky_reuseIdentifier)!
        field._configurator.configureCell(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

extension Form: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let field = sections[indexPath.section].fields[indexPath.row]
        field.didSelect()
    }
}

class FormSection {
    var fields = [Field]()
    var title = ""
}

class Field {
    fileprivate let _configurator: AnyCellConfigurator
    
    // The fact that type-erasure is needed for CellConfigurator is an implementation detail
    init<C: CellConfigurator>(configurator: C) {
        self._configurator = AnyCellConfigurator(base: configurator)
    }
    
    func didSelect() {
        
    }
}

extension UITableViewCell {
    static var ky_reuseIdentifier: String {
        return String(describing: self)
    }
}

protocol CellConfigurator {
    associatedtype Cell: UITableViewCell
    func configureCell(_ cell: Cell)
}

// Erases the type of the cell
private class AnyCellConfigurator: CellConfigurator {
    let _configure: (UITableViewCell) -> ()
    let cellType: UITableViewCell.Type
    
    init<B: CellConfigurator>(base: B) {
        cellType = B.Cell.self
        _configure = { (cell: UITableViewCell) in
            let typedCell = cell as! B.Cell
            base.configureCell(typedCell)
        }
    }
    
    func configureCell(_ cell: UITableViewCell) {
        _configure(cell)
    }
    
    func registerCell(in tableView: UITableView) {
        tableView.register(cellType, forCellReuseIdentifier: cellType.ky_reuseIdentifier)
    }
}
