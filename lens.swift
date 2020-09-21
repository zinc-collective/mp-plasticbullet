import Foundation
import AppKit
import CoreImage

// Persists data to the filesystem sans any wrappers.
// Probably should look into using UserDefaults or FileManager.
// See: https://programmingwithswift.com/save-images-locally-with-swift-5/
func save(data:Data, path:String) {
  print("PATH \(path)")
  guard let url = URL(string: path) else {
    print("Bad URL")
    return
  }
  print("Writing \(url)")
  try! data.write(to: url)
  print("Wrote \(url)")
}

// Retrieves data from a string and passes it to the callback
func download(urlString: String, callback: @escaping (Data) -> ()) {
  guard let url = URL(string: urlString) else {
    print("Bad URL")
    return
  }
  print("A")
  let task = URLSession.shared.dataTask(with: url) { data, response, error in
    print("B")
    guard let data = data, error == nil else {
      print("OH NO")
      return
    }
    print("C")

    print(data)
    callback(data)
    print("D")
  }
  // tasks start paused; so we need to start them
  task.resume()
  // And because we are in a swift command line program,
  // we're going to sleep so that the exectuion doesn't stop
  // before the file is downloaded
  while !task.progress.isFinished {
    print(".")
    sleep(1)
  }
}





class Filter {
    let filterName: String
    var filterData: Dictionary<String, Any>?

    init(filterName: String, filterData: Dictionary<String, Any>?) {
        self.filterName = filterName
        self.filterData = filterData
    }
}

// A Fingerprint is a random-number generator that is used by Lenses
// to adjust the image.
class Fingerprint {

}

// A Lens applied to a CGImage returns a new CGImage the filter transformations applied
// currently only works with CIImage
class Lens {
  var fingerprint: Fingerprint
  var filter: Filter
  init(fingerprint:Fingerprint, filter:Filter) {
    self.fingerprint = fingerprint
    self.filter = filter
  }

  func apply(image: CGImage) -> CGImage {
    // let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
    return image
  }

  func apply(image: CIImage) -> CIImage {
    let localFilter = CIFilter(name: filter.filterName, parameters: filter.filterData)
    localFilter?.setValue(image, forKey: kCIInputImageKey)
    guard let output = localFilter?.outputImage else {
        return image
    }
    return output
  }

}

let aang = "https://vignette.wikia.nocookie.net/avatar/images/3/37/Aang_inhales.png/revision/latest?cb=20130814113013"
// let localPath = "file:///Users/\(NSFullUserName())/x.png"
let localPath = "file:///Users/\(NSUserName())/x.png"
let savePath = "file:///Users/\(NSUserName())/x-filtered.png"

var sepia: Filter = Filter(filterName: "CISepiaTone", filterData: [kCIInputIntensityKey: 0.95])
var gaussianBlur: Filter = Filter(filterName: "CIGaussianBlur", filterData: [kCIInputRadiusKey: 20])
var motionBlur: Filter = Filter(filterName: "CIMotionBlur", filterData: [kCIAttributeTypeAngle: 20, kCIAttributeTypeDistance: 20])
var zoomBlur: Filter = Filter(filterName: "CIZoomBlur", filterData: [kCIAttributeTypePosition: [150,150], kCIAttributeTypeDistance: 20])

download(urlString: aang) { (data) -> () in
  save(data: data, path: localPath)
  // let image = NSImage(data: data)!
  let image = CIImage(data: data)!

  // found a way to get to CIImage from web resource -- can use this in a refactor later
  // let webImage = CIImage(contentsOf: URL(string: aang)!)

  print(image)
  let lens = Lens(fingerprint: Fingerprint(), filter: sepia)
  // print(webImage!.properties)
  let newImage = lens.apply(image: image)
  print(newImage)
  save(data: newImage, path: savePath)
}

