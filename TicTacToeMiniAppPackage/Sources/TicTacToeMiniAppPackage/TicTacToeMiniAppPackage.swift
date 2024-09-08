import UIKit
import MiniAppInterfaces

enum Turn {
    case Nought
    case Cross
}

public class TicTacToeMiniApp: UIView {
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Крестики-Нолики"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ticTacToe")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var turnLabel: UILabel = {
        let label = UILabel()
        label.text = "X"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var firstTurn = Turn.Cross
    private var currentTurn = Turn.Cross

    private let nought = "O"
    private let cross = "X"
    private var board = [UIButton]()

    private var noughtsScore = 0
    private var crossesScore = 0

    // Кнопки на поле
    private var a1 = UIButton()
    private var a2 = UIButton()
    private var a3 = UIButton()
    private var b1 = UIButton()
    private var b2 = UIButton()
    private var b3 = UIButton()
    private var c1 = UIButton()
    private var c2 = UIButton()
    private var c3 = UIButton()

    private lazy var gridStackView: UIStackView = {
        let buttons = [a1, a2, a3, b1, b2, b3, c1, c2, c3]
        let stackView = UIStackView(arrangedSubviews: [
            createRow(buttons: [a1, a2, a3]),
            createRow(buttons: [b1, b2, b3]),
            createRow(buttons: [c1, c2, c3])
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        initBoard()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        initBoard()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    private func setupUI() {
        backgroundColor = .white

        let buttons = [a1, a2, a3, b1, b2, b3, c1, c2, c3]
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 50)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .systemGray6

            button.addAction(UIAction { [weak self] _ in
                self?.boardTapAction(button)
            }, for: .touchUpInside)
            addSubview(button)
        }

        addSubview(gridStackView)
        addSubview(turnLabel)
        addSubview(infoStackView)

        NSLayoutConstraint.activate([
            infoStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoStackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),

            turnLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            turnLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),

            gridStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            gridStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            gridStackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
            gridStackView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7)
        ])
    }

    private func createRow(buttons: [UIButton]) -> UIStackView {
        let row = UIStackView(arrangedSubviews: buttons)
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 10
        return row
    }

    private func initBoard() {
        board.append(a1)
        board.append(a2)
        board.append(a3)
        board.append(b1)
        board.append(b2)
        board.append(b3)
        board.append(c1)
        board.append(c2)
        board.append(c3)
    }

    private func boardTapAction(_ button: UIButton) {
        addToBoard(button)

        if checkVictory(for: cross) {
            crossesScore += 1
            resultAlert(title: "Крестики Победили!")
        }

        if checkVictory(for: nought) {
            noughtsScore += 1
            resultAlert(title: "Нолики Победили!")
        }

        if fullBoard() {
            resultAlert(title: "Ничья")
        }
    }

    private func addToBoard(_ button: UIButton) {
        if button.title(for: .normal) == nil {
            if currentTurn == .Cross {
                button.setTitle(cross, for: .normal)
                currentTurn = .Nought
                turnLabel.text = nought
            } else {
                button.setTitle(nought, for: .normal)
                currentTurn = .Cross
                turnLabel.text = cross
            }
        }
    }

    private func checkVictory(for symbol: String) -> Bool {
        let victoryPatterns: [[UIButton]] = [
            [a1, a2, a3],
            [b1, b2, b3],
            [c1, c2, c3],
            [a1, b1, c1],
            [a2, b2, c2],
            [a3, b3, c3],
            [a1, b2, c3],
            [a3, b2, c1]
        ]

        for pattern in victoryPatterns {
            if pattern.allSatisfy({ $0.title(for: .normal) == symbol }) {
                return true
            }
        }

        return false
    }

    private func fullBoard() -> Bool {
        return board.allSatisfy { $0.title(for: .normal) != nil }
    }

    private func resetBoard() {
        for button in board {
            button.setTitle(nil, for: .normal)
        }
        currentTurn = firstTurn
        turnLabel.text = currentTurn == .Cross ? cross : nought
    }
}

extension TicTacToeMiniApp {
    private func resultAlert(title: String) {
        let message = "\nНолики: \(noughtsScore)\nКрестики: \(crossesScore)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Заново", style: .default, handler: { _ in
            self.resetBoard()
        }))
        if let controller = self.window?.rootViewController {
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}

extension TicTacToeMiniApp: DisplayModeUpdatable {
    public func updateDisplayMode(to mode: String) {
        switch mode {
        case "oneEighth":
            titleLabel.isHidden = false
            iconImageView.isHidden = false
            turnLabel.isHidden = true
            board.forEach { $0.isHidden = true }

        case "half", "fullScreen":
            titleLabel.isHidden = true
            iconImageView.isHidden = true
            turnLabel.isHidden = false
            board.forEach { $0.isHidden = false }
        default:
            titleLabel.isHidden = false
            iconImageView.isHidden = false
            turnLabel.isHidden = true
            board.forEach { $0.isHidden = true }
        }
    }
}

extension TicTacToeMiniApp {
    @objc private func orientationDidChange() {
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        // Проверяем, является ли устройство iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                updateConstraintsForLandscape()
            } else {
                updateConstraintsForPortrait()
            }
        }
    }

    // Обновление констрейнтов для ландшафтной ориентации
    private func updateConstraintsForLandscape() {
        NSLayoutConstraint.deactivate(self.constraints)

        NSLayoutConstraint.activate([
            infoStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoStackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),

            turnLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            turnLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),

            gridStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            gridStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            gridStackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            gridStackView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
        ])
    }

    // Обновление констрейнтов для портретной ориентации
    private func updateConstraintsForPortrait() {
        NSLayoutConstraint.deactivate(self.constraints)

        NSLayoutConstraint.activate([
            infoStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoStackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),

            turnLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            turnLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),

            gridStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            gridStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            gridStackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6),
            gridStackView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6)
        ])
    }
}
