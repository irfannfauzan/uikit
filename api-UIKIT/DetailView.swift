import UIKit

class DetailView: UIViewController {
    
    var onDeleteSuccess: ((MockApi) -> Void)?
    var mockApi: MockApi?
    
    let labelName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    let labelAddress: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let removeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Remove"
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let button = UIButton(configuration: config)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [labelName, labelAddress, removeButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Detail"
        
        labelName.text = mockApi?.name
        labelAddress.text = mockApi?.address
        
        view.addSubview(mainStack)
        
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func deleteItem(mockApi: MockApi) async throws {
        let url = URL(string: "https://615075caa706cd00179b7461.mockapi.io/listApi/\(mockApi.id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        _ = try await URLSession.shared.data(for: request)
    }
    
    @objc func removeTapped() {
        guard let mockApi = mockApi else { return }
        
        Task { [weak self] in
            await self?.performDelete(mockApi: mockApi)
        }
    }
    
    func performDelete(mockApi: MockApi) async {
        do {
            try await deleteItem(mockApi: mockApi)
            onDeleteSuccess?(mockApi)
            navigationController?.popViewController(animated: true)
        } catch {
            print("Gagal hapus data: \(error)")
        }
    }
}
