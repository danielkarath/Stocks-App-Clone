//
//  TopStoriesNewsViewController.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 07. 11..
//

import UIKit
import SafariServices

///Controller to show news
final class NewsViewController: UIViewController {

    ///Type of news story
    enum `Type` {
        case topStories
        case company(symbol: String)
        
        ///Title for given news
        var title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    

    //MARK: - Properties
    
    ///Collection of models
    private var stories = [NewsStory]()
    
    ///Instance of a type
    private let type: Type

    ///Primary news view
    public let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor(named: "ThirdBackgroundColor")
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        //Register cells and header
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        
        return table
    }()
    
    
    //MARK: - init
    
    ///Create viewcontroller with a type
    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        fetchNews()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
    
    
    //MARK: - Private
    
    
    /// Sets up tableview
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    /// Fetch news models
    private func fetchNews() {
        APICaller.shared.news(for: type) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Open a news story in Safari
    /// - Parameter url: URL of news story to open
    private func open(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: - Public
    
    
    

}

//MARK: - UITableViewDelegate and UITableViewDataSource

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        header.configure(with: .init(title: self.type.title, souldShowAddButton: false))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.prefferedHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Vibrates when selecting
        HapticsManager.shared.vibrateForSelection()
        
        //open news story
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFailedToOpenAlert()
            return
        }
        open(url: url)
    }
    
    /// Present an error showing that an error occurred while trying to open a story
    private func presentFailedToOpenAlert() {
        
        //Vibrates lightly for error
        HapticsManager.shared.vibrate(for: .error)
        
        let alert = UIAlertController(title: "Bad URL", message: "We're unable to open the selected news", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
