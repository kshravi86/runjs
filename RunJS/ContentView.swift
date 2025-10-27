import SwiftUI

struct ContentView: View {
    @StateObject private var engine = JSEngine()
    @State private var codeInput: String = "console.log('Hello, Run JS!');\n1 + 1;"

    var body: some View {
        VStack(spacing: 0) {
            // Code Input Area
            TextEditor(text: $codeInput)
                .font(.system(.body, design: .monospaced))
                .frame(height: 200)
                .border(Color.gray)
                .padding([.horizontal, .top])

            // Run Button
            Button("Run Code") {
                engine.execute(code: codeInput)
            }
            .padding()
            .buttonStyle(.borderedProminent)

            // Output Area
            ScrollView {
                Text(engine.output)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.black.opacity(0.05))
            }
            .border(Color.gray)
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("Run JS Interpreter")
    }
}

#Preview {
    ContentView()
}