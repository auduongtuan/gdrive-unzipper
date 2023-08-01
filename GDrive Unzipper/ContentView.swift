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

class FileUnzipper {
    
    public func unzipFile(at: URL, to: URL) {
        let fileManager = FileManager()
        let fileName = at.lastPathComponent
        let fileNameParts = fileName.split(separator: ".")
        if let fileNameNotExt = fileNameParts.first {
            var destinationURL = at.deletingLastPathComponent()
            destinationURL.appendPathComponent(String(fileNameNotExt))
            do {
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                try fileManager.unzipItem(at: at, to: destinationURL)
            } catch {
                print("Extraction of ZIP archive failed with error:\(error)")
            }

        }
    }
    
    public func unzipFiles(_ urls: [URL]) {
        let firstFile = urls[0]
        let fileManager = FileManager()
        var fileNameParts = firstFile.lastPathComponent.components(separatedBy: ".")
        if fileNameParts.last == "zip" {
            fileNameParts.removeLast()
        }
        if fileNameParts.last?.isNumber == true {
            fileNameParts.removeLast()
        }
        let originNewName: String = fileNameParts.joined(separator: "_")
        var newName = originNewName
        if newName.isEmpty == false {
            var destinationURL = firstFile.deletingLastPathComponent()
            destinationURL.appendPathComponent(newName)
            print(newName)
            print(destinationURL)
            do {
                var isdirectory: ObjCBool = true
                var num = 1;
                while(fileManager.fileExists(atPath: destinationURL.path, isDirectory: &isdirectory)) {
                    print("Directory exists")
                    destinationURL = destinationURL.deletingLastPathComponent()
                    num += 1
                    newName = originNewName + "_" + String(num)
                    destinationURL.appendPathComponent(newName)
                }
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                for url in urls {
                    try fileManager.unzipItem(at: url, to: destinationURL)
                }
            } catch {
                print("Extraction of ZIP archive failed with error:\(error)")
            }

        }
    }
}

struct FilePicker: View {
    
    @State var dragOver = false
    
    let fileUnzipper = FileUnzipper()
    
    private func handleDrop(items: [NSItemProvider]) async -> [URL] {
        var urls: [URL] = []
       
        for item in items {
            if let identifier = item.registeredTypeIdentifiers.first {
                print("onDrop with identifier = \(identifier)")
                if identifier == "public.url" || identifier == "public.file-url" {
                    do {
                        let urlData = try await item.loadItem(forTypeIdentifier: identifier) as! Data
                        let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                        urls.append(urll)
                    } catch {
                        print("Error loading item: \(error)")
                    }
                }
            }
        }
        return urls
    }
    var fgColor: Color {
        return self.dragOver ? Color(NSColor.controlAccentColor) : Color(NSColor.controlTextColor)
    }
    var bdColor: Color {
        return self.dragOver ? Color(NSColor.controlAccentColor) : Color(NSColor.controlColor)
    }

    var body: some View {
        VStack(spacing: 16) {
//                Button(action: selectFile) {
            VStack(spacing: 8) {
                Image(systemName: "doc.zipper").foregroundColor(fgColor).font(.largeTitle)
                Text("Select Google Drive zip files or Drag and drop them here...").foregroundColor(self.fgColor).multilineTextAlignment(.center)
                // }.buttonStyle(PlainButtonStyle()).frame(maxHeight: .infinity)
                // https://stackoverflow.com/questions/59008409/swiftui-vstack-hstack-zstack-drag-gesture-not-working
                // https://www.youtube.com/watch?v=yAGTIg7qIak
            }.padding(20)
//            InputImageView(image: self.$image)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).contentShape(Rectangle()).overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(self.bdColor, style: StrokeStyle(lineWidth: 1, dash: [6]))
        ).onTapGesture {
            selectFile()
        }.onDrop(of: ["public.url","public.file-url"], isTargeted: $dragOver) { (items) -> Bool in
            Task {
                let urls = await handleDrop(items: items)
                fileUnzipper.unzipFiles(urls)
                print(urls)
            }
            return true
        }
    }
    
    
    private func selectFile() {
        let openPanel = NSOpenPanel();
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = true;
        openPanel.allowedContentTypes = [.zip];
        openPanel.begin(completionHandler: {(result) -> Void in
            if result == .OK {
                //Do what you will
                //If there's only one URL, surely 'openPanel.URL'
                //but otherwise a for loop works
                fileUnzipper.unzipFiles(openPanel.urls)
            }
        });
    }
}


struct ContentView: View {
    var body: some View {
        VStack {
            FilePicker()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
