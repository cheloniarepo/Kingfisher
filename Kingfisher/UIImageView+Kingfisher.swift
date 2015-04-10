//
//  UIImageView+Kingfisher.swift
//  WebImageDemo
//
//  Created by Wei Wang on 15/4/6.
//
//  Copyright (c) 2015 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

public typealias DownloadProgressBlock = ((receivedSize: Int64, totalSize: Int64) -> ())
public typealias CompletionHandler = ((image: UIImage?, error: NSError?, imageURL: NSURL) -> ())

// MARK: - Set Images
public extension UIImageView {
    public func kf_setImageWithURL(url: NSURL) -> RetrieveImageTask
    {
        return kf_setImageWithURL(url, placeHolderImage: nil, options: KingfisherOptions.None, progressBlock: nil, completionHandler: nil)
    }
    
    public func kf_setImageWithURL(url: NSURL,
                      placeHolderImage: UIImage?) -> RetrieveImageTask
    {
        return kf_setImageWithURL(url, placeHolderImage: placeHolderImage, options: KingfisherOptions.None, progressBlock: nil, completionHandler: nil)
    }
    
    public func kf_setImageWithURL(url: NSURL,
                      placeHolderImage: UIImage?,
                               options: KingfisherOptions) -> RetrieveImageTask
    {
        return kf_setImageWithURL(url, placeHolderImage: placeHolderImage, options: options, progressBlock: nil, completionHandler: nil)
    }
    
    public func kf_setImageWithURL(url: NSURL,
                      placeHolderImage: UIImage?,
                               options: KingfisherOptions,
                     completionHandler: CompletionHandler?) -> RetrieveImageTask
    {
        return kf_setImageWithURL(url, placeHolderImage: placeHolderImage, options: options, progressBlock: nil, completionHandler: completionHandler)
    }
    
    public func kf_setImageWithURL(url: NSURL,
                      placeHolderImage: UIImage?,
                               options: KingfisherOptions,
                         progressBlock: DownloadProgressBlock?,
                     completionHandler: CompletionHandler?) -> RetrieveImageTask
    {
        image = placeHolderImage
        
        self.kf_setWebUrl(url)
        let task = KingfisherManager.sharedManager.retriveImageWithURL(url, options: options, progressBlock: { (recivedSize, totalSize) -> () in
            if let progressBlock = progressBlock {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    progressBlock(receivedSize: recivedSize, totalSize: totalSize)
                })
            }
        }) { (image, error, imageURL) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (imageURL == self.kf_webUrl && image != nil) {
                    self.image = image;
                }
                completionHandler?(image: image, error: error, imageURL: imageURL)
            })
        }
        
        return task
    }
}

// MARK: - Associated Object
private var lastUrlkey: Void?
public extension UIImageView {
    public var kf_webUrl: NSURL? {
        get {
            return objc_getAssociatedObject(self, &lastUrlkey) as? NSURL
        }
    }
    
    private func kf_setWebUrl(url: NSURL) {
        objc_setAssociatedObject(self, &lastUrlkey, url, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
}