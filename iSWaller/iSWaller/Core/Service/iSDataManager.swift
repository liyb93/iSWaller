//
//  iSDataManager.swift
//  iSWaller
//
//  Created by liyb on 2020/7/2.
//  Copyright © 2020 liyb. All rights reserved.
//

import Cocoa
import Carbon
import ServiceManagement
import UserNotifications
import MASShortcut
import FMDB

enum iSImageQualityType: Int {
    case small = 0  // 低
    case medium = 1 // 中
    case large = 2  // 高
}

enum iSAutoChnageWallperType: Int {
    case off = 0    // 关闭
    case fiteen = 1 // 十五分钟
    case thirty = 2 // 三十分钟
    case fortyFive = 3  // 四十五分钟
    case hour = 4   // 1小时
    case twoHour = 5    // 2小时
    case day = 6    // 1天
}

enum iSWallpaperPlatform: Int {
    case unsplash
    case pexels
    case pixabay
}

class iSDataManager: NSObject {
    static let shared = iSDataManager.init()
    
    private struct iSDataKey {
        let rawValue: String
        init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        static let startUp = iSDataKey.init("startUp")
        static let unite = iSDataKey.init("unite")
        static let notification = iSDataKey.init("notification")
        static let wallpaperPath = iSDataKey.init("wallpaperPath")
        static let imageQuality = iSDataKey.init("imageQuality")
        static let wallpaperType = iSDataKey.init("wallpaperType")
        static let previous = iSDataKey.init("previous")
        static let next = iSDataKey.init("next")
        static let version = iSDataKey.init("version")
    }
    
    enum HotKeyType {
        case previous
        case next
    }

    var timer: Timer?
    
    private lazy var database: FMDatabase? = {
        let path = cachePath + "/iSWaller.sqlite"
        let db = FMDatabase.init(path: path)
        return db
    }()
    
    override init() {
        super.init()
        // 修复v1.0版本Bug，下载历史重复添加问题
        if let version = appVersion {
            switch compareVersion(version, "1.0") {
            case .orderedDescending:
                if UserDefaults.standard.object(forKey: iSDataKey.version.rawValue) == nil, let _ = try? FileManager.default.removeItem(atPath: cachePath + "/iSWaller.sqlite") {
                    UserDefaults.standard.setValue("version", forKey: iSDataKey.version.rawValue)
                }
            default:
                break
            }
        }
        // 创建下载历史表
        if database?.open() ?? false {
            if let isExist = database?.tableExists("iSDownload"), isExist {} else {
                let sql = "CREATE TABLE iSDownload(wid TEXT PRIMARY KEY, fullUrl TEXT, mediumUrl TEXT, smallUrl TEXT,user TEXT);"
                do {
                    try database?.executeUpdate(sql, values: nil)
                } catch {
                    iSLog(error)
                }
                database?.close()
            }
        }
    }
    
    // MARK: < App info >
    var appName: String? {
        get {
            return info?["CFBundleDisplayName"] as? String
        }
    }
    
    var appVersion: String? {
        get {
            return info?["CFBundleShortVersionString"] as? String
        }
    }
    
    var copyright: String? {
        get {
            return info?["NSHumanReadableCopyright"] as? String
        }
    }
    
    var info: [String: Any]? {
        get {
            return Bundle.main.infoDictionary
        }
    }
    
    var cachePath: String {
        get {
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        }
    }
    
    var currentWallpaper: iSDownloadModel? {    // 当前的壁纸
        get {
            if let data = UserDefaults.standard.object(forKey: "is.currentWallpaper") as? Data {
                let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data)
                unarchiver?.requiresSecureCoding = false
                return try? unarchiver?.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? iSDownloadModel
            }
            return nil
        }
        set {
            if let model = newValue {
                let data = try? NSKeyedArchiver.archivedData(withRootObject: model, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: "is.currentWallpaper")
            }
        }
    }
    
    private var previousWallpaperModel: iSDownloadModel? // 上一张
    
    // MARK: < Cofig info >
    var isStartUp: Bool {   // 开启自启
        get {
            let value = UserDefaults.standard.bool(forKey: iSDataKey.startUp.rawValue)
            return value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: iSDataKey.startUp.rawValue)
            configAppStartUp(newValue)
        }
    }
    
    var isUnite: Bool { // 多屏统一
        get {
            if UserDefaults.standard.object(forKey: iSDataKey.unite.rawValue) != nil {
                return UserDefaults.standard.bool(forKey: iSDataKey.unite.rawValue)
            }
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: iSDataKey.unite.rawValue)
        }
    }
    
    var isNotification: Bool {  // 更换通知
        get {
            if UserDefaults.standard.object(forKey: iSDataKey.notification.rawValue) != nil {
                return UserDefaults.standard.bool(forKey: iSDataKey.notification.rawValue)
            }
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: iSDataKey.notification.rawValue)
        }
    }
    
    var wallpaperPath: String { // 存储路径
        get {
            if let path = UserDefaults.standard.string(forKey: iSDataKey.wallpaperPath.rawValue) {
                return path
            } else {
                var defaultPath: String = ""
                if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                    defaultPath = path + "/iSWaller/Wallpaper"
                } else {
                    defaultPath = NSHomeDirectory() + "/Documents/iSWaller/Wallpaper"
                }
                if !FileManager.default.fileExists(atPath: defaultPath) {
                    do {
                        try FileManager.default.createDirectory(atPath: defaultPath, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        iSLog("\(error)")
                    }
                }
                return defaultPath
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: iSDataKey.wallpaperPath.rawValue)
        }
    }
    
    var imageQuality: iSImageQualityType {  // 图片预览质量
        get {
            if UserDefaults.standard.object(forKey: iSDataKey.imageQuality.rawValue) != nil {
                let rawValue = UserDefaults.standard.integer(forKey: iSDataKey.imageQuality.rawValue)
                return iSImageQualityType.init(rawValue: rawValue) ?? .medium
            } else {
                return .medium
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: iSDataKey.imageQuality.rawValue)
        }
    }
    
    var autoChangeWallpaperType: iSAutoChnageWallperType {  // 自动切换
        get {
            if UserDefaults.standard.object(forKey: iSDataKey.wallpaperType.rawValue) != nil {
                let rawValue = UserDefaults.standard.integer(forKey: iSDataKey.wallpaperType.rawValue)
                return iSAutoChnageWallperType.init(rawValue: rawValue) ?? .off
            } else {
                return .off
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: iSDataKey.wallpaperType.rawValue)
            startAutoChangeWallpaper()
        }
    }
    
    var previousShortcut: MASShortcut? { // 上一张快捷键
        get {
            if let data = UserDefaults.standard.object(forKey: iSDataKey.previous.rawValue) as? Data {
                let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data)
                unarchiver?.requiresSecureCoding = false
                let value = try? unarchiver?.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? MASShortcut
                return value
            }
            let modifier: NSEvent.ModifierFlags = [.command, .option]
            return MASShortcut.init(keyCode: kVK_LeftArrow, modifierFlags: modifier)
        }
    }
    
    var nextShortcut: MASShortcut? { // 下一张快捷键
        get {
            if let data = UserDefaults.standard.object(forKey: iSDataKey.next.rawValue) as? Data {
                let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data)
                unarchiver?.requiresSecureCoding = false
                let value = try? unarchiver?.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? MASShortcut
                return value
            }
            let modifier: NSEvent.ModifierFlags = [.command, .option]
            return MASShortcut.init(keyCode: kVK_RightArrow, modifierFlags: modifier)
        }
    }
    
    // MARK: < Public function >
    // 设置壁纸
    func setDesktopImage(_ url: URL, model: Any? = nil) {
        var result: Bool = true
        if isUnite {
            for screen in NSScreen.screens {
                do {
                    try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [NSWorkspace.DesktopImageOptionKey.imageScaling: NSImageScaling.scaleAxesIndependently.rawValue])
                } catch {
                    result = false
                }
            }
        } else {
            if let screen = NSScreen.main {
                do {
                    try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [NSWorkspace.DesktopImageOptionKey.imageScaling: NSImageScaling.scaleAxesIndependently.rawValue])
                } catch {
                    result = false
                }
            } else {
                result = false
            }
        }
        if isNotification {
            let title = result ? NSLocalizedString("iSChangeWallpaperSuccess", comment: "壁纸切换成功") : NSLocalizedString("iSChangeWallpaperError", comment: "壁纸切换成功")
            var m: iSDownloadModel?
            if model is iSGalleryModel {
                m = iSDownloadModel.init(model as? iSGalleryModel)
            } else if model is iSDownloadModel {
                m = model as? iSDownloadModel
            }
            postNotification(with: title, model: m)
        }
    }
    
    // 配置快捷键
    func configHotKey() {
        MASShortcutMonitor.shared()?.register(previousShortcut, withAction: { [unowned self] in
            self.previousWallpaper()
        })
        MASShortcutMonitor.shared()?.register(nextShortcut, withAction: { [unowned self] in
            self.nextWallpaper()
        })
    }
    
    // 设置快捷键
    func setHotKey(_ keycode: Int, modifier: NSEvent.ModifierFlags, type: HotKeyType) {
        var key: String!
        if type == .previous {
            key = iSDataKey.previous.rawValue
        } else {
            key = iSDataKey.next.rawValue
        }
        if let shortcut = MASShortcut.init(keyCode: keycode, modifierFlags: modifier) {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: shortcut, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    // 开始更换壁纸
    func startAutoChangeWallpaper() {
        let second = autoChangeWallpaperTypeToSecond(autoChangeWallpaperType)
        if second > 0 {
            timer = Timer.scheduledTimer(timeInterval: second, target: self, selector: #selector(timerDidAction), userInfo: nil, repeats: true)
            timer?.fire()
            RunLoop.current.add(timer!, forMode: .common)
        } else {
            stopAutoChangeWallpaper()
        }
    }
    
    // 停止自动更换壁纸
    func stopAutoChangeWallpaper() {
        timer?.invalidate()
        timer = nil
    }
    
    // 添加历史
    func append(_ model: iSDownloadModel) {
        if let fullUrl = model.fullUrl, let smallUrl = model.smallUrl, let mediumUrl = model.mediumUrl, let wid = model.wid, let user = model.user {
            let sql = "INSERT OR IGNORE INTO iSDownload (wid,fullUrl,mediumUrl,smallUrl,user) VALUES ('\(wid)','\(fullUrl)','\(mediumUrl)','\(smallUrl)','\(user)');"
            if database?.open() ?? false {
                do {
                    try database?.executeUpdate(sql, values: nil)
                } catch {
                    iSLog(error)
                }
                database?.close()
            }
        }
    }
    
    // 移出历史
    func remove(_ models: [iSDownloadModel], handler: (()->())?) {
        DispatchQueue.init(label: "removeDownload").async { [unowned self] in
            for model in models {
                if let wid = model.wid {    // 数据库中删除数据
                    let sql = "DELETE FROM iSDownload WHERE wid = '\(wid)';"
                    if self.database?.open() ?? false {
                        try? self.database?.executeUpdate(sql, values: nil)
                        self.database?.close()
                    }
                }
                if let urlString = model.fullUrl, let url = URL.init(string: urlString) {    // 本地存在文件删除
                    let fileName = url.path.md5()
                    let filePath = iSDataManager.shared.wallpaperPath + "/\(fileName).jpg"
                    if FileManager.default.fileExists(atPath: filePath) {
                        try? FileManager.default.removeItem(atPath: filePath)
                    }
                }
            }
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    // 下一张
    func nextWallpaper() {
        if getDownloads().count <= 1 {
            return
        }
        if let wid = currentWallpaper?.wid {
            // 存储上一张
            previousWallpaperModel = currentWallpaper
            let sql = "SELECT * FROM iSDownload WHERE wid != '\(wid)' ORDER BY RANDOM() LIMIT 1;"
            if database?.open() ?? false, let result = try? database?.executeQuery(sql, values: nil) {
                var download: iSDownloadModel?
                while result.next() {
                    download = iSDownloadModel.init()
                    download?.fullUrl = result.string(forColumn: "fullUrl")
                    download?.smallUrl = result.string(forColumn: "smallUrl")
                    download?.mediumUrl = result.string(forColumn: "mediumUrl")
                    download?.wid = result.string(forColumn: "wid")
                    download?.user = result.string(forColumn: "user")
                }
                database?.close()
                currentWallpaper = download
                if let url = download?.fullUrl {
                    iSNetwork.download(url, progress: nil) { [unowned self] (fileUrl) in
                        if let file = fileUrl {
                            DispatchQueue.main.async { [unowned self] in
                                self.setDesktopImage(file, model: download)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 上一张
    func previousWallpaper() {
        if let url = previousWallpaperModel?.fullUrl {
            iSNetwork.download(url, progress: nil) { [unowned self] (fileUrl) in
                if let file = fileUrl {
                    let temp = self.previousWallpaperModel
                    self.previousWallpaperModel = self.currentWallpaper
                    self.currentWallpaper = temp
                    self.setDesktopImage(file, model: self.previousWallpaperModel)
                }
            }
        }
    }
    
    // 下载历史
    func getDownloads() -> [iSDownloadModel] {
        let sql = "SELECT * FROM iSDownload;"
        if database?.open() ?? false {
            var arr: [iSDownloadModel] = []
            if let result = try? database?.executeQuery(sql, values: nil) {
                while result.next() {
                    let previousModel = iSDownloadModel.init()
                    previousModel.fullUrl = result.string(forColumn: "fullUrl")
                    previousModel.smallUrl = result.string(forColumn: "smallUrl")
                    previousModel.mediumUrl = result.string(forColumn: "mediumUrl")
                    previousModel.wid = result.string(forColumn: "wid")
                    previousModel.user = result.string(forColumn: "user")
                    arr.append(previousModel)
                }
            }
            database?.close()
            return arr
        }
        return []
    }
    
    // 路径移动
    func wallpaperMove(_ path: String, toPath: String) {
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: path) {
            // 移动壁纸到新目录
            for item in contents {
                let fileName = (item as NSString).lastPathComponent
                let path = toPath + "/" + fileName
                do {
                    // 移动文件
                    try FileManager.default.copyItem(atPath: item, toPath: path)
                } catch {
                    iSLog(error)
                }
            }
            
            try? FileManager.default.removeItem(atPath: path)
        }
    }
    
    // 清除网络缓存
    func clearNetworkCache() {
        iSCacheHelper.clearCache()
    }
    
    // MARK: < Private function >
    private func postNotification(with message: String, model: iSDownloadModel?) {
        // 请求权限
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            if granted {
                iSLog("授权成功")
            }
        }
        
        // 发送通知
        let content = UNMutableNotificationContent.init()
        content.title = message
        if let user = model?.user {
            content.body =  "Pixabay-\(user)"
        }
        content.sound = UNNotificationSound.default
        let categoryId = "com.liyb.iSWaller.category"
        content.categoryIdentifier = categoryId
        let category = UNNotificationCategory.init(identifier: categoryId, actions: [], intentIdentifiers: [], options: .customDismissAction)
        let request = UNNotificationRequest.init(identifier: "com.liyb.iSWaller.notification", content: content, trigger: nil)
        
        center.setNotificationCategories([category])
        center.add(request, withCompletionHandler: nil)
    }
    
    private func configAppStartUp(_ isStartUp: Bool) {
        let helperAppIdentifier = "com.liyb.iSWallerHelper"
        let success = SMLoginItemSetEnabled(helperAppIdentifier as CFString, isStartUp)
        if success {
            iSLog(isStartUp ? "添加登录项成功" : "移除登录项成功")
        } else {
            iSLog("配置登录项失败")
        }
    }
    
    private func autoChangeWallpaperTypeToSecond(_ type: iSAutoChnageWallperType) -> TimeInterval {
        var second: TimeInterval = 0;
        switch type {
        case .fiteen:
            second = 15 * 60
        case .thirty:
            second = 30 * 60
        case .fortyFive:
            second = 45 * 60
        case .hour:
            second = 60 * 60
        case .twoHour:
            second = 120 * 60
        case .day:
            second = 24 * 60 * 60
        default:
            break
        }
        return second
    }
    
    @objc private func timerDidAction() {
        nextWallpaper()
    }
}

extension iSDataManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}
