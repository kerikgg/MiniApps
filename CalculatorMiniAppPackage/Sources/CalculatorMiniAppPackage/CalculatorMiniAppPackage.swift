import UIKit
import MiniAppInterfaces

public class CalculatorMiniApp: UIView {
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Калькулятор"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "calculator")
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

    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .right
        label.backgroundColor = .lightGray
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    private var buttons = [UIButton]()
    private let buttonTitles: [[String]] = [
        ["C", "7", "8", "9", "/"],
        ["4", "5", "6", "*"],
        ["1", "2", "3", "-"],
        ["0", ".", "=", "+"]
    ]

    private var currentNumber: String = "0"
    private var previousNumber: String = ""
    private var operation: String = ""

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white
        addSubview(infoStackView)
        addSubview(resultLabel)

        NSLayoutConstraint.activate([
            infoStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50)
        ])


        let heightConstraint = resultLabel.heightAnchor.constraint(equalToConstant: 60)
        heightConstraint.priority = UILayoutPriority(750)
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            resultLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            heightConstraint
        ])

        let gridStackView = createGridStackView()
        addSubview(gridStackView)
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridStackView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            gridStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            gridStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            gridStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    private func createGridStackView() -> UIStackView {
        let gridStackView = UIStackView()
        gridStackView.axis = .vertical
        gridStackView.distribution = .fillEqually
        gridStackView.spacing = 10

        for row in buttonTitles {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 10

            for title in row {
                let button = createButton(withTitle: title)
                buttons.append(button)
                rowStackView.addArrangedSubview(button)
            }
            gridStackView.addArrangedSubview(rowStackView)
        }

        return gridStackView
    }

    private func createButton(withTitle title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.backgroundColor = .darkGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8

        let action = UIAction { [weak self] _ in
            guard let self else { return }
            guard let title = button.currentTitle else { return }

            switch title {
            case "0"..."9", ".":
                handleNumberInput(title)
            case "/", "*", "-", "+":
                handleOperationInput(title)
            case "=":
                handleEqualsInput()
            case "C":
                handleClearInput()
            default:
                break
            }

        }
        button.addAction(action, for: .touchUpInside)
        return button
    }

    private func handleNumberInput(_ number: String) {
        if currentNumber == "0" && number != "." {
            currentNumber = number
        } else {
            currentNumber += number
        }
        resultLabel.text = currentNumber
    }

    private func handleOperationInput(_ op: String) {
        if !currentNumber.isEmpty {
            previousNumber = currentNumber
            currentNumber = "0"
            operation = op
        }
    }

    private func handleEqualsInput() {
        guard !previousNumber.isEmpty && !currentNumber.isEmpty else { return }

        let num1 = Double(previousNumber) ?? 0
        let num2 = Double(currentNumber) ?? 0
        var result: Double = 0

        switch operation {
        case "/":
            result = num1 / num2
        case "*":
            result = num1 * num2
        case "-":
            result = num1 - num2
        case "+":
            result = num1 + num2
        default:
            break
        }

        resultLabel.text = "\(result)"
        currentNumber = "\(result)"
        previousNumber = ""
        operation = ""
    }

    private func handleClearInput() {
        currentNumber = "0"
        previousNumber = ""
        operation = ""
        resultLabel.text = "0"
    }
}

extension CalculatorMiniApp: DisplayModeUpdatable {
    public func updateDisplayMode(to mode: String) {
        switch mode {
        case "oneEighth":
            titleLabel.isHidden = false
            iconImageView.isHidden = false
            resultLabel.isHidden = true
            buttons.forEach { $0.isHidden = true }
        case "half", "fullScreen":
            titleLabel.isHidden = true
            iconImageView.isHidden = true
            resultLabel.isHidden = false
            buttons.forEach { $0.isHidden = false }
        default:
            titleLabel.isHidden = true
            iconImageView.isHidden = true
            resultLabel.isHidden = false
        }
    }
}
