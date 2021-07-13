import Combine
import UIKit

func detailViewModel(
  searchResult: SearchResult
) -> (AnyPublisher<GifInfo, Error>) {
  let api = GifAPIClient.live
  return api.gifInfo(searchResult.id).eraseToAnyPublisher()
}
