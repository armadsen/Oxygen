//
//  OxygenMonitorController.swift
//  Oxygen
//
//  Created by Andrew Madsen on 7/21/15.
//  Copyright (c) 2015 Open Reel Software. All rights reserved.
//

import Foundation
import ORSSerial
import Observable

struct PulseOxMeasurement {
	var oxygen: Int
	var heartRate: Int
	var timestamp: NSDate
	
	init?(serialPacket: NSData) {
		
		self.oxygen = 0; self.heartRate = 0; self.timestamp = NSDate()
		
		if let string = String(asciiData: serialPacket) as NSString? where
			string.length >= 15 {
				let oxygenString = string.substringWithRange(NSRange(location: 5, length: 3)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
				let heartRateString = string.substringWithRange(NSRange(location: 12, length: 3)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
				
				if let oxygen = oxygenString.toInt(),
					let heartRate = heartRateString.toInt() {
						self.oxygen = oxygen
						self.heartRate = heartRate
						self.timestamp = NSDate()
				} else {
					return nil
				}
		} else {
			return nil
		}
	}
	
	var csvLineRepresentation: String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		let dateString = dateFormatter.stringFromDate(timestamp)
		
		return "\(dateString), \(String(oxygen)), \(String(heartRate))\n"
	}
}

class OxygenMonitorController: NSObject, ORSSerialPortDelegate {
	
	init(_ serialPort: ORSSerialPort) {
		self.serialPort = serialPort
		let desktop = NSURL(fileURLWithPath: "~/Desktop/".stringByExpandingTildeInPath)!
		let dataFileURL = desktop.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("o2d")
		NSFileManager.defaultManager().createFileAtPath(dataFileURL.path!, contents: NSData(), attributes: nil)
		var error: NSError?
		self.dataFileHandle = NSFileHandle(forWritingToURL: dataFileURL, error: &error)
		if self.dataFileHandle == nil {
			println("Unable to open file handle to \(dataFileURL): \(error)")
		}
		
		super.init()
		
		self.writeFileHeader()
		self.configureSerialPort()
	}
	
	deinit {
		self.serialPort = nil
		self.dataFileHandle?.closeFile()
	}
	
	// MARK: - ORSSerialPortDelegate
	
	func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
		self.serialPort = nil
	}
	
	func serialPortWasOpened(serialPort: ORSSerialPort) {
		println("\(serialPort) was opened.")
	}
	
	func serialPort(serialPort: ORSSerialPort, didReceivePacket packetData: NSData, matchingDescriptor descriptor: ORSSerialPacketDescriptor) {
		if let reading = PulseOxMeasurement(serialPacket: packetData) {
			self.mostRecentReading.value = reading
			self.allReadings.value.append(reading)
			self.dataFileHandle?.writeData(reading.csvLineRepresentation.asciiData)
		}
	}
	
	// MARK: - Private
	
	func configureSerialPort() {
		self.serialPort?.delegate = self
		self.serialPort?.baudRate = 9600
		self.serialPort?.numberOfStopBits = 2
		self.serialPort?.open()
		self.installPacketListener()
	}
	
	func installPacketListener() {
		if let port = self.serialPort {
			let prefix = NSData(asciiString: "Sp")
			let suffix = NSData(asciiString: "\r\n")
			let descriptor = ORSSerialPacketDescriptor(prefix: prefix, suffix: suffix, userInfo: nil)
			port.startListeningForPacketsMatchingDescriptor(descriptor)
		}
	}
	
	func writeFileHeader() {
		let data = NSData(asciiString: "Date, O2, HeartRate\n")
		self.dataFileHandle?.writeData(data)
	}
	
	// MARK: - Properties
	
	private(set) var mostRecentReading = Observable<PulseOxMeasurement?>(nil)
	private(set) var allReadings = Observable(Array<PulseOxMeasurement>())
	
	private(set) var serialPort: ORSSerialPort? {
		willSet {
			self.serialPort?.delegate = nil
			self.serialPort?.close()
		}
		didSet {
			self.configureSerialPort()
		}
	}
	
	private let dataFileHandle: NSFileHandle?
}

extension NSData {
	convenience init!(asciiString: String) {
		if let data = asciiString.dataUsingEncoding(NSASCIIStringEncoding) {
			self.init(data: data)
		} else {
			self.init()
			return nil
		}
	}
	
	var asciiString: String {
		return NSString(data: self, encoding: NSASCIIStringEncoding)! as String
	}
}

extension String {
	init!(asciiData: NSData) {
		if let string = NSString(data: asciiData, encoding: NSASCIIStringEncoding) {
			self.init(string)
		} else {
			self.init()
			return nil
		}
	}
	
	var asciiData: NSData {
		return self.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
	}
}
