//
//  ContentView.swift
//  GDrive Unzip
//
//  Created by Tuan on 31/07/2023.
//

import SwiftUI
import ZIPFoundation

extension Bundle {
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
}

extension String {
    var isNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}
struct GaugeProcesssCircle: View {
    var fractionCompleted: Double
    var strokeColor = Color.accentColor
    var sucessStrokeColor = Color.green
    var bgStrokeColor = Color(NSColor.controlColor)
    var strokeWidth = 10.0
    var body: some View {
        ZStack {
            Circle()
                .stroke(bgStrokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0, to: fractionCompleted)
                .stroke(fractionCompleted.isEqual(to: 1) ? sucessStrokeColor : strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
struct GaugeProgressStyle: ProgressViewStyle {
    
    var textColor = Color(NSColor.controlTextColor)
 

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        return ZStack {
           
            Text(String(format: "%02.0f", fractionCompleted*100)+"%")
                .font(.system(size: 40).monospacedDigit()).fontWeight(.light)
                .padding(25)
                .minimumScaleFactor(0.01).lineLimit(1).foregroundColor(textColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .overlay(
                    GaugeProcesssCircle(fractionCompleted: fractionCompleted)
                )
                .aspectRatio(1, contentMode: .fit)
           
        }
    }
}


struct ContentView: View {
    @State var errorMessageState: MessageState = MessageState(message: "", show: false)
    @ObservedObject var fileUnzipper = FileUnzipper()
    @State var completed: Double = 0
    
    
    private func updateState()
    {
        
    }
   
    private func unzip(_ urls: [URL]) {
        do {
            print("start unzip")
            try fileUnzipper.unzipFiles(urls) { error in
//                fileUnzipper.clearFiles()
                errorMessageState.message = "Cannot unzip. Please try again"
                errorMessageState.show = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.fileUnzipper.clearFiles()
                }
            }
        }
        catch FileUnzipperError.noFilesProvided {
            errorMessageState.message = "No .zip files provided"
            errorMessageState.show = true
        }
        catch {
            errorMessageState.message = "There are some errors. Try again"
            errorMessageState.show = true
        }
        withAnimation {
            print("animation done")
        }
    }
    var body: some View {
        ZStack(alignment: .bottom) {
            FilePicker(processUrls: unzip).opacity(fileUnzipper.files.isEmpty ? 1 : 0).disabled(!fileUnzipper.files.isEmpty)
//            ProgressView(value: 0.5).progressViewStyle(GaugeProgressStyle()).padding(20)
            if fileUnzipper.files.count > 0 {
                    ProgressView(value: completed).progressViewStyle(GaugeProgressStyle()).padding(10).onReceive(self.fileUnzipper.$files) {
                            let sizeCompleted = $0.reduce(0) {
                                $0 + $1.fractionCompleted * Double($1.fileSize)
                            }
                            let sizeTotal = $0.reduce(0) {
                                $0 + Double($1.fileSize)
                            }
                            self.completed = sizeCompleted / sizeTotal
                            if(self.completed.isEqual(to: 1)) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.fileUnzipper.clearFiles()
                                }
                            }
                    }
            }
            if errorMessageState.show {
                Message(state: $errorMessageState).transition(.move(edge: .bottom))
            }
        }.animation(.easeInOut(duration: 0.3), value: errorMessageState.show).animation(.easeInOut(duration: 0.3), value: fileUnzipper.files.count)
        
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
