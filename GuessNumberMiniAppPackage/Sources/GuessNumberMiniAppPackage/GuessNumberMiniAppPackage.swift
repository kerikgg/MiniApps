import UIKit
import MiniAppInterfaces

public class GuessNumberMiniApp: UIView {
    private var randomNumber: Int = Int.random(in: 1...100)

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Угадай число!"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "numbers")
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

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Угадайте число от 1 до 100"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 100
        slider.value = 50
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private lazy var guessButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.setTitle("Угадать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false

        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.checkGuess()
        }
        button.addAction(action, for: .touchUpInside)

        return button
    }()

    private var attemptsCountLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var resultLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [hintLabel, resultLabel, slider, attemptsCountLabel, guessButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var attemptsCount = 0

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

        addSubview(mainStackView)
        addSubview(infoStackView)

        NSLayoutConstraint.activate([
            infoStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoStackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),

            mainStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            guessButton.widthAnchor.constraint(equalToConstant: 150),
            guessButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func checkGuess() {
        let userGuess = Int(slider.value)

        if userGuess < randomNumber {
            attemptsCount += 1
            animateResultTextChange(newText: "Загаданное число больше!", attemptsCount: attemptsCount)
        } else if userGuess > randomNumber {
            attemptsCount += 1
            animateResultTextChange(newText: "Загаданное число меньше!", attemptsCount: attemptsCount)
        } else {
            resultAlert(title: "Победа")
            resetGame()
        }
    }

    private func animateResultTextChange(newText: String, attemptsCount: Int) {
        UIView.animate(withDuration: 0.2, animations: {
            self.resultLabel.alpha = 0
            self.attemptsCountLabel.alpha = 0
        }) { _ in
            self.resultLabel.text = newText
            self.attemptsCountLabel.text = "Попыток: \(attemptsCount)"

            UIView.animate(withDuration: 0.2) {
                self.resultLabel.alpha = 1
                self.attemptsCountLabel.alpha = 1
            }
        }
    }

    private func resetGame() {
        randomNumber = Int.random(in: 1...100)
        slider.value = 50
        resultLabel.text = ""
        attemptsCountLabel.text = ""
        attemptsCount = 0
    }
}

extension GuessNumberMiniApp {
    private func resultAlert(title: String) {
        let message = "Поздравляем! Вы угадали!"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Заново", style: .default, handler: { _ in
            self.resetGame()
        }))
        if let controller = self.window?.rootViewController {
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}

extension GuessNumberMiniApp: DisplayModeUpdatable {
    public func updateDisplayMode(to mode: String) {
        switch mode {
        case "oneEighth":
            titleLabel.isHidden = false
            iconImageView.isHidden = false
            hintLabel.isHidden = true
            slider.isHidden = true
            guessButton.isHidden = true
            resultLabel.isHidden = true
        case "half", "fullScreen":
            titleLabel.isHidden = true
            iconImageView.isHidden = true
            hintLabel.isHidden = false
            slider.isHidden = false
            guessButton.isHidden = false
            resultLabel.isHidden = false
        default:
            titleLabel.isHidden = false
            iconImageView.isHidden = false
            hintLabel.isHidden = true
            slider.isHidden = true
            guessButton.isHidden = true
            resultLabel.isHidden = true
        }
    }
}
