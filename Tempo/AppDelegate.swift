//
//  AppDelegate.swift
//  Tempo
//
//  Created by Luis Ramos on 16/10/20.
//

import Cocoa
import Combine
import LaunchAtLogin
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let clockView = ClockView()
    lazy var hostingView = NSHostingView(rootView: clockView)
    let dateFormatter = DateFormatter()
    @IBOutlet var launchAtLoginMenuItem: NSMenuItem!
    var cancelable: AnyCancellable?

    func applicationDidFinishLaunching(_: Notification) {
        dateFormatter.dateFormat = "HH mm"

        NSApp.dockTile.contentView = hostingView
        NSApp.dockTile.display()

        updateClock()
        Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateClock),
            userInfo: nil,
            repeats: true
        )

        cancelable = LaunchAtLogin.publisher.sink { [unowned self] in
            launchAtLoginMenuItem.state = $0 ? .on : .off
        }
    }

    @objc func updateClock() {
        let timeString = dateFormatter.string(from: Date())
        if clockView.state.timeString != timeString {
            clockView.state.timeString = timeString
            DispatchQueue.main.async {
                NSApp.dockTile.display()
            }
        }
    }

    @IBAction func launchAtLoginAction(_: Any) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
    }
}
