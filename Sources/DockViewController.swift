import UIKit

final class DockViewController: UITableViewController {

    private var entries: [QuickEntry]

    var onPick: ((QuickEntry) -> Void)?
    var onSave: (([QuickEntry]) -> Void)?

    init(entries: [QuickEntry]) {
        self.entries = entries
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选择面板内容"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "entryCell")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(closeTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addTapped))
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func addTapped() {
        let alert = UIAlertController(title: "新增面板条目",
                                      message: "填标题和网址，网址不带 https:// 也可以",
                                      preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "标题，例如 小红书"
        }
        alert.addTextField { field in
            field.placeholder = "网址，例如 xiaohongshu.com"
            field.keyboardType = .URL
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "添加", style: .default, handler: { [weak self, weak alert] _ in
            guard let self = self, let alert = alert else { return }
            let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let url = alert.textFields?.last?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !url.isEmpty else { return }
            let entry = QuickEntry(title: title.isEmpty ? url : title, url: url)
            self.entries.append(entry)
            self.onSave?(self.entries)
            self.tableView.reloadData()
        }))
        present(alert, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        let entry = entries[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = entry.title
        content.secondaryText = entry.url
        content.image = UIImage(systemName: "square.on.square")
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = entries[indexPath.row]
        onPick?(entry)
        dismiss(animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        entries.remove(at: indexPath.row)
        onSave?(entries)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView,
                            titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}
