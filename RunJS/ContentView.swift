import SwiftUI

struct ContentView: View {
    @StateObject private var engine = JSEngine()
    @State private var codeInput: String = "console.log('Hello, Run JS!');\n1 + 1;"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Code Input Area
                TextEditor(text: $codeInput)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden) // Hide default background
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding([.horizontal, .top])
                    .frame(maxHeight: .infinity)
                
                Divider()
                
                // MARK: - Output Console Area
                VStack(alignment: .leading, spacing: 4) {
                    Text("Console Output")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ScrollView {
                        Text(engine.output)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .textSelection(.enabled)
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding([.horizontal, .bottom])
                }
                .frame(height: 200) // Fixed height for console
            }
            .navigationTitle("Run JS Interpreter")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Clear") {
                        print("[UI] Clear tapped: clearing code and output")
                        codeInput = ""
                        engine.output = ""
                    }
                    
                    Button {
                        print("[UI] Run tapped: executing code (\(codeInput.count) chars)")
                        engine.execute(code: codeInput)
                    } label: {
                        Label("Run", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                print("[UI] ContentView appeared")
            }
        }
    }
}

#Preview {
    ContentView()
}
