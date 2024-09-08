import UIKit
import CoreLocation
import MiniAppInterfaces

public class WeatherMiniApp: UIView {
    private lazy var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "weather")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Погода"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true

        return label
    }()
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 27, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private lazy var coordinatesLabel: UILabel = {
        let label = UILabel()
        label.text = "Координаты: неизвестны"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.numberOfLines = 2

        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImage, temperatureLabel, activityIndicator])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let locationManager = LocationManager()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        fetchLocation()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        fetchLocation()
    }

    private func setupUI() {
        backgroundColor = .white
        addSubview(infoLabel)
        addSubview(coordinatesLabel)
        addSubview(stackView)

        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),

            iconImage.widthAnchor.constraint(equalToConstant: 50),
            iconImage.heightAnchor.constraint(equalToConstant: 50),

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            coordinatesLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 10),
            coordinatesLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            coordinatesLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }

    private func fetchLocation() {
        activityIndicator.startAnimating()
        locationManager.requestLocation { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let location):
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                self.coordinatesLabel.text = "Ваши координаты: \n\(latitude), \(longitude)"
                self.fetchWeather(latitude: latitude, longitude: longitude)
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case .denied:
                        self.showAlert(title: "Ошибка доступа", message: "Доступ к геолокации запрещен. Пожалуйста, разрешите доступ в настройках.")
                        self.temperatureLabel.text = "Ошибка"
                    case .failedToLocate:
                        self.showAlert(title: "Ошибка", message: "Не удалось получить ваши координаты. Попробуйте снова.")
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }

    private func fetchWeather(latitude: Double, longitude: Double) {
        Task {
            do {
                let weatherModel = try await NetworkManager.shared.fetchData(latitude: latitude, longitude: longitude)
                DispatchQueue.main.async {
                    self.updateLabel(with: weatherModel)
                    self.activityIndicator.stopAnimating()
                }
            } catch NetworkingError.badURL {
                DispatchQueue.main.async {
                    self.showAlert(title: "Ошибка URL", message: "Неправильный URL. Пожалуйста, проверьте URL.")
                    self.temperatureLabel.text = "Ошибка"
                    self.activityIndicator.stopAnimating()
                }
            } catch NetworkingError.badResponse {
                DispatchQueue.main.async {
                    self.showAlert(title: "Ошибка сервера", message: "Некорректный ответ сервера. Попробуйте позже.")
                    self.temperatureLabel.text = "Ошибка"
                    self.activityIndicator.stopAnimating()
                }
            } catch NetworkingError.decodingError {
                DispatchQueue.main.async {
                    self.showAlert(title: "Ошибка данных", message: "Не удалось декодировать данные о погоде.")
                    self.temperatureLabel.text = "Ошибка"
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Неизвестная ошибка", message: "Произошла неизвестная ошибка.")
                    self.temperatureLabel.text = "Ошибка"
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }

    private func updateLabel(with weatherModel: WeatherModel) {
        temperatureLabel.text = "\(weatherModel.current.temperature2M)°C"
    }
}

extension WeatherMiniApp {
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ок", style: .default))
        if let controller = self.window?.rootViewController {
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}

extension WeatherMiniApp: DisplayModeUpdatable {
    public func updateDisplayMode(to mode: String) {
        switch mode {
        case "oneEighth":
            coordinatesLabel.isHidden = true
            infoLabel.isHidden = true
            stackView.axis = .horizontal
        case "half", "fullScreen":
            coordinatesLabel.isHidden = false
            infoLabel.isHidden = false
            stackView.axis = .vertical
        default:
            coordinatesLabel.isHidden = false
            infoLabel.isHidden = false
        }
    }
}
