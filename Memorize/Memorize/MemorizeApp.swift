import SwiftUI

@main
struct MemorizeApp: App {
  @StateObject var themeStore = ThemeStore(named: "Default")
  
  var body: some Scene {
    WindowGroup {
      ThemeChooser(store: themeStore)
    }
  }
}
