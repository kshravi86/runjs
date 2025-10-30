import Foundation
import JavaScriptCore

class JSEngine: ObservableObject {
    @Published var output: String = ""
    private var jsContext: JSContext

    init() {
        jsContext = JSContext()!
        configureContext()
    }

    private func setupConsoleLog() {
        // Create a custom 'console' object in the JS context with multi-arg support
        print("[JSEngine] Setting up console bindings (log, warn, error) with multi-arg support")

        let makeLogger: (_ level: String) -> AnyObject = { [weak self] level in
            let block: @convention(block) () -> Void = {
                guard let self = self else { return }
                let argsAny = JSContext.currentArguments() ?? []
                let args: [String] = argsAny.compactMap { anyVal in
                    if let v = anyVal as? JSValue { return self.formatJSValue(v) }
                    return String(describing: anyVal)
                }
                let line = "[\(level.uppercased())] " + args.joined(separator: " ")
                DispatchQueue.main.async { [weak self] in
                    self?.output += line + "\n"
                }
                print("[console.\(level)] \(args.joined(separator: " "))")
            }
            return unsafeBitCast(block, to: AnyObject.self)
        }

        let console = JSValue(newObjectIn: jsContext)
        console?.setObject(makeLogger("log"), forKeyedSubscript: "log" as NSCopying & NSObjectProtocol)
        console?.setObject(makeLogger("warn"), forKeyedSubscript: "warn" as NSCopying & NSObjectProtocol)
        console?.setObject(makeLogger("error"), forKeyedSubscript: "error" as NSCopying & NSObjectProtocol)
        jsContext.setObject(console, forKeyedSubscript: "console" as NSCopying & NSObjectProtocol)
    }

    func execute(code: String) {
        // Clear previous output
        output = ""
        print("[JSEngine] Executing JS (\(code.count) chars)")

        // Execute the code
        let result = jsContext.evaluateScript(code)

        // Append the result of the last expression, if any
        if let result = result, !result.isUndefined, !result.isNull {
            let text = formatJSValue(result)
            output += "=> " + text + "\n"
            print("[JSEngine] Result: \(text)")
        } else {
            print("[JSEngine] No result (undefined/null)")
        }
    }

    func resetContext() {
        print("[JSEngine] Resetting JSContext")
        jsContext = JSContext()!
        configureContext()
        DispatchQueue.main.async { [weak self] in
            self?.output = ""
        }
    }

    private func configureContext() {
        print("[JSEngine] Initialized JSContext: \(jsContext)")
        jsContext.exceptionHandler = { [weak self] _, exception in
            let message = exception?.toString() ?? "Unknown JS exception"
            DispatchQueue.main.async {
                self?.output += "[ERROR] " + message + "\n"
            }
            print("[JSEngine] JS Exception: \(message)")
        }
        setupConsoleLog()
    }

    private func formatJSValue(_ value: JSValue) -> String {
        if value.isNull { return "null" }
        if value.isUndefined { return "undefined" }
        if value.isBoolean { return value.toBool() ? "true" : "false" }
        if value.isNumber { return value.toNumber()?.stringValue ?? value.toString() ?? "NaN" }
        if value.isString { return value.toString() ?? "" }

        // Try JSON.stringify for objects/arrays; fall back to toString()
        if let json = jsContext.objectForKeyedSubscript("JSON")?.objectForKeyedSubscript("stringify")?.call(withArguments: [value]),
           !json.isUndefined, !json.isNull, let s = json.toString(), !s.isEmpty {
            return s
        }
        return value.toString() ?? "[object]"
    }
}
