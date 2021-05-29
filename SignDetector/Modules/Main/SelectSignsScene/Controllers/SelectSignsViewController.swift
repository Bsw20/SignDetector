//
//  SelectSignsViewController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 14.05.2021.
//

import Foundation
import UIKit

protocol SelectSignsViewControllerDelegate: NSObjectProtocol {
    func applyButtonTapped(signName: String)
}

class SelectSignsViewController: UIViewController {
    enum ViewModel {
        case create
        case edit(signName: String)
    }
    
    //MARK: - Variables
    weak var customDelegate: SelectSignsViewControllerDelegate?
    private var signName: String
    //MARK: - Controls
    private var applyButton = UIButton.getLittleRoundButton(text: "ПРИМЕНИТЬ",
                                                           isEnabled: true)
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsMultipleSelection = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tableView.selectRow(at: IndexPath(row: SignsJSONHolder.shared.getIndexBy(name: signName), section: 0), animated: true, scrollPosition: .top)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    init(viewModel: ViewModel) {
        switch viewModel {
        
        case .create:
            self.signName = SignsJSONHolder.shared.getSignByIndex(index: 0)!.name
        case .edit(signName: let signName):
            self.signName = signName
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupUI()
        setupConstraints()
    }
    
    
    //MARK: - Funcs
    private func configure() {
        tableView.register(SelectSignCell.self, forCellReuseIdentifier: SelectSignCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.sfUISemibold(with: 20)]
        navigationItem.title = "Тип знака"
    }
    
    //MARK: - objc funcs
    @objc private func applyButtonTapped() {
        print("APPLY BUTTON TAPPED")
//        print(tableView.indexPathsForSelectedRows?.count)
        customDelegate?.applyButtonTapped(signName: SignsJSONHolder.shared.getSignByIndex(index: tableView.indexPathForSelectedRow?.row ?? 0)!.imageName!)
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - TableView
extension SelectSignsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SignsJSONHolder.shared.signs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectSignCell.reuseId, for: indexPath) as! SelectSignCell
        let model = SignsJSONHolder.shared.getSignByIndex(index: indexPath.item)
        guard let model = model else {
            fatalError("Неверное количество знаков")
        }
        cell.configure(text: model.name, image: UIImage(named: model.imageName!))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Тип знака"
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        let label = UILabel(text: "Тип знака")
//        label.font = UIFont.sfUISemibold(with: 32)
//        label.textColor = .black
//
//        view.addSubview(label)
//        label.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
    
}

//MARK: - Constraints
extension SelectSignsViewController {
    private func setupConstraints() {
        let screenSize = UIScreen.main.bounds
        view.addSubview(tableView)
        view.addSubview(applyButton)
        
        applyButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(22)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenSize.width * 0.875)
            make.height.equalTo(56)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
