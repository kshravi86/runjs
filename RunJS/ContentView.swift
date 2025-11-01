import SwiftUI
import UIKit

struct ContentView: View {
    private struct SampleScript: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let code: String
    }
    
    @StateObject private var engine = JSEngine()
    @State private var codeInput: String = "console.log('Hello, Run JS!');\n1 + 1;"
    @FocusState private var isEditorFocused: Bool
    
    private let sampleScripts: [SampleScript] = [
        .init(
            title: "Console",
            subtitle: "Log a greeting",
            code: "console.log('Hello from RunJS!');"
        ),
        .init(
            title: "Math",
            subtitle: "Use built-in Math API",
            code: """
            const values = [3, 5, 9, 12];
            const avg = values.reduce((acc, value) => acc + value, 0) / values.length;
            console.log(`Average value: ${avg}`);
            """
        ),
        .init(
            title: "Async",
            subtitle: "Await a promise",
            code: """
            const wait = (ms) => new Promise(resolve => setTimeout(resolve, ms));
            await wait(500);
            console.log('Async work finished!');
            """
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                VStack(spacing: 24) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            header
                            sampleLibrary
                            codeEditorCard
                            consoleCard
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)
                    }

                    controlBar
                }
            }
            .navigationTitle("Run JS")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.09, green: 0.11, blue: 0.21),
                Color(red: 0.05, green: 0.05, blue: 0.09)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instant JavaScript Scratchpad")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text("Write snippets, execute them on-device, and inspect console output without leaving your flow.")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var sampleLibrary: some View {
        Group {
            Text("Quick Samples")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sampleScripts) { script in
                        Button {
                            codeInput = script.code
                            engine.output = ""
                            isEditorFocused = true
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(script.title)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(script.subtitle)
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .frame(width: 140, alignment: .leading)
                            .padding()
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var codeEditorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Code Editor", systemImage: "terminal.fill")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    UIPasteboard.general.string = codeInput
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.borderless)
                .labelStyle(.iconOnly)
                .tint(.white.opacity(0.7))
                .accessibilityLabel("Copy code to clipboard")
            }

            ZStack(alignment: .topLeading) {
                if codeInput.isEmpty {
                    Text("Write or paste JavaScript here...")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.top, 8)
                }

                TextEditor(text: $codeInput)
                    .focused($isEditorFocused)
                    .scrollContentBackground(.hidden)
                    .font(.system(.body, design: .monospaced))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .frame(minHeight: 220, idealHeight: 260)
                    .padding(8)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding()
        .glassCard()
    }

    private var consoleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Console Output", systemImage: "waveform.path.ecg")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                if !engine.output.isEmpty {
                    Button {
                        engine.output = ""
                    } label: {
                        Label("Clear Output", systemImage: "trash")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.borderless)
                    .labelStyle(.titleAndIcon)
                    .tint(.white.opacity(0.7))
                }
            }

            ScrollView {
                Text(engine.output.isEmpty ? "Output will appear here after executing your script." : engine.output)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(engine.output.isEmpty ? .white.opacity(0.4) : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding()
            }
            .frame(minHeight: 160, maxHeight: 220)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding()
        .glassCard()
    }

    private var controlBar: some View {
        HStack(spacing: 12) {
            Button {
                codeInput = ""
                engine.output = ""
                isEditorFocused = true
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .font(.callout.weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white.opacity(0.12))
            .foregroundStyle(.white)

            Button {
                engine.execute(code: codeInput)
            } label: {
                Label("Run", systemImage: "play.fill")
                    .font(.callout.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.38, green: 0.58, blue: 0.98))
            .foregroundStyle(.white)
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
        .background(
            Color.white.opacity(0.02)
                .blur(radius: 0)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

private extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}

private struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.35), radius: 40, y: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
    }
}

#Preview {
    ContentView()
}
