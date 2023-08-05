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



struct ContentView: View {
    @State var errorMessage: String = ""
    @State var showErrorMessage: Bool = false
    @State var progress: Double? = nil
    @ObservedObject var fileUnzipper = FileUnzipper()
   
    private func unzip(_ urls: [URL]) {
        withAnimation {
            progress = 50
        }
        do {
            print("start unzip")
            try fileUnzipper.unzipFiles(urls)
        }
        catch FileUnzipperError.noFilesProvided {
            errorMessage = "No zip files provided"
            showErrorMessage = true
        }
        catch {
            errorMessage = "There are some errors"
            showErrorMessage = true
        }
        withAnimation {
            print("animation done")
            progress = nil
        }
        print(urls)
    }
    var body: some View {
        ZStack(alignment: .bottom) {
            FilePicker(processUrls: unzip).opacity(fileUnzipper.files.isEmpty ? 1 : 0)
            if showErrorMessage {
                Message(errorMessage: $errorMessage, showErrorMessage: $showErrorMessage).transition(.move(edge: .bottom))
            }
            if fileUnzipper.files.count > 0 {
                if !fileUnzipper.files.allSatisfy({ file in
                    file.fractionCompleted == 1.0
                }) {
                    VStack(spacing: 8) {
                        Spacer()
                        // Text("Working on it...").font(.body)
                        // ProgressView(value: progress, total: 100)
                        ProgressView(value: fileUnzipper.files.reduce(0) {
                            $0 + $1.fractionCompleted * $1.fileSize
                        }, total: fileUnzipper.files.reduce(0) {
                            $0 + $1.fileSize
                        }) {
                            Text("Working on it")
                        }.padding([.leading, .bottom, .trailing], 20.0)
//                        if fileUnzipper.files.indices.count > 0 {
//                            Text(String(fileUnzipper.files.count))
//                            ForEach(0..<fileUnzipper.files.count, id: \.self) { index in
//                                Text(String(fileUnzipper.files[index].fileSize))
//                                Text(String(fileUnzipper.files[index].fractionCompleted))
//                            }
//                            //                        Text("complete" + String(fileUnzipper.unzipProgress!.completedUnitCount))
//                            //                        Text("total" + String(fileUnzipper.unzipProgress!.totalUnitCount))
//                        }
                        Spacer()
                    }
                    
                }
            }
        }.animation(.easeInOut(duration: 0.3), value: showErrorMessage).animation(.easeInOut(duration: 0.3), value: fileUnzipper.files.count)
        
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
