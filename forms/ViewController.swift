//
//  ViewController.swift
//  forms
//
//  Created by Ricky Joudrey on 1/7/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class MyCell: UITableViewCell {
    
}

class MyOtherCell: UITableViewCell {
    
}

// The simplest field. Represents a cell with static data
class MyField: Field {
    init() {
        super.init(configurator: Configurator())
    }
    
    class Configurator: CellConfigurator {
        func configureCell(_ cell: MyCell) {
            cell.textLabel?.text = "hello"
        }
    }
}

// The simplest field. Represents a cell with a dataSource and delegate
class MyOtherField: Field {
    struct DataSource {
        let title: String
        let timesPressed: Int
    }
    
    weak var delegate: MyOtherFieldDelegate?
    
    // this field exists so that we can pull data out of the dataSource from the our delegate implementation
    let configurator: Configurator
    
    init(dataSource: DataSource) {
        configurator = Configurator(dataSource: dataSource)
        super.init(configurator: configurator)
    }
    
    override func didSelect() {
        delegate?.didSelectMyOtherField(self)
    }
    
    class Configurator: CellConfigurator {
        let dataSource: DataSource
        
        init(dataSource: DataSource) {
            self.dataSource = dataSource
        }
        
        func configureCell(_ cell: MyOtherCell) {
            cell.textLabel?.text = "\(dataSource.title) - \(dataSource.timesPressed)"
        }
    }
}

protocol MyOtherFieldDelegate: class {
    func didSelectMyOtherField(_ field: MyOtherField)
}

class ViewController: UIViewController {
    var tableView: UITableView!
    
    var form: Form! {
        didSet {
            tableView.configure(with: form)
        }
    }
    
    func makeForm(timesPressed: Int = 0) -> Form {
        let form = Form()
        
        let section1 = FormSection()
        section1.title = "Section one"
        section1.fields = [
            MyField(),
            MyField()
        ]
        
        let section2 = FormSection()
        section2.title = "Section two"
        
        let dataSource = MyOtherField.DataSource(title: "Click me!", timesPressed: timesPressed)
        let selectableField = MyOtherField(dataSource: dataSource)
        selectableField.delegate = self
        
        section2.fields = [
            MyField(),
            selectableField
        ]
        
        form.sections = [section1, section2]
        
        return form
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // the form itself is the data source and the delegate
        form = makeForm()
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: MyOtherFieldDelegate {
    func didSelectMyOtherField(_ field: MyOtherField) {
        form = makeForm(timesPressed: field.configurator.dataSource.timesPressed + 1)
    }
}
