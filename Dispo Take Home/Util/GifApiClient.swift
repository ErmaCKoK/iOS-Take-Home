import Combine
import UIKit

struct GifAPIClient {
  var gifInfo: (_ gifId: String) -> AnyPublisher<GifInfo, Error>
  var searchGIFs: (String) -> AnyPublisher<[SearchResult], Never>
  var featuredGIFs: () -> AnyPublisher<[SearchResult], Never>
}

// MARK: - Live Implementation

extension GifAPIClient {
  static let live = GifAPIClient(
    gifInfo: { gifId in
        var components = URLComponents(
          url: URL(string: "https://api.giphy.com/v1/gifs/\(gifId)")!,
          resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
          .init(name: "api_key", value: Constants.giphyApiKey),
        ]
        let url = components.url!

        return URLSession.shared.dataTaskPublisher(for: url)
          .tryMap { element -> Data in
            guard let httpResponse = element.response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
              throw URLError(.badServerResponse)
            }
            return element.data
          }
          .decode(type: APIGifResponse.self, decoder: JSONDecoder())
            .map { response in
                GifInfo(id: response.data.id,
                        gifUrl: response.data.images.fixed_height.url,
                        text: "\(response.data.title)\n\(response.data.rating)\n\(response.data.source_tld)",
                        shares: 0,
                        backgroundColor: nil,
                        tags: [])
            }
          .share()
          .receive(on: DispatchQueue.main)
          .eraseToAnyPublisher()
    },
    searchGIFs: { query in
      var components = URLComponents(
        url: URL(string: "https://api.giphy.com/v1/gifs/search")!,
        resolvingAgainstBaseURL: false
      )!
      components.queryItems = [
        .init(name: "api_key", value: Constants.giphyApiKey),
        .init(name: "q", value: query),
      ]
      let url = components.url!

      return URLSession.shared.dataTaskPublisher(for: url)
        .tryMap { element -> Data in
          guard let httpResponse = element.response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
          }
          return element.data
        }
        .decode(type: APIListResponse.self, decoder: JSONDecoder())
        .map { response in
          response.data.map {
            SearchResult(
              id: $0.id,
              gifUrl: $0.images.fixed_height.url,
              title: $0.title
            )
          }
        }
        .replaceError(with: [])
        .share()
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    },
    featuredGIFs: {
      var components = URLComponents(
        url: URL(string: "https://api.giphy.com/v1/gifs/trending")!,
        resolvingAgainstBaseURL: false
      )!
      components.queryItems = [
        .init(name: "api_key", value: Constants.giphyApiKey),
        .init(name: "rating", value: "pg"),
      ]
      let url = components.url!

      return URLSession.shared.dataTaskPublisher(for: url)
        .tryMap { element -> Data in
          guard let httpResponse = element.response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
          }
          return element.data
        }
        .decode(type: APIListResponse.self, decoder: JSONDecoder())
        .map { response in
          response.data.map {
            SearchResult(
              id: $0.id,
              gifUrl: $0.images.fixed_height.url,
              title: $0.title
            )
          }
        }
        .replaceError(with: [])
        .share()
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
  )
}

private struct APIListResponse: Codable {
  var data: [GifObject]
}

private struct APIGifResponse: Codable {
  var data: GifObject
}

private struct GifObject: Codable {
  var id: String
  var title: String
  var source_tld: String
  var rating: String
  /// Giphy URL (not gif url to be displayed)
  var url: URL
  var images: Images

  struct Images: Codable {
    var fixed_height: Image

    struct Image: Codable {
      var url: URL
      var width: String
      var height: String
    }
  }
}
