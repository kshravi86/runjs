import Foundation
import JavaScriptCore

class JSEngine: ObservableObject {
    @Published var output: String = ""
    private let jsContext: JSContext

    init() {
        jsContext = JSContext()!
        print("[JSEngine] Initialized JSContext: \(jsContext)")
        // Capture JS exceptions and surface them to the console output
        jsContext.exceptionHandler = { [weak self] context, exception in
            let message = exception?.toString() ?? "Unknown JS exception"
            DispatchQueue.main.async {
                self?.output += "[ERROR] " + message + "\n"
            }
            print("[JSEngine] JS Exception: \(message)")
        }
        setupConsoleLog()
    }

    private func setupConsoleLog() {
        // Create a custom 'console' object in the JS context
        print("[JSEngine] Setting up console bindings (log, warn, error)")

        let consoleLog: @convention(block) (String) -> Void = { [weak self] message in
            DispatchQueue.main.async {
                self?.output += "[LOG] " + message + "\n"
            }
            print("[console.log] \(message)")
        }

        let consoleWarn: @convention(block) (String) -> Void = { [weak self] message in
            DispatchQueue.main.async {
                self?.output += "[WARN] " + message + "\n"
            }
            print("[console.warn] \(message)")
        }

        let consoleError: @convention(block) (String) -> Void = { [weak self] message in
            DispatchQueue.main.async {
                self?.output += "[ERROR] " + message + "\n"
            }
            print("[console.error] \(message)")
        }

        let console = JSValue(newObjectIn: jsContext)
        console?.setObject(unsafeBitCast(consoleLog, to: AnyObject.self), forKeyedSubscript: "log" as NSCopying & NSObjectProtocol)
        console?.setObject(unsafeBitCast(consoleWarn, to: AnyObject.self), forKeyedSubscript: "warn" as NSCopying & NSObjectProtocol)
        console?.setObject(unsafeBitCast(consoleError, to: AnyObject.self), forKeyedSubscript: "error" as NSCopying & NSObjectProtocol)
        jsContext.setObject(console, forKeyedSubscript: "console" as NSCopying & NSObjectProtocol)
    }

    func execute(code: String) {
        // Clear previous output
        output = ""
        print("[JSEngine] Executing JS (\(code.count) chars)")

        // Execute the code
        let result = jsContext.evaluateScript(code)

        // Append the result of the last expression, if any
        if let result = result, !result.isUndefined, !result.isNull, let text = result.toString() {
            output += "=> " + text + "\n"
            print("[JSEngine] Result: \(text)")
        } else {
            print("[JSEngine] No result (undefined/null)")
        }
    }
}
