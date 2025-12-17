//
//  ScannerView.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI
import AVFoundation

struct ScannerView: View {
    @EnvironmentObject var appState: AppState
    @State private var scannedCode: String = ""
    @State private var showingPriceComparison = false
    @State private var showingManualEntry = false
    @State private var manualBarcode = ""
    @State private var torchOn = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera View
                BarcodeScannerRepresentable(scannedCode: $scannedCode, torchOn: $torchOn)
                    .ignoresSafeArea()
                    .onAppear {
                        appState.isScanning = true
                    }
                    .onDisappear {
                        appState.isScanning = false
                    }
                
                // Scanning Overlay
                VStack {
                    // Top Bar
                    HStack {
                        Button("Cancel") {
                            appState.selectedTab = .home
                        }
                        .foregroundColor(.white)
                        .padding()
                        
                        Spacer()
                        
                        Button(action: { torchOn.toggle() }) {
                            Image(systemName: torchOn ? "bolt.fill" : "bolt")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .background(Color.black.opacity(0.5))
                    
                    Spacer()
                    
                    // Scanning Frame
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 280, height: 200)
                        .overlay(
                            VStack {
                                Text("Align barcode within frame")
                                    .foregroundColor(.white)
                                    .padding(.top, -100)
                            }
                        )
                    
                    Spacer()
                    
                    // Manual Entry Button
                    VStack(spacing: 20) {
                        Button(action: { showingManualEntry = true }) {
                            HStack {
                                Image(systemName: "keyboard")
                                Text("Enter Barcode Manually")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(25)
                        }
                        
                        Text("Scan any product barcode")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .onChange(of: scannedCode) { newValue in
                if !newValue.isEmpty {
                    showingPriceComparison = true
                }
            }
            .sheet(isPresented: $showingPriceComparison) {
                PriceComparisonView(barcode: scannedCode)
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualBarcodeEntry(barcode: $manualBarcode, isPresented: $showingManualEntry) {
                    scannedCode = manualBarcode
                    showingManualEntry = false
                }
            }
        }
    }
}

// MARK: - Manual Barcode Entry
struct ManualBarcodeEntry: View {
    @Binding var barcode: String
    @Binding var isPresented: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter the barcode number below the product barcode")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextField("Barcode number", text: $barcode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .font(.title2)
                    .padding()
                
                Button(action: onSubmit) {
                    Text("Search Product")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(barcode.isEmpty)
                
                Spacer()
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Barcode Scanner Camera View
struct BarcodeScannerRepresentable: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var torchOn: Bool
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        uiViewController.updateTorchState(torchOn)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BarcodeScannerDelegate {
        let parent: BarcodeScannerRepresentable
        
        init(_ parent: BarcodeScannerRepresentable) {
            self.parent = parent
        }
        
        func didScanBarcode(_ code: String) {
            parent.scannedCode = code
        }
    }
}

// MARK: - Barcode Scanner View Controller
protocol BarcodeScannerDelegate: AnyObject {
    func didScanBarcode(_ code: String)
}

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: BarcodeScannerDelegate?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var device: AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        self.device = videoCaptureDevice
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce, .code128, .code39]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
    }
    
    private func startScanning() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
    
    private func stopScanning() {
        captureSession?.stopRunning()
    }
    
    func updateTorchState(_ on: Bool) {
        guard let device = device, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            delegate?.didScanBarcode(stringValue)
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
            .environmentObject(AppState())
    }
}