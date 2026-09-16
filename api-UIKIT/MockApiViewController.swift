//
//  MockApiViewController.swift
//  api-UIKIT
//
//  Created by Vokal-Ican on 16/09/26.
//

import UIKit

class MockApiViewController: UIViewController {
    
    let url = "https://615075caa706cd00179b7461.mockapi.io/listApi"

    var items: [MockApi] = []
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        title = "Mock Api"
                
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = addButton
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MockApiTableView.self, forCellReuseIdentifier: MockApiTableView.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension 
        tableView.estimatedRowHeight = 80
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        Task { [ weak self ] in
            await self?.loadData()
        }
    }
    
    func fetchData() async throws -> [MockApi] {
        let url = URL(string: url)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let item = try JSONDecoder().decode([MockApi].self, from: data)
        return item
    }
    
    func loadData() async {
        do {
            items = try await fetchData()
            tableView.reloadData()
        } catch {
            print("Something error! \(error)")
        }
    }
    
    func createItem(name: String, address: String)async throws -> MockApi {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "name": name,
            "address": address
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        let item = try JSONDecoder().decode(MockApi.self, from: data)
        return item
    }
    
    @objc func addTapped() {
        let postVC = PostView()
            postVC.onAddSuccess = { [ weak self ] newItem in
                self?.items.append(newItem)
                self?.tableView.reloadData()
            }
        navigationController?.pushViewController(postVC, animated: true)
    }
    
    func addNewItem() async {
        do {
            let newItem = try await createItem(name: "Nama Baru", address: "Alamat Baru")
            items.append(newItem)
            tableView.reloadData()
        } catch {
            printContent("Something error: \(error)")
        }
    }
    
}

extension MockApiViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MockApiTableView.reuseIdentifier, for: indexPath) as! MockApiTableView
        let item = items[indexPath.row]
        cell.configure(name: item.name, adress: item.address, imageUrl: item.imageUrl)
        return cell
    }
}

extension MockApiViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _datas = items[indexPath.row]
        let detailView = DetailView()
        detailView.mockApi = _datas
        detailView.onDeleteSuccess = { [weak self] deletedItem in
                self?.items.removeAll { $0.id == deletedItem.id }
                self?.tableView.reloadData()
            }
        navigationController?.pushViewController(detailView, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
