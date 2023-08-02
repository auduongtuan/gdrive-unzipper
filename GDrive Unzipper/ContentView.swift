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
    let fileUnzipper = FileUnzipper()

    private func unzip(_ urls: [URL]) {
        withAnimation {
            progress = 50
        }
        do {
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
            print("done")
            progress = nil
        }
        print(urls)
    }
    var body: some View {
        ZStack(alignment: .bottom) {
            FilePicker(processUrls: unzip, completion: {
                progress = nil
            }).opacity(progress == nil ? 1 : 0)
            if showErrorMessage {
                Message(errorMessage: $errorMessage, showErrorMessage: $showErrorMessage).transition(.move(edge: .bottom))
            }
            if progress != nil {
                VStack(spacing: 8) {
                    Spacer()
                    // Text("Working on it...").font(.body)
                    // ProgressView(value: progress, total: 100).padding([.leading, .bottom, .trailing], 20.0)
                    ProgressView("Working on it...")
                    Spacer()
                }
              
            }
        }.animation(.easeInOut(duration: 0.3), value: showErrorMessage)
        
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
