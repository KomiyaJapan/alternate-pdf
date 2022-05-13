//
//  main.swift
//  alternatepdf
//
//  Created by Yoshihiro Saigusa on 2022/05/13.
//

import PDFKit

let oddFile : URL
let evenFile : URL

if CommandLine.arguments.count == 3 {
    oddFile = URL(fileURLWithPath: CommandLine.arguments[1])
    evenFile = URL(fileURLWithPath:CommandLine.arguments[2])
} else {
    print("Usage: alternatepdf <odd-page> <even-page>")
    exit(1)
}

guard var oddpdf = PDFDocument(url: oddFile) else {
    print("Source file \(oddFile) cannot be opened, exiting")
    exit(1)
}
guard var evenpdf = PDFDocument(url: evenFile) else {
    print("Source file \(evenFile) cannot be opened, exiting")
    exit(1)
}

let infoDict = ["kCGPDFContextCreator" : "alternatepdf" ] as CFDictionary

let output = PDFDocument()

let outFile = FileManager().temporaryDirectory.appendingPathComponent("alternated-\(oddFile.lastPathComponent)")

var page = 0
if oddpdf.pageCount >= evenpdf.pageCount{
    for odd in 0...(oddpdf.pageCount-1){
        output.insert(oddpdf.page(at: odd)!, at: output.pageCount)
        if let even = evenpdf.page(at: odd){
            output.insert(even, at: output.pageCount)
        } else {
            print("Page \(odd+1) of even page cannot be found, skipping...")
        }
    }
} else {
    for even in 0...(evenpdf.pageCount-1){
        if let odd = oddpdf.page(at: even){
            output.insert(odd, at: output.pageCount)
        } else {
            print("Page \(even+1) of odd page cannot be found, skipping...")
        }
        output.insert(evenpdf.page(at: even)!, at: output.pageCount)
    }
}
output.write(to: outFile)

if !NSWorkspace.shared.open(outFile) {
    print("Destination file \(outFile) cannot be opened, exiting")
    exit(1)
}
