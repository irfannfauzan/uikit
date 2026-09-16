//
//  PostView.swift
//  api-UIKIT
//
//  Created by Vokal-Ican on 16/09/26.
//

import UIKit

class PostView: UIViewController {
    
    var onAddSuccess: ((MockApi) -> Void)?
    
    let nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Nama"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let addressTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Alamat"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let addButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Tambah"
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameTextField, addressTextField, addButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Tambah Orang"
        
        view.addSubview(mainStack)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func createItem(name: String, address: String) async throws -> MockApi {
        let url = URL(string: "https://615075caa706cd00179b7461.mockapi.io/listApi")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "name": name,
            "address": address
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let newItem = try JSONDecoder().decode(MockApi.self, from: data)
        return newItem
    }
    
    @objc func addButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let address = addressTextField.text, !address.isEmpty else {
            print("Nama atau alamat masih kosong")
            return
        }
        
        Task { [weak self] in
            await self?.submitNewItem(name: name, address: address)
        }
    }
    
    func submitNewItem(name: String, address: String) async {
        do {
            let newItem = try await createItem(name: name, address: address)
            onAddSuccess?(newItem)
            navigationController?.popViewController(animated: true)
        } catch {
            print("Gagal nambah data: \(error)")
        }
    }
}
