//
//  TableView.swift
//  api-UIKIT
//
//  Created by Vokal-Ican on 16/09/26.
//

import UIKit

class MockApiTableView: UITableViewCell {
    
    static let reuseIdentifier = "MockApiCell"
    private var ImageLoadTask: Task<Void, Never>?

    private let imageUrl: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "person.crop.circle")
        img.contentMode = .scaleAspectFill
        img.widthAnchor.constraint(equalToConstant: 50).isActive = true
        img.heightAnchor.constraint(equalToConstant: 50).isActive = true
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let labelName: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let labelAddress: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var childStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [labelName, labelAddress])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageUrl, childStack])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
        ])
    }
    
    func configure(name: String, adress: String, imageUrl: String) {
        labelName.text = name
        labelAddress.text = adress
                
        ImageLoadTask?.cancel()
        
        Task { [ weak self ] in
            guard let url = URL(string: imageUrl) else { return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if Task.isCancelled { return }
                
                if let image = UIImage(data: data) {
                    self?.imageUrl.image = image
                }
                
            } catch {
                print("Gagal load image: \(error)")
            }
            
        }
    }
}
