import Cocoa
import Foundation

private struct ServiceState {
    let running: Bool
    let online: Bool
    let uin: String
    let nick: String
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private lazy var workspaceRoot = Bundle.main.bundleURL.deletingLastPathComponent()
    private lazy var securityFile = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".qq-chat-exporter/security.json")
    private lazy var qceDir = workspaceRoot.appendingPathComponent("NapCat-QCE-macOS-arm64")
    private lazy var foregroundScript = qceDir.appendingPathComponent("run-qce-real-foreground.sh")
    private lazy var stopScript = qceDir.appendingPathComponent("stop-qce-real.sh")
    private lazy var launcherLog = qceDir.appendingPathComponent("qce-statusbar.log")

    private var statusItem: NSStatusItem!
    private let menu = NSMenu()
    private let stateItem = NSMenuItem(title: "状态：检测中…", action: nil, keyEquivalent: "")
    private let openWebItem = NSMenuItem(title: "打开 QCE 网页", action: nil, keyEquivalent: "")
    private let toggleItem = NSMenuItem(title: "启动 QCE", action: nil, keyEquivalent: "")
    private let stopItem = NSMenuItem(title: "停止 QCE", action: nil, keyEquivalent: "")
    private let quitItem = NSMenuItem(title: "停止并退出", action: nil, keyEquivalent: "q")

    private var token: String = ""
    private var pollTimer: Timer?
    private var pendingBrowserOpen = false
    private var lastState: ServiceState?
    private var startupAttempted = false
    private var launcherProcess: Process?
    private var launcherLogHandle: FileHandle?

    private var apiInfoURL: URL {
        URL(string: "http://127.0.0.1:40653/api/system/info")!
    }

    private var webURL: URL {
        URL(string: "http://127.0.0.1:40653/qce-v4-tool")!
    }

    private var authURL: URL {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
        let escaped = token.addingPercentEncoding(withAllowedCharacters: allowed) ?? token
        return URL(string: "http://127.0.0.1:40653/qce-v4-tool/auth?token=\(escaped)") ?? webURL
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        _ = loadToken()

        setupStatusItem()
        refreshState(startIfNeeded: true)

        pollTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshState(startIfNeeded: false)
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        handleExternalLaunchRequest()
        return false
    }

    func menuWillOpen(_ menu: NSMenu) {
        refreshState(startIfNeeded: false)
    }

    private func handleExternalLaunchRequest() {
        _ = loadToken()
        pendingBrowserOpen = true
        refreshState(startIfNeeded: true)
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem.button else { return }

        if let image = NSImage(systemSymbolName: "message.fill", accessibilityDescription: "QCE") {
            image.isTemplate = true
            image.size = NSSize(width: 18, height: 18)
            button.image = image
        } else {
            button.title = "QCE"
        }
        button.toolTip = "QCE 菜单栏控制器"

        menu.delegate = self
        menu.autoenablesItems = false

        stateItem.isEnabled = false
        openWebItem.target = self
        openWebItem.action = #selector(openWebPage)
        toggleItem.target = self
        toggleItem.action = #selector(toggleQCE)
        stopItem.target = self
        stopItem.action = #selector(stopQCEAction)
        quitItem.target = self
        quitItem.action = #selector(stopAndQuit)
        quitItem.keyEquivalentModifierMask = [.command]

        menu.addItem(stateItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(openWebItem)
        menu.addItem(toggleItem)
        menu.addItem(stopItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func refreshState(startIfNeeded: Bool) {
        _ = loadToken()

        fetchState { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                self.apply(state: state)
                if startIfNeeded, self.lastState?.running != true, self.launcherProcess?.isRunning != true {
                    self.startupAttempted = true
                    self.launchQCE(openBrowserWhenReady: true)
                } else if state?.running == true {
                    self.pendingBrowserOpen = false
                }
            }
        }
    }

    private func apply(state: ServiceState?) {
        lastState = state

        let running = state?.running ?? false
        let online = state?.online ?? false
        let nick = state?.nick.isEmpty == false ? state!.nick : (token.isEmpty ? "等待访问令牌" : "未登录")
        let uin = state?.uin.isEmpty == false ? state!.uin : "——"

        stateItem.title = running
            ? "状态：\(online ? "已连接" : "已启动") · \(nick) · QQ \(uin)"
            : "状态：未启动"

        toggleItem.title = running ? "重启 QCE" : "启动 QCE"
        stopItem.isEnabled = running
        openWebItem.isEnabled = running || startupAttempted

        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: running ? (online ? "checkmark.circle.fill" : "pause.circle.fill") : "circle.dashed", accessibilityDescription: "QCE") {
                image.isTemplate = true
                image.size = NSSize(width: 18, height: 18)
                button.image = image
            }
            button.toolTip = running
                ? "QCE：\(nick) / QQ \(uin)"
                : "QCE：未启动"
        }

        if running, pendingBrowserOpen {
            pendingBrowserOpen = false
            openAuthPage()
        }
    }

    private func fetchState(completion: @escaping (ServiceState?) -> Void) {
        guard !token.isEmpty else {
            completion(nil)
            return
        }

        var request = URLRequest(url: apiInfoURL)
        request.setValue(token, forHTTPHeaderField: "X-Access-Token")

        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let http = response as? HTTPURLResponse, http.statusCode == 200,
                  let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let payload = json["data"] as? [String: Any],
                  let napcat = payload["napcat"] as? [String: Any],
                  let selfInfo = napcat["selfInfo"] as? [String: Any]
            else {
                completion(nil)
                return
            }

            let online = (napcat["online"] as? Bool) ?? false
            completion(ServiceState(
                running: true,
                online: online,
                uin: selfInfo["uin"] as? String ?? "",
                nick: selfInfo["nick"] as? String ?? ""
            ))
        }.resume()
    }

    private func launchQCE(openBrowserWhenReady: Bool) {
        guard launcherProcess?.isRunning != true else { return }
        pendingBrowserOpen = openBrowserWhenReady
        startupAttempted = true

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = [foregroundScript.path]
        task.currentDirectoryURL = qceDir
        var environment = ProcessInfo.processInfo.environment
        environment["QCE_STATUSBAR_OWNER"] = "1"
        task.environment = environment

        if !FileManager.default.fileExists(atPath: launcherLog.path) {
            FileManager.default.createFile(atPath: launcherLog.path, contents: nil)
        }
        if let handle = try? FileHandle(forWritingTo: launcherLog) {
            _ = try? handle.seekToEnd()
            task.standardOutput = handle
            task.standardError = handle
            launcherLogHandle = handle
        }

        do {
            task.terminationHandler = { [weak self] _ in
                DispatchQueue.main.async {
                    self?.launcherLogHandle?.closeFile()
                    self?.launcherLogHandle = nil
                    self?.launcherProcess = nil
                    self?.startupAttempted = false
                    self?.refreshState(startIfNeeded: false)
                }
            }
            try task.run()
            launcherProcess = task
        } catch {
            pendingBrowserOpen = false
            presentAlert(title: "启动失败", message: error.localizedDescription)
            startupAttempted = false
            return
        }

        scheduleStartWatchdog()
    }

    private func scheduleStartWatchdog() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }
            self.refreshState(startIfNeeded: false)
            if self.pendingBrowserOpen {
                self.scheduleStartWatchdog()
            }
        }
    }

    private func stopQCE(completion: (() -> Void)? = nil) {
        pendingBrowserOpen = false

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = [stopScript.path]
        task.currentDirectoryURL = qceDir
        task.terminationHandler = { _ in
            DispatchQueue.main.async {
                self.startupAttempted = false
                self.refreshState(startIfNeeded: false)
                completion?()
            }
        }

        do {
            try task.run()
        } catch {
            presentAlert(title: "停止失败", message: error.localizedDescription)
            completion?()
        }
        launcherLogHandle?.closeFile()
        launcherLogHandle = nil
        launcherProcess = nil
    }

    @objc private func openWebPage() {
        if lastState?.running != true {
            launchQCE(openBrowserWhenReady: true)
            return
        }
        openAuthPage()
    }

    @objc private func toggleQCE() {
        if lastState?.running == true {
            stopQCE { [weak self] in
                self?.launchQCE(openBrowserWhenReady: true)
            }
        } else {
            launchQCE(openBrowserWhenReady: true)
        }
    }

    @objc private func stopQCEAction() {
        stopQCE(completion: nil)
    }

    @objc private func stopAndQuit() {
        stopQCE { NSApp.terminate(nil) }
    }

    private func openAuthPage() {
        NSWorkspace.shared.open(authURL)
    }

    private func loadToken() -> Bool {
        guard let data = try? Data(contentsOf: securityFile),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let token = json["accessToken"] as? String,
              !token.isEmpty
        else {
            return false
        }
        self.token = token
        return true
    }

    private func presentAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}

@main
struct Main {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
