import SwiftUI

extension Theme {
  var color: Color {
    get {
      Color(rgbaColor: self.rgbaColor)
    }
    set {
      self.rgbaColor = RGBAColor(color: newValue)
    }
  }
}
