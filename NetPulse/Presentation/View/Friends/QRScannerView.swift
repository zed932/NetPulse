//
//  QRScannerView.swift
//  NetPulse
//

import SwiftUI
import AVFoundation

final class QRScannerViewController: UIViewController {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var session: AVCaptureSession?
    let sessionQueue = DispatchQueue(label: "qr.capture.session")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async { [weak self] in
            self?.session?.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async { [weak self] in
            self?.session?.stopRunning()
        }
    }

    func setupSession(with outputDelegate: AVCaptureMetadataOutputObjectsDelegate) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            let session = AVCaptureSession()
            session.beginConfiguration()
            defer { session.commitConfiguration() }

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else { return }
            session.addInput(input)

            let output = AVCaptureMetadataOutput()
            guard session.canAddOutput(output) else { return }
            session.addOutput(output)
            output.setMetadataObjectsDelegate(outputDelegate, queue: .main)
            output.metadataObjectTypes = [.qr]

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill

            DispatchQueue.main.async {
                self.session = session
                self.previewLayer = preview
                preview.frame = self.view.layer.bounds
                self.view.layer.insertSublayer(preview, at: 0)
            }
        }
    }
}

/// Обёртка над AVCaptureSession для сканирования QR‑кодов.
struct QRScannerView: UIViewControllerRepresentable {
    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let parent: QRScannerView
        var didScan = false

        init(parent: QRScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  object.type == .qr,
                  let value = object.stringValue else { return }
            guard !didScan else { return }
            didScan = true
            let callback = parent.onCodeScanned
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    var onCodeScanned: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.setupSession(with: context.coordinator)
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        if let preview = uiViewController.previewLayer, preview.superlayer != uiViewController.view.layer {
            preview.frame = uiViewController.view.layer.bounds
            uiViewController.view.layer.insertSublayer(preview, at: 0)
        }
    }

    static func dismantleUIViewController(_ uiViewController: QRScannerViewController, coordinator: Coordinator) {
        uiViewController.sessionQueue.async {
            uiViewController.session?.stopRunning()
        }
        uiViewController.previewLayer?.removeFromSuperlayer()
    }
}
