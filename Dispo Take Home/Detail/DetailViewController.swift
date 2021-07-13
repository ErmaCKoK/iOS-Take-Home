import Combine
import UIKit

class DetailViewController: UIViewController {
  let searchResult: SearchResult
  private var cancellables = Set<AnyCancellable>()
  
  init(searchResult: SearchResult) {
    self.searchResult = searchResult
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let details = detailViewModel(searchResult: searchResult)
    details
    .sink(receiveCompletion: { completion in
        print("Completion \(completion)")
    }, receiveValue: { [weak self] gif in
        self?.updateLayout(gif: gif)
    })
    .store(in: &cancellables)
  }

  override func loadView() {
    view = UIView()
    view.backgroundColor = .systemBackground
    
    view.addSubview(imageView)
    imageView.snp.makeConstraints { maker in
        maker.centerX.equalToSuperview()
        maker.top.equalTo(view.safeAreaLayoutGuide)
        maker.height.equalTo(imageView.snp.width)
    }
    
    view.addSubview(detailsLabel)
    detailsLabel.snp.makeConstraints { maker in
        maker.top.equalTo(imageView.snp.bottom).offset(16)
        maker.left.right.equalToSuperview().inset(24)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  lazy var detailsLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
    
  lazy var imageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFill
    view.clipsToBounds = true
    return view
  }()
    
    func updateLayout(gif: GifInfo) {
        imageView.kf.setImage(with: gif.gifUrl, options: [.transition(.fade(1)),.cacheOriginalImage])
        detailsLabel.text = gif.text
    }
}
