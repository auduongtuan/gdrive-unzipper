//
//  FilePicker.swift
//  GDrive Unzipper
//
//  Created by Tuan on 02/08/2023.
//

import Foundation
import SwiftUI

struct FilePicker: View {
    
    @State var dragOver = false
    @State var urls: [URL] = []
    
    let processUrls: ((_ urls: [URL]) -> Void)?
    
    var completion: (() -> Void)?
    
    private func handleDrop(items: [NSItemProvider]) -> [URL] {
        let dispatchGroup = DispatchGroup()
        urls = []
        items.forEach { item in
            dispatchGroup.enter()
            _ = item.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    if(url.pathExtension == "zip") {
                        urls.append(url)
                    }
                    dispatchGroup.leave()
                }
            }
 
        }
        dispatchGroup.wait()
        print("urls")
        print(urls)
        return urls
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
//                DispatchQueue.global().async {
                    processUrls!(urls)
//                    DispatchQueue.main.async {
//                        if (completion != nil) {
//                            completion!()
//                        }
//                    }
//                }
            }
        });
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
                Text("Select Google Drive zip files or drop them here...").foregroundColor(self.fgColor).multilineTextAlignment(.center)
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
//            Task {
                let urls = handleDrop(items: items)
//                DispatchQueue.global().async {
                    processUrls!(urls)
//                    DispatchQueue.main.async {
//                        if (completion != nil) {
//                            completion!()
//                        }
//                    }
//                }
//            }
            return true
        }
    }
    
    
  
}
