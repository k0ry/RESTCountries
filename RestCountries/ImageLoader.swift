//
//  ImageLoader.swift
//  RestCountries
//
//  Created by Filipp Milovanov on 26.04.2022.
//

import Foundation
import UIKit
import Combine

let imageCache = TemporaryImageCache()
protocol ImageLoaderProtocol{
    func didFinish(withImage:UIImage?)
}
class AsyncImage: UIView, ImageLoaderProtocol {
    private let placeholder = UIActivityIndicatorView()
    private var loader: ImageLoader?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    convenience init (url: URL?){
        self.init(frame: CGRect.zero)
        if let url = url {
            setup(url)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    func setup(_ url: URL) {
        self.addSubview(self.placeholder)
        self.placeholder.startAnimating()
        self.placeholder.center = CGPoint(x:self.frame.width/2,y:self.frame.height/2)
        self.loader = ImageLoader(url: url, cache: imageCache)
        if let loader = self.loader{
            loader.delegate = self
            loader.load()
        }
    }
    
    func didFinish(withImage: UIImage?) {
        DispatchQueue.main.async {
            self.placeholder.removeFromSuperview()
            if let image = withImage{
                let iv = UIImageView(image: image)
                iv.contentMode = .scaleToFill
                iv.frame = CGRect(x:0,y:0,width:self.frame.size.width,height:self.frame.size.height)
                if let superview = self.superview{
                    superview.layer.borderColor = CGColor(gray: 0.5, alpha: 0.9)
                    superview.layer.borderWidth = 1
                }
                self.addSubview(iv)
            }
        }
    }
}

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    var delegate: ImageLoaderProtocol?

    private(set) var isLoading = false
    
    private let url: URL
    private var cache: ImageCache?
    private var cancellable: AnyCancellable?
    
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
    
    deinit {
        cancel()
    }
    
    func load() {
        guard !isLoading else { return }
        if let image = cache?[url] {
            if let delegate = delegate {
                delegate.didFinish(withImage: image)
            }
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.cache($0) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .subscribe(on: Self.imageProcessingQueue)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        image.map { cache?[url] = $0 }
        if let delegate = delegate {
            delegate.didFinish(withImage: image)
        }
    }
}
