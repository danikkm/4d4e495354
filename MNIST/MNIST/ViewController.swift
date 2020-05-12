//
//  ViewController.swift
//  MNIST
//
//  Created by Daniel Dluzhnevsky on 2020-04-20.
//  Copyright © 2020 Daniel Dluznevskij. All rights reserved.
//

import UIKit
import Vision


class ViewController: UIViewController {

    private lazy var answerLabel: UILabel = self.initAnswerLabel()
    private lazy var viewForCanvas: UIView = self.initViewForCanvas()
    private var canvasView = CanvasView()
    private lazy var clearButton: UIButton = self.initClearButton()
    private lazy var recogniseButton: UIButton = self.initRecogniseButton()
    var request = [VNRequest]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.viewForCanvas)
        self.activateViewForCanvasConstraints()
        self.activateCanvasViewConstraints()


        self.view.addSubview(self.clearButton)
        self.activateClearButtonConstraints()

        self.view.addSubview(self.recogniseButton)
        self.activateRecogniseButtonConstraints()

        self.view.addSubview(self.answerLabel)
        self.activateAnswerLabelConstraints()
        
        self.setupCoreMLRequest()
    }


}

extension ViewController {
    private func setupCoreMLRequest() {
        
        // load model
        let my_model = latest().model

        guard let model = try? VNCoreMLModel(for: my_model) else {
            fatalError("Cannot load Core ML Model")
        }
        
        // set up request
        let MNIST_request = VNCoreMLRequest(model: model, completionHandler: handleMNISTClassification)
        self.request = [MNIST_request]
    }

    // handle request
    func handleMNISTClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            debugPrint("No results")
            return
        }

        print(observations)

        let classification = observations
            .compactMap({ $0 as? VNClassificationObservation })
            .filter({ $0.confidence > 0.9925 }) // filter confidence > 0.9925
        .map({ $0.identifier }) // map the identifier as answer
        print("confidence:", observations.compactMap({ $0 as? VNClassificationObservation }).map({ $0.identifier }))
        self.updateLabel(with: classification.first)

    }
    
    private func updateLabel(with text: String?) {
           // update UI should be on main thread
           DispatchQueue.main.async {
               self.answerLabel.text = text
           }
    }
}

extension ViewController {
    @objc private func clearInput() {
        self.canvasView.clearCanvas()
        self.answerLabel.text = "?"
    }

    @objc private func recognise() {
        // The model takes input with 28 by 28 pixels, check the uiimage extension for
        // - Get snapshot of an view (Canvas)
        // - Resize image

        let image = UIImage(view: self.canvasView).scale(toSize: CGSize(width: 28, height: 28))

        let imageRequest = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        do {
            try imageRequest.perform(self.request)
        }
        catch {
            print(error)
        }
    }
}

extension ViewController {
    private func initAnswerLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 104)
        label.text = "?"
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.contentMode = .scaleAspectFit
        return label
    }
    
    private func initViewForCanvas() -> UIView {
        let view = UIView()
        view.addSubview(self.canvasView)
        self.canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private func initClearButton() -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 12.5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(clearInput), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func initRecogniseButton() -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 12.5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Recognise", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(recognise), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}

extension ViewController {
    private func activateAnswerLabelConstraints() {
        NSLayoutConstraint.activate([
            self.answerLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.answerLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32),
            self.answerLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32),
            self.answerLabel.heightAnchor.constraint(equalToConstant: 208)
//            self.answerLabel.bottomAnchor.constraint(equalTo: self.clearButton.topAnchor, constant: -16)
            ])
    }
    
    private func activateViewForCanvasConstraints() {
        NSLayoutConstraint.activate([
            self.viewForCanvas.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            self.viewForCanvas.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            self.viewForCanvas.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            self.viewForCanvas.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.height / 2)
            ])
    }

    private func activateCanvasViewConstraints() {
        NSLayoutConstraint.activate([
            self.canvasView.topAnchor.constraint(equalTo: self.viewForCanvas.topAnchor),
            self.canvasView.bottomAnchor.constraint(equalTo: self.viewForCanvas.bottomAnchor),
            self.canvasView.leadingAnchor.constraint(equalTo: self.viewForCanvas.leadingAnchor),
            self.canvasView.trailingAnchor.constraint(equalTo: self.viewForCanvas.trailingAnchor)
            ])
    }
    private func activateClearButtonConstraints() {
        NSLayoutConstraint.activate([
            self.clearButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            self.clearButton.bottomAnchor.constraint(equalTo: canvasView.topAnchor, constant: -16),
            self.clearButton.widthAnchor.constraint(equalToConstant: 120),
            self.clearButton.heightAnchor.constraint(equalToConstant: 50),
            ])
    }

    private func activateRecogniseButtonConstraints() {
        NSLayoutConstraint.activate([
            self.recogniseButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            self.recogniseButton.bottomAnchor.constraint(equalTo: canvasView.topAnchor, constant: -16),
            self.recogniseButton.widthAnchor.constraint(equalToConstant: 120),
            self.recogniseButton.heightAnchor.constraint(equalToConstant: 50),
            ])
    }
}

