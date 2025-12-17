//
//  BarcodeScanner.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI
import AVFoundation

// MARK: - Barcode Scanner View
struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var isScanning: Bool
    var supportedTypes: [AVMetadataObject.ObjectType] = [.upce, .code39, .code39Mod43, .ean13, .ean8, .code93, .code128, .pdf417, .qr, .aztec]
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let controller = BarcodeScannerViewController()
        controller.delegate = context.coordinator
        controller.supportedTypes = supportedTypes
        return controller
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        if isScanning {
            uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BarcodeScannerDelegate {
        let parent: BarcodeScannerView
        
        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }
        
        func didFindCode(_ code: String) {
            parent.scannedCode = code
            parent.isScanning = false
        }
        
        func didFailWithError(_ error: Error) {
            print("Barcode scanning error: \(error.localizedDescription)")
            parent.isScanning = false
        }
    }
}

// MARK: - Scanner Protocol
protocol BarcodeScannerDelegate: AnyObject {
    func didFindCode(_ code: String)
    func didFailWithError(_ error: Error)
}

// MARK: - Scanner View Controller
class BarcodeScannerViewController: UIViewController {
    weak var delegate: BarcodeScannerDelegate?
    var supportedTypes: [AVMetadataObject.ObjectType] = []
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "barcode.scanner.session")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkCameraPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()
                    }
                } else {
                    self?.showCameraAccessDenied()
                }
            }
        case .denied, .restricted:
            showCameraAccessDenied()
        @unknown default:
            break
        }
    }
    
    private func setupCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            let session = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                self.delegate?.didFailWithError(ScannerError.noCameraAvailable)
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                
                if session.canAddInput(videoInput) {
                    session.addInput(videoInput)
                } else {
                    self.delegate?.didFailWithError(ScannerError.inputError)
                    return
                }
                
                let metadataOutput = AVCaptureMetadataOutput()
                
                if session.canAddOutput(metadataOutput) {
                    session.addOutput(metadataOutput)
                    metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                    metadataOutput.metadataObjectTypes = self.supportedTypes
                } else {
                    self.delegate?.didFailWithError(ScannerError.outputError)
                    return
                }
                
                self.captureSession = session
                
                DispatchQueue.main.async {
                    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                    previewLayer.frame = self.view.bounds
                    previewLayer.videoGravity = .resizeAspectFill
                    self.view.layer.addSublayer(previewLayer)
                    self.previewLayer = previewLayer
                    self.addScannerOverlay()
                }
                
            } catch {
                self.delegate?.didFailWithError(error)
            }
        }
    }
    
    private func addScannerOverlay() {
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlayView.isUserInteractionEnabled = false
        
        let scanRect = CGRect(x: view.bounds.width / 2 - 150, y: view.bounds.height / 2 - 150, width: 300, height: 300)
        
        let path = UIBezierPath(rect: overlayView.bounds)
        let scanPath = UIBezierPath(roundedRect: scanRect, cornerRadius: 20)
        path.append(scanPath.reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer
        
        view.addSubview(overlayView)
        
        // Add corner brackets
        let bracketLayer = CAShapeLayer()
        bracketLayer.strokeColor = UIColor.systemRed.cgColor
        bracketLayer.lineWidth = 3
        bracketLayer.fillColor = UIColor.clear.cgColor
        
        let bracketPath = UIBezierPath()
        let bracketLength: CGFloat = 30
        
        // Top left
        bracketPath.move(to: CGPoint(x: scanRect.minX + 20, y: scanRect.minY))
        bracketPath.addLine(to: CGPoint(x: scanRect.minX + 20 + bracketLength, y: scanRect.minY))
        bracketPath.move(to: CGPoint(x: scanRect.minX, y: scanRect.minY + 20))
        bracketPath.addLine(to: CGPoint(x: scanRect.minX, y: scanRect.minY + 20 + bracketLength))
        
        // Top right
        bracketPath.move(to: CGPoint(x: scanRect.maxX - 20, y: scanRect.minY))
        bracketPath.addLine(to: CGPoint(x: scanRect.maxX - 20 - bracketLength, y: scanRect.minY))
        bracketPath.move(to: CGPoint(x: scanRect.maxX, y: scanRect.minY + 20))
        bracketPath.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.minY + 20 + bracketLength))
        
        // Bottom left
        bracketPath.move(to: CGPoint(x: scanRect.minX + 20, y: scanRect.maxY))
        bracketPath.addLine(to: CGPoint(x: scanRect.minX + 20 + bracketLength, y: scanRect.maxY))
        bracketPath.move(to: CGPoint(x: scanRect.minX, y: scanRect.maxY - 20))
        bracketPath.addLine(to: CGPoint(x: scanRect.minX, y: scanRect.maxY - 20 - bracketLength))
        
        // Bottom right
        bracketPath.move(to: CGPoint(x: scanRect.maxX - 20, y: scanRect.maxY))
        bracketPath.addLine(to: CGPoint(x: scanRect.maxX - 20 - bracketLength, y: scanRect.maxY))
        bracketPath.move(to: CGPoint(x: scanRect.maxX, y: scanRect.maxY - 20))
        bracketPath.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.maxY - 20 - bracketLength))
        
        bracketLayer.path = bracketPath.cgPath
        view.layer.addSublayer(bracketLayer)
        
        // Add instruction label
        let label = UILabel()
        label.text = "Position barcode within frame"
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            label.widthAnchor.constraint(equalToConstant: 250),
            label.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func showCameraAccessDenied() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Camera Access Required",
                message: "Please enable camera access in Settings to scan barcodes.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self?.present(alert, animated: true)
        }
    }
    
    func startScanning() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopScanning() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
}

// MARK: - Metadata Output Delegate
extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        delegate?.didFindCode(stringValue)
    }
}

// MARK: - Scanner Errors
enum ScannerError: LocalizedError {
    case noCameraAvailable
    case inputError
    case outputError
    
    var errorDescription: String? {
        switch self {
        case .noCameraAvailable:
            return "No camera available on this device"
        case .inputError:
            return "Unable to access camera input"
        case .outputError:
            return "Unable to process camera output"
        }
    }
}