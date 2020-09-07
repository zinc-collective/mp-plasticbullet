import Foundation
import AppKit

// Persists data to the filesystem sans any wrappers.
// Probably should look into using UserDefaults or FileManager.
// See: https://programmingwithswift.com/save-images-locally-with-swift-5/
func save(data:Data) {
  guard let url = URL(string: "file:///Users/zee/x.png") else {
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

}

// A Fingerprint is a random-number generator that is used by Lenses
// to adjust the image.
class Fingerprint {

}

// A Lens applied to a CGImage returns a new CGImage the filter transformations applied
class Lens {
  var fingerprint: Fingerprint
  var filter: Filter
  init(fingerprint:Fingerprint, filter:Filter) {
    self.fingerprint = fingerprint
    self.filter = filter
  }

  func apply(image: CGImage) -> CGImage {
    return image
  }
}

let aang = "https://vignette.wikia.nocookie.net/avatar/images/3/37/Aang_inhales.png/revision/latest?cb=20130814113013"

download(urlString: aang) { (data) -> () in
  save(data: data)
  let image = NSImage(data: data)!
  // We _think_ we can get a CGImage off of the NSImage, which means
  // we should be able to run the CGImage through a Lens
  print(image)
  let lens = Lens(fingerprint: Fingerprint(), filter: Filter())
  print(lens)
}

