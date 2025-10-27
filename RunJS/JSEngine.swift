import Foundation
import JavaScriptCore

class JSEngine: ObservableObject {
    @Published var output: String = ""
    private let jsContext: JSContext

    init() {
        jsContext = JSContext()!
        setupConsoleLog()
    }

    private func setupConsoleLog() {
        // Create a custom 'console' object in the JS context
        let consoleLog: @convention(block) (String) -> Void = { [weak self] message in
            DispatchQueue.main.async {
                self?.output += message + "\n"
            }
        }
        
        let console = JSValue(newObjectIn: jsContext)
        console?.setObject(unsafeBitCast(consoleLog, to: AnyObject.self), forKeyedSubscript: "console" as NSCopying & NSObjectProtocol)
        jsContext.setObject(console, forKeyedSubscript: "console" as NSCopying & NSObjectProtocol)
    }

    func execute(code: String) {
        // Clear previous output
        output = ""
        
        // Execute the code
        let result = jsContext.evaluateScript(code)
        
        // Append the result of the last expression, if any
        if !result!.isUndefined && !result!.isNull {
            output += "=> " + result!.toString()! + "\n"
        }
    }
}
