import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var cardsViewModel: CardsViewModel
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingAboutSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Storage")) {
                    HStack {
                        Image(systemName: "internaldrive")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Local Storage")
                                .font(.headline)
                            Text("All data stored securely on your device")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Data & Privacy")) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Privacy First")
                                .font(.headline)
                            Text("No tracking, no analytics, no data collection")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        showingExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Export Data")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        showingImportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Import Data")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text("Preferences")) {
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Currency")
                        
                        Spacer()
                        
                        Text("USD")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Date Format")
                        
                        Spacer()
                        
                        Text("MM/DD/YYYY")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("About")) {
                    Button(action: {
                        showingAboutSheet = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("About MyCardBook")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://github.com/pthakkar9/MyCardBook") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Open Source Code")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://launchpadlogic.com/mycardbook/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://launchpadlogic.com/mycardbook/support") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Support & Help")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportDataView()
                .environmentObject(cardsViewModel)
        }
        .sheet(isPresented: $showingImportSheet) {
            ImportDataView()
                .environmentObject(cardsViewModel)
        }
        .sheet(isPresented: $showingAboutSheet) {
            AboutView()
        }
    }
}

struct ExportDataView: View {
    @EnvironmentObject var cardsViewModel: CardsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var exportService = DataExportService.shared
    @State private var exportFormat: ExportFormat = .json
    @State private var showingShareSheet = false
    @State private var shareItem: ShareItem?
    @State private var isExporting = false
    @State private var exportError: String?
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csvCards = "CSV (Cards)"
        case csvCredits = "CSV (Credits)"
        
        var fileExtension: String {
            switch self {
            case .json: return "json"
            case .csvCards, .csvCredits: return "csv"
            }
        }
        
        var description: String {
            switch self {
            case .json: return "Complete data export including all cards and credits"
            case .csvCards: return "Cards only with summary information"
            case .csvCredits: return "Credits only with detailed usage data"
            }
        }
    }
    
    struct ShareItem {
        let data: Data
        let filename: String
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Export Your Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Export all your cards and credits data to a file")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    Text("Export Format")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Button(action: {
                            exportFormat = format
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(format.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(format.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if exportFormat == format {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(exportFormat == format ? Color(.secondarySystemBackground) : Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(exportFormat == format ? Color.blue : Color(.separator), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Button(action: {
                    exportData()
                }) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isExporting ? "Exporting..." : "Export Data")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(cardsViewModel.cards.isEmpty ? Color.gray : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(cardsViewModel.cards.isEmpty || isExporting)
                
                if let error = exportError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                if cardsViewModel.cards.isEmpty {
                    Text("Add some cards first to export your data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let shareItem = shareItem {
                ShareSheet(items: [createTemporaryFile(data: shareItem.data, filename: shareItem.filename)])
            }
        }
    }
    
    private func exportData() {
        guard !cardsViewModel.cards.isEmpty else { return }
        
        isExporting = true
        exportError = nil
        
        // Capture cards array on main actor before background processing
        let cards = cardsViewModel.cards
        
        DispatchQueue.global(qos: .userInitiated).async {
            var data: Data?
            var filename: String
            
            switch exportFormat {
            case .json:
                data = exportService.exportAsJSON(cards: cards)
                filename = exportService.generateExportFilename(format: "json")
            case .csvCards:
                data = exportService.exportCardsAsCSV(cards: cards)
                filename = exportService.generateExportFilename(format: "csv-cards")
            case .csvCredits:
                data = exportService.exportCreditsAsCSV(cards: cards)
                filename = exportService.generateExportFilename(format: "csv-credits")
            }
            
            DispatchQueue.main.async {
                isExporting = false
                
                if let data = data {
                    shareItem = ShareItem(data: data, filename: filename)
                    showingShareSheet = true
                } else {
                    exportError = "Failed to export data. Please try again."
                }
            }
        }
    }
    
    private func createTemporaryFile(data: Data, filename: String) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(filename)
        
        try? data.write(to: fileURL)
        return fileURL
    }
}

struct ImportDataView: View {
    @EnvironmentObject var cardsViewModel: CardsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var importService = DataImportService.shared
    @State private var showingDocumentPicker = false
    @State private var isImporting = false
    @State private var importResult: ImportResult?
    @State private var importError: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Import Your Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Import cards and credits from a previously exported file")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    Text("Supported Formats")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        ImportFormatRow(icon: "doc.text", title: "JSON Files", description: "Complete MyCardBook export files")
                        ImportFormatRow(icon: "tablecells", title: "CSV Files", description: "Cards or credits in CSV format")
                    }
                }
                
                Button(action: {
                    showingDocumentPicker = true
                }) {
                    HStack {
                        if isImporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isImporting ? "Importing..." : "Choose File to Import")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isImporting)
                
                if let error = importError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                if case .success(let summary) = importResult {
                    VStack(spacing: 8) {
                        Text("Import Successful!")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("Imported \(summary.cardsImported) cards and \(summary.creditsImported) credits")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if !summary.warnings.isEmpty {
                            Text("\(summary.warnings.count) warnings - check details")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Import Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .fileImporter(isPresented: $showingDocumentPicker, allowedContentTypes: [.json, .commaSeparatedText, .data]) { result in
            handleFileSelection(result)
        }
    }
    
    private func handleFileSelection(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            importFile(from: url)
        case .failure(let error):
            importError = "Failed to select file: \(error.localizedDescription)"
        }
    }
    
    private func importFile(from url: URL) {
        isImporting = true
        importError = nil
        importResult = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard url.startAccessingSecurityScopedResource() else {
                    DispatchQueue.main.async {
                        isImporting = false
                        importError = "Unable to access the selected file"
                    }
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                let data = try Data(contentsOf: url)
                let fileType = importService.detectFileType(data: data)
                
                let result: ImportResult
                switch fileType {
                case "json":
                    result = importService.importFromJSON(data: data)
                case "csv":
                    result = importService.importCardsFromCSV(data: data)
                default:
                    result = .failure(.invalidFormat)
                }
                
                DispatchQueue.main.async {
                    isImporting = false
                    
                    switch result {
                    case .success(let summary):
                        importResult = result
                        // Actually import the cards into the view model
                        cardsViewModel.importCards(summary.importedCards)
                    case .failure(let error):
                        importError = error.localizedDescription
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    isImporting = false
                    importError = "Failed to read file: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct ImportFormatRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("MyCardBook")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Empowering credit card users to maximize their benefits and never let valuable credits expire.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 16) {
                        FeatureRow(icon: "shield", title: "Privacy First", description: "All data stored locally on your device")
                        FeatureRow(icon: "doc.text", title: "Open Source", description: "Complete transparency with public code")
                        FeatureRow(icon: "iphone", title: "iOS Native", description: "Built specifically for iOS users")
                        FeatureRow(icon: "heart", title: "Community Driven", description: "Developed with community feedback")
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}