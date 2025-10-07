import ExpoModulesCore
import UIKit

public class ContextMenuWithViewModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ContextMenuWithView")

    View(ContextMenuWithView.self) {
      Prop("menuItems") { (view: ContextMenuWithView, items: [[String: Any]]) in
        view.menuItems = items
      }

      Prop("auxiliaryAlignment") { (view: ContextMenuWithView, alignment: String) in
        view.auxiliaryAlignment = alignment
      }

      Prop("auxiliaryBackgroundColor") { (view: ContextMenuWithView, color: String?) in
        view.auxiliaryBackgroundColor = color
      }

      Prop("plusButtonColor") { (view: ContextMenuWithView, color: String?) in
        view.plusButtonColor = color
      }

      Prop("emojis") { (view: ContextMenuWithView, emojis: [String]) in
        view.emojis = emojis
      }

      Events("onMenuAction", "onEmojiSelected", "onPlusButtonPressed")
    }
  }
}

class ContextMenuWithView: ExpoView {
  let onMenuAction = EventDispatcher()
  let onEmojiSelected = EventDispatcher()
  let onPlusButtonPressed = EventDispatcher()
  var menuItems: [[String: Any]] = []
  var auxiliaryAlignment: String = "center"
  var auxiliaryBackgroundColor: String?
  var plusButtonColor: String?
  var emojis: [String] = []
  private var auxiliaryView: UIView?
  private var contextMenuInteraction: UIContextMenuInteraction?
  private var overlayWindow: UIWindow?
  private var overlayViewController: UIViewController?

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    clipsToBounds = true

    let interaction = UIContextMenuInteraction(delegate: self)
    self.contextMenuInteraction = interaction
    addInteraction(interaction)
  }

  private func hexStringToUIColor(hex: String) -> UIColor {
    var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if cString.hasPrefix("#") {
      cString.remove(at: cString.startIndex)
    }

    if cString.count != 6 {
      return UIColor.gray
    }

    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: 1.0
    )
  }
}

extension ContextMenuWithView: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    configurationForMenuAtLocation location: CGPoint
  ) -> UIContextMenuConfiguration? {
    return UIContextMenuConfiguration(
      identifier: nil,
      previewProvider: { [weak self] in
        self?.makePreviewViewController()
      },
      actionProvider: { [weak self] _ -> UIMenu? in
        guard let self = self else { return nil }

        let actions = self.menuItems.map { item in
          let title = item["title"] as? String ?? ""
          let id = item["id"] as? String ?? ""
          let systemImage = item["systemImage"] as? String

          return UIAction(
            title: title,
            image: systemImage != nil ? UIImage(systemName: systemImage!) : nil
          ) { [weak self] _ in
            self?.onMenuAction(["id": id, "title": title])
          }
        }

        return UIMenu(title: "", children: actions)
      }
    )
  }

  private func makePreviewViewController() -> UIViewController {
    let previewVC = UIViewController()

    // Create snapshot of the actual content
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    let snapshot = renderer.image { context in
      layer.render(in: context.cgContext)
    }

    let contentImageView = UIImageView(image: snapshot)
    contentImageView.translatesAutoresizingMaskIntoConstraints = false
    contentImageView.contentMode = .scaleAspectFit

    previewVC.view.addSubview(contentImageView)

    let contentWidth = bounds.width
    let contentHeight = bounds.height

    NSLayoutConstraint.activate([
      contentImageView.topAnchor.constraint(equalTo: previewVC.view.topAnchor),
      contentImageView.leadingAnchor.constraint(equalTo: previewVC.view.leadingAnchor),
      contentImageView.trailingAnchor.constraint(equalTo: previewVC.view.trailingAnchor),
      contentImageView.bottomAnchor.constraint(equalTo: previewVC.view.bottomAnchor)
    ])

    previewVC.preferredContentSize = CGSize(width: contentWidth, height: contentHeight)

    return previewVC
  }

  func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    willDisplayMenuFor configuration: UIContextMenuConfiguration,
    animator: UIContextMenuInteractionAnimating?
  ) {
    guard let keyWindow = findKeyWindow() else { return }
    guard let windowScene = keyWindow.windowScene else { return }

    // Create auxiliary view
    let auxView = UIView()
    if let colorString = auxiliaryBackgroundColor {
      auxView.backgroundColor = hexStringToUIColor(hex: colorString)
    } else {
      auxView.backgroundColor = .systemBlue
    }
    auxView.layer.cornerRadius = 25
    auxView.translatesAutoresizingMaskIntoConstraints = false
    auxView.isUserInteractionEnabled = true

    // Add shadow for depth
    auxView.layer.shadowColor = UIColor.black.cgColor
    auxView.layer.shadowOpacity = 0.3
    auxView.layer.shadowOffset = CGSize(width: 0, height: 2)
    auxView.layer.shadowRadius = 8

    self.auxiliaryView = auxView

    // Create horizontal stack for emojis
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    stackView.alignment = .center
    stackView.spacing = 4
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.isUserInteractionEnabled = true
    auxView.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: auxView.leadingAnchor, constant: 8),
      stackView.trailingAnchor.constraint(equalTo: auxView.trailingAnchor, constant: -8),
      stackView.topAnchor.constraint(equalTo: auxView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: auxView.bottomAnchor)
    ])

    // Add up to 6 emojis
    let displayEmojis = Array(emojis.prefix(6))
    for emoji in displayEmojis {
      let button = UIButton(type: .system)
      button.setTitle(emoji, for: .normal)
      button.titleLabel?.font = .systemFont(ofSize: 28)
      button.addTarget(self, action: #selector(emojiTapped(_:)), for: .touchUpInside)
      stackView.addArrangedSubview(button)
    }

    // Add "+" button
    let plusButton = UIButton(type: .system)
    plusButton.setTitle("+", for: .normal)
    plusButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .semibold)

    // Set button color
    let buttonColor: UIColor
    if let colorString = plusButtonColor {
      buttonColor = hexStringToUIColor(hex: colorString)
    } else {
      buttonColor = .white.withAlphaComponent(0.7)
    }
    plusButton.setTitleColor(buttonColor, for: .normal)
    plusButton.tintColor = buttonColor

    plusButton.backgroundColor = .clear
    plusButton.layer.cornerRadius = 18
    plusButton.layer.borderWidth = 1.5
    plusButton.layer.borderColor = buttonColor.withAlphaComponent(0.5).cgColor
    plusButton.contentVerticalAlignment = .center
    plusButton.contentHorizontalAlignment = .center

    // Force the button to maintain its size
    plusButton.setContentHuggingPriority(.required, for: .horizontal)
    plusButton.setContentCompressionResistancePriority(.required, for: .horizontal)

    NSLayoutConstraint.activate([
      plusButton.widthAnchor.constraint(equalToConstant: 36),
      plusButton.heightAnchor.constraint(equalToConstant: 36)
    ])

    plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)

    stackView.addArrangedSubview(plusButton)

    let auxWidth: CGFloat = 270
    let auxHeight: CGFloat = 54

    // Calculate X position based on alignment
    let auxX: CGFloat
    switch auxiliaryAlignment {
    case "left":
      auxX = 16
    case "right":
      auxX = keyWindow.bounds.width - auxWidth - 16
    default: // "center"
      auxX = (keyWindow.bounds.width - auxWidth) / 2
    }

    // Calculate where iOS will position the preview
    let frameInWindow = self.convert(self.bounds, to: keyWindow)

    let estimatedMenuItemHeight: CGFloat = 47
    let estimatedMenuPadding: CGFloat = 10
    let estimatedMenuHeight = CGFloat(menuItems.count) * estimatedMenuItemHeight + estimatedMenuPadding * 2

    let previewToMenuSpacing: CGFloat = 10
    let menuBottomMargin: CGFloat = 6

    let totalSpaceNeeded = estimatedMenuHeight + previewToMenuSpacing + menuBottomMargin
    let spaceAvailableBelow = keyWindow.bounds.height - frameInWindow.maxY - keyWindow.safeAreaInsets.bottom

    let actualPreviewY: CGFloat
    if spaceAvailableBelow < totalSpaceNeeded {
      let pushUpAmount = totalSpaceNeeded - spaceAvailableBelow
      let minY = keyWindow.safeAreaInsets.top + 10
      actualPreviewY = max(frameInWindow.minY - pushUpAmount, minY)
    } else {
      actualPreviewY = frameInWindow.minY
    }

    let auxY = actualPreviewY - auxHeight - 8

    // Create overlay window above context menu
    overlayWindow = UIWindow(windowScene: windowScene)
    overlayWindow?.frame = CGRect(x: auxX, y: auxY, width: auxWidth, height: auxHeight)
    overlayWindow?.windowLevel = UIWindow.Level.alert + 1000
    overlayWindow?.backgroundColor = .clear
    overlayWindow?.isUserInteractionEnabled = true
    overlayWindow?.clipsToBounds = false

    // Create view controller
    overlayViewController = UIViewController()
    overlayViewController?.view.backgroundColor = .clear
    overlayViewController?.view.frame = CGRect(origin: .zero, size: CGSize(width: auxWidth, height: auxHeight))
    overlayWindow?.rootViewController = overlayViewController

    // Add auxiliary view to overlay
    overlayViewController?.view.addSubview(auxView)
    auxView.frame = CGRect(origin: .zero, size: CGSize(width: auxWidth, height: auxHeight))

    // Set initial transform for subtle fade-in animation
    let initialTransform: CGAffineTransform
    switch auxiliaryAlignment {
    case "left":
      initialTransform = CGAffineTransform(translationX: -20, y: 0)
    case "right":
      initialTransform = CGAffineTransform(translationX: 20, y: 0)
    default:
      initialTransform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }

    auxView.transform = initialTransform
    auxView.alpha = 0.0

    // Show the window immediately
    overlayWindow?.makeKeyAndVisible()

    // Restore key window status
    DispatchQueue.main.async {
      keyWindow.makeKey()
    }

    animator?.addAnimations {
      auxView.transform = .identity
      auxView.alpha = 1.0
    }
  }

  private func findKeyWindow() -> UIWindow? {
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }

  @objc private func emojiTapped(_ sender: UIButton) {
    guard let emoji = sender.titleLabel?.text else { return }
    contextMenuInteraction?.dismissMenu()
    onEmojiSelected(["emoji": emoji])
  }

  @objc private func plusButtonTapped() {
    contextMenuInteraction?.dismissMenu()
    onPlusButtonPressed([:])
  }

  func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    willEndFor configuration: UIContextMenuConfiguration,
    animator: UIContextMenuInteractionAnimating?
  ) {
    // Subtle fade out in the direction it came from
    let exitTransform: CGAffineTransform
    switch auxiliaryAlignment {
    case "left":
      exitTransform = CGAffineTransform(translationX: -20, y: 0)
    case "right":
      exitTransform = CGAffineTransform(translationX: 20, y: 0)
    default:
      exitTransform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }

    animator?.addAnimations {
      self.auxiliaryView?.transform = exitTransform
      self.auxiliaryView?.alpha = 0.0
    }

    animator?.addCompletion {
      self.cleanupOverlay()
    }
  }

  private func cleanupOverlay() {
    if let overlayWindow = overlayWindow {
      overlayWindow.isHidden = true
      overlayWindow.rootViewController = nil
      self.overlayWindow = nil
      self.overlayViewController = nil
    }

    if let auxiliaryView = auxiliaryView {
      auxiliaryView.removeFromSuperview()
      self.auxiliaryView = nil
    }
  }
}
