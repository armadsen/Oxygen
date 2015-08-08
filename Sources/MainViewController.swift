//
//  ViewController.swift
//  Oxygen
//
//  Created by Andrew Madsen on 7/21/15.
//  Copyright (c) 2015 Open Reel Software. All rights reserved.
//

import Cocoa
import ORSSerial
import Observable
import CorePlot

class MainViewController: NSViewController, CPTPlotDataSource {
	
	private let monitorController = OxygenMonitorController(ORSSerialPort(path: "/dev/cu.KeySerial1")!)
	
	override func viewDidLoad() {
		self.monitorController.allReadings.afterChange.add(owner: self) { (_) in
			if let reading = self.monitorController.allReadings.value.last {
				self.oxygenLabel.stringValue = String(reading.oxygen)
				self.heartRateLabel.stringValue = String(reading.heartRate)
			}
			
		}
		
		let graph = CPTXYGraph(frame: self.graphView.bounds, xScaleType: .Linear, yScaleType: .Linear)
		self.oxygenPlot = CPTScatterPlot(frame: graph.bounds)
		self.oxygenPlot?.dataSource = self
		graph.addPlot(oxygenPlot)
		self.graphView.hostedGraph = graph
	}
	
	// MARK: - CPTPlotDataSource
	
	func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
		return UInt(self.monitorController.allReadings.value.count)
	}
	
//	func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {		
//		switch let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) {
//		case .X:
//			return idx + 1
//		case .Y:
//			let readings = self.monitorController.allReadings.value
//			return readings[idx].oxygen
//		}
//		return nil
//	}
	
	// MARK: - Properties
	
	private var oxygenPlot: CPTScatterPlot?
	
	@IBOutlet weak var oxygenLabel: NSTextField!
	@IBOutlet weak var heartRateLabel: NSTextField!
	@IBOutlet weak var graphView: CPTGraphHostingView!
}

