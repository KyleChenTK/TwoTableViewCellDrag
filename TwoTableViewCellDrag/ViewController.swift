//
//  ViewController.swift
//  TwoTableViewCellDrag
//
//  Created by Kyle Chen on 2022/6/13.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var tableViewA: NSTableView!
    
    @IBOutlet weak var tableViewB: NSTableView!

    let registeredType = NSPasteboard.PasteboardType.string
    var groupA: [String] = ["Apple", "Banana", "Grape", "Peach"]
    var groupB: [String] = ["Gomi", "Hoge", "Piyo"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewA.delegate = self
        tableViewB.delegate = self
        tableViewA.dataSource = self
        tableViewB.dataSource = self
        
        tableViewA.registerForDraggedTypes([registeredType])
        tableViewB.registerForDraggedTypes([registeredType])

        tableViewA.reloadData()
        tableViewB.reloadData()
    }

}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if tableView === tableViewA {
            return groupA.count
        } else if tableView === tableViewB {
            return groupB.count
        }
        return 0
    }

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView
        if tableView === tableViewA {
            cell?.textField?.stringValue = groupA[row]
        } else if tableView === tableViewB {
            cell?.textField?.stringValue = groupB[row]
        }
        return cell
    }

    // drag & drop
    func tableView(_ tableView: NSTableView,
                   validateDrop info: NSDraggingInfo,
                   proposedRow row: Int,
                   proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        guard let source = info.draggingSource as? NSTableView else{ return [] }
        
        if source == tableViewA && tableView == tableViewB || source == tableViewB && tableView == tableViewA {
            
            if dropOperation == .on {
                return NSDragOperation.move
            }
            
        }
        
        else {
            
            if dropOperation == .above {
                return NSDragOperation.move
            }
            
        }
        
        return []
        
    }

    func tableView(_ tableView: NSTableView,
                   writeRowsWith rowIndexes: IndexSet,
                   to pboard: NSPasteboard) -> Bool {
        guard tableView === tableViewA || tableView === tableViewB else {
            return false
        }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: rowIndexes,
                                                        requiringSecureCoding: false)
            pboard.declareTypes([registeredType], owner: self)
            pboard.setData(data, forType: registeredType)
            return true
        } catch {
            Swift.print(error.localizedDescription)
        }
        return false
    }

    func tableView(_ tableView: NSTableView,
                   acceptDrop info: NSDraggingInfo,
                   row: Int,
                   dropOperation: NSTableView.DropOperation) -> Bool {
        let pboard = info.draggingPasteboard
        guard
            let data = pboard.data(forType: registeredType),
            let rowIndexes = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? IndexSet,
            let source = info.draggingSource as? NSTableView,
            let sourceRow = rowIndexes.min()
            else { return false }
        let targetIndexes = rowIndexes.sorted()
        var tmp = [String]()
        let beforeCount = targetIndexes.filter({ (n) -> Bool in
            return n < row
        }).count
        if source == tableViewA && tableView == tableViewB {
            
            print(groupA[sourceRow])
//            let value = groupA[sourceRow]
//            groupA.remove(at: sourceRow)
//            groupB.insert(value, at: row)
        }
        if source == tableViewB && tableView == tableViewA {
            print(groupB[sourceRow])
//            let value = groupB[sourceRow]
//            groupB.remove(at: sourceRow)
//            groupA.insert(value, at: row)
        }
        
        if source == tableViewA && tableView == tableViewA {
            let value = groupA[sourceRow]
            var newRow = row
            if sourceRow < newRow {
                newRow = row - 1
            }
            groupA.remove(at: sourceRow)
            groupA.insert(value, at: newRow)
            
        }
        if source == tableViewB && tableView == tableViewB {
            let value = groupB[sourceRow]
            var newRow = row
            if sourceRow < newRow {
                newRow = row - 1
            }
            groupB.remove(at: sourceRow)
            groupB.insert(value, at: newRow)
        }
        
        tableViewA.reloadData()
        tableViewB.reloadData()
        return true
    }

}
