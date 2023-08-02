//
//  FileUnzipper.swift
//  GDrive Unzipper
//
//  Created by Tuan on 02/08/2023.
//

import Foundation

enum FileUnzipperError: Error {
    case noFilesProvided
    case filesNotFound
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
    
    public func unzipFiles(_ urls: [URL]) throws {
        if(urls.count == 0) {
            throw FileUnzipperError.noFilesProvided
        };
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
