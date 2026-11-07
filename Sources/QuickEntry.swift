import Foundation

struct QuickEntry: Codable {
    var title: String
    var url: String

    init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}

enum QuickStore {

    private static let storageKey = "quickEntries.v1"

    static func load() -> [QuickEntry] {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let list = try? JSONDecoder().decode([QuickEntry].self, from: data),
           !list.isEmpty {
            return list
        }
        return defaultEntries
    }

    static func save(_ entries: [QuickEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    static let defaultEntries: [QuickEntry] = [
        QuickEntry(title: "百度", url: "https://www.baidu.com"),
        QuickEntry(title: "微博", url: "https://m.weibo.cn"),
        QuickEntry(title: "哔哩哔哩", url: "https://m.bilibili.com"),
        QuickEntry(title: "知乎", url: "https://www.zhihu.com"),
        QuickEntry(title: "豆瓣", url: "https://m.douban.com"),
        QuickEntry(title: "GitHub", url: "https://github.com"),
    ]
}
