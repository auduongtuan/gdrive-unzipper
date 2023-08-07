//
//  FileUnzipper.swift
//  GDrive Unzipper
//
//  Created by Tuan on 02/08/2023.
//

import Foundation
import ZIPFoundation

enum FileUnzipperError: Error {
    case noFilesProvided
    case filesNotFound
    case unzipFailed
}

extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }
    }
}

func getFileSize(url: URL?) -> UInt64 {
    guard let filePath = url?.path else {
        return 0
    }
    do {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
        if let fileSize = fileAttributes[FileAttributeKey.size]  {
            return (fileSize as! NSNumber).uint64Value
        } else {
            print("Failed to get a size attribute from path: \(filePath)")
        }
    } catch {
        print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
    }
    return 0
}

func json(from object:Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return nil
    }
    return String(data: data, encoding: String.Encoding.utf8)
}

struct UnzipFile {
    var fileSize: UInt64
    var fractionCompleted: Double
}

class FileUnzipper: ObservableObject {
//    @objc var unzipProgress: Progress?
    @Published var files = [UnzipFile]()
    
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
    public func getFolderName(_ fileName: String) -> String {
        print("file name start")
        let matches = fileName.matchingStrings(regex: "(.*?)(-[0-9]{3})?.zip")
        if(matches.count > 0 && matches[0].count > 0) {
            return matches[0][1]
        }
        else {
            return fileName;
        }
//        if fileNameParts.last == "zip" {
//            fileNameParts.removeLast()
//        }
//        if fileNameParts.last?.isNumber == true && fileNameParts.count > 1 {
//            fileNameParts.removeLast()
//        }
//        let originNewName: String = fileNameParts.joined(separator: "_")
//        var newName = originNewName
//        print(newName)
    }
    public func clearFiles() {
        DispatchQueue.main.async {
            self.files.removeAll();
        }
    }
    public func addFileInfo(_ urls: [URL]) {
        for url in urls {
            let file = UnzipFile(fileSize: getFileSize(url: url), fractionCompleted: 0.0)
            files.append(file)
        }
    }
    public func updateProgress(index: Int, fractionCompleted: Double) {
        DispatchQueue.main.async {
            self.files[index].fractionCompleted = fractionCompleted
        }
    }
    public func unzipFiles(_ urls: [URL], onError: ((Error?)->())?) throws {
        if(urls.count == 0) {
            throw FileUnzipperError.noFilesProvided
        };
        let firstFile = urls[0]
        let fileManager = FileManager()
        let originNewName: String = getFolderName(firstFile.lastPathComponent);
        var newName = originNewName
        print(newName)
        if newName.isEmpty == false {
            var destinationURL = firstFile.deletingLastPathComponent()
            destinationURL.appendPathComponent(newName)
            print(newName)
            print(destinationURL)
            do {
                addFileInfo(urls)
                var isdirectory: ObjCBool = true
                var num = 1;
                print("Folder url " + destinationURL.absoluteString)
                while(fileManager.fileExists(atPath: destinationURL.path, isDirectory: &isdirectory)) {
                    print("Directory exists")
                    destinationURL = destinationURL.deletingLastPathComponent()
                    num += 1
                    newName = originNewName + "_" + String(num)
                    destinationURL.appendPathComponent(newName)
                }
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                
                DispatchQueue.global(qos: .background).async {
                    for index in urls.indices {
                        let url = urls[index]
                        let _unzipProgress = Progress()
                        let observation = _unzipProgress.observe(\.fractionCompleted) { progress, _ in
                            self.updateProgress(index: index, fractionCompleted: progress.fractionCompleted)
                        }
                        print("unzip "+url.absoluteString)
                        let archive = Archive(url: url, accessMode: .update)
                        for entry in archive! {
                            if(entry.path.contains(".DS_Store")) {
                                print("remove .DS_Store " + entry.path)
                                try? archive?.remove(entry)
                            }
                        }
                        do {
                            try fileManager.unzipItem(at: url, to: destinationURL, skipCRC32: true, progress: _unzipProgress)
                        }
                        catch {
                            print(error)
                            if let callableOnError = onError {
                                callableOnError(error)
                            }
                        }
                        observation.invalidate()
                    }
//                    self.clearFiles();
                }
            } catch {
                print("Extraction of ZIP archive failed with error:\(error)")
                throw FileUnzipperError.unzipFailed
            }


        }
    }
}
