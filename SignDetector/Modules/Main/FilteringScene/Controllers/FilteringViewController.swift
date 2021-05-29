//
//  FilteringViewController.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 16.05.2021.
//

import Foundation
import UIKit

protocol FilteringViewControllerDelegate: NSObjectProtocol {
    func applyButtonTapped(selectedSigns: [String])
}

class FilteringViewController: UIViewController {
    //MARK: - Variables
    weak var customDelegate: FilteringViewControllerDelegate?
    private var allKeys = SignsJSONHolder.shared.getKeys()
    private var selectedKeys: [String] = []
    
    //MARK: - Controls
    private var applyButton = UIButton.getLittleRoundButton(text: "ПРИМЕНИТЬ",
                                                           isEnabled: true)
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = .white
        return tableView
    }()

    //MARK: - Lifecycle
    init(signsForFilter: [String]) {
        self.selectedKeys = signsForFilter
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
    
    //MARK: - funcs
    private func configure() {
        tableView.delegate = self
        tableView.dataSource = self
        
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.168627451, green: 0.1803921569, blue: 0.231372549, alpha: 1)
        tableView.register(FilterSignsCell.self, forCellReuseIdentifier: FilterSignsCell.reuseId)
        
    }
    
    private func handleTapOnCell(indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if selectedKeys.count == allKeys.count {
                selectedKeys = []
            } else {
                selectedKeys = []
                allKeys.forEach { el in
                    selectedKeys.append(el)
                }
                
            }
            
            print(selectedKeys.count)
            tableView.reloadSections(IndexSet(integersIn: 0...1), with: .automatic)
        case 1:
            let signName = SignsJSONHolder.shared.getSignByIndex(index: indexPath.row)!.imageName!
            if selectedKeys.contains(signName) {
                selectedKeys.removeAll { $0.elementsEqual(signName)}
            } else {
                selectedKeys.append(signName)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
    
    //MARK: - objc funcs
    @objc private func applyButtonTapped() {
//        print("APPLY BUTTON TAPPED")
        print(selectedKeys.count)
        print(selectedKeys)
        customDelegate?.applyButtonTapped(selectedSigns: selectedKeys)
        navigationController?.popViewController(animated: true)
        
    }
}

//MARK: - TableView
extension FilteringViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return allKeys.count
        default:
            fatalError("Unknown section")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterSignsCell.reuseId, for: indexPath) as! FilterSignsCell
        switch indexPath.section {
        case 0:
            cell.configure(text: "Все", isSelected: selectedKeys.count == allKeys.count, signImageName: nil)
        case 1:
            let signModel = SignsJSONHolder.shared.getSignByIndex(index: indexPath.row)!
            cell.configure(text: signModel.name, isSelected: selectedKeys.contains(signModel.imageName!), signImageName: signModel.imageName)
        default:
            fatalError("Unknown section")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        handleTapOnCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(#function)
        handleTapOnCell(indexPath: indexPath)
    }
}

//MARK: - Constraints
extension FilteringViewController {
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
