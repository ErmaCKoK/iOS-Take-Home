import Combine
import Kingfisher
import UIKit

class MainViewController: UIViewController {
  private var cancellables = Set<AnyCancellable>()
  private let searchTextChangedSubject = PassthroughSubject<String, Never>()
  private let cellSelectedSubject = PassthroughSubject<SearchResult, Never>()

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.titleView = searchBar
    
    let (
      loadResults,
      pushDetailView
    ) = mainViewModel(
      cellTapped: cellSelectedSubject.eraseToAnyPublisher(), // replace
      searchText: searchTextChangedSubject.eraseToAnyPublisher(),
      viewWillAppear: Empty().eraseToAnyPublisher() // replace
    )

    loadResults
      .sink { [weak self] results in
        // load search results into data source
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchResult>()
        snapshot.appendSections([0])
        snapshot.appendItems(results)
        self?.dataSource.apply(snapshot, animatingDifferences: true)
      }
      .store(in: &cancellables)

    pushDetailView
      .sink { [weak self] result in
        // push detail view
        self?.navigationController?.pushViewController(DetailViewController(searchResult: result), animated: true)
      }
      .store(in: &cancellables)
    
    searchTextChangedSubject.send("") // show featured gifs
  }

  override func loadView() {
    view = UIView()
    view.backgroundColor = .systemBackground
    view.addSubview(collectionView)

    collectionView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

  private lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = "search gifs..."
    searchBar.delegate = self
    return searchBar
  }()

  private var layout: UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout.list(using: UICollectionLayoutListConfiguration(appearance: .plain))
    return layout
  }

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: layout
    )
    collectionView.backgroundColor = .clear
    collectionView.keyboardDismissMode = .onDrag
    collectionView.register(SearchResultCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.delegate = self
    return collectionView
  }()
    
  private lazy var dataSource: UICollectionViewDiffableDataSource<Int, SearchResult> = {
    UICollectionViewDiffableDataSource<Int, SearchResult>(
        collectionView: collectionView,
        cellProvider: { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchResultCollectionViewCell
            cell.titleLabel.text = item.title
            cell.imageView.kf.setImage(with: item.gifUrl, options: [.transition(.fade(1)),.cacheOriginalImage])
            return cell
        }
    )
  }()
}

// MARK: UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchTextChangedSubject.send(searchText)
  }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellSelectedSubject.send(dataSource.snapshot().itemIdentifiers[indexPath.item])
    }
}
