//
//  ViewController.swift
//  MiniAppsProject
//
//  Created by kerik on 08.09.2024.
//

import UIKit
import CalculatorMiniAppPackage
import WeatherMiniAppPackage
import TicTacToeMiniAppPackage
import GuessNumberMiniAppPackage
import MiniAppInterfaces

enum DisplayMode: Double {
    case oneEighth = 0.125
    case half = 0.5
    case fullScreen = 1
}

final class MainViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorInset = .zero
        tableView.delaysContentTouches = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MiniAppCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    private var displayMode: DisplayMode = .oneEighth

    private let miniApps: [UIView] = [
        WeatherMiniApp(),
        TicTacToeMiniApp(),
        CalculatorMiniApp(),
        GuessNumberMiniApp(),
        WeatherMiniApp(),
        TicTacToeMiniApp(),
        CalculatorMiniApp(),
        GuessNumberMiniApp(),
        WeatherMiniApp(),
        TicTacToeMiniApp()
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(tableView)

        setupNavigationBar()
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = "Мини-приложения"

        let menuButton = UIBarButtonItem(title: "Выбор", style: .plain, target: self, action: nil)
        menuButton.image = UIImage(systemName: "square.grid.2x2")

        let firstAction = UIAction(title: "1/8 Экрана") { [weak self] _ in
            self?.updateDisplayMode(.oneEighth)
        }
        let secondAction = UIAction(title: "1/2 Экрана") { [weak self] _ in
            self?.updateDisplayMode(.half)
        }
        let thirdAction = UIAction(title: "Полный экран") { [weak self] _ in
            self?.updateDisplayMode(.fullScreen)
        }

        let menu = UIMenu(children: [firstAction, secondAction, thirdAction])
        menuButton.menu = menu
        navigationItem.leftBarButtonItem = menuButton
    }

    private func updateDisplayMode(_ mode: DisplayMode) {
        displayMode = mode
        tableView.reloadData()
    }
}

extension MainViewController {
    private func availableHeight(for displayMode: DisplayMode) -> CGFloat {
        guard let windowScene = view.window?.windowScene else {
            return view.frame.height * displayMode.rawValue
        }

        let statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height ?? 0
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let screenHeight = view.frame.height - navigationBarHeight - statusBarHeight

        return screenHeight * displayMode.rawValue
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        availableHeight(for: displayMode)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return miniApps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MiniAppCell", for: indexPath)
        cell.selectionStyle = .none

        // Удаляем все subviews из ячейки, чтобы избежать дублирования
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let miniApp = miniApps[indexPath.row]
        cell.contentView.addSubview(miniApp)
        miniApp.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            miniApp.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            miniApp.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            miniApp.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            miniApp.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])

        if let displayModeUpdatable = miniApp as? DisplayModeUpdatable {
            let modeString: String
            switch displayMode {
            case .oneEighth:
                modeString = "oneEighth"
            case .half:
                modeString = "half"
            case .fullScreen:
                modeString = "fullScreen"
            }
            displayModeUpdatable.updateDisplayMode(to: modeString)
        }

        let isInteractionEnabled = displayMode != .oneEighth
        miniApp.isUserInteractionEnabled = isInteractionEnabled

        return cell
    }

}
