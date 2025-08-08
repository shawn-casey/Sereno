import SwiftUI

struct ModernToolbar: View {
    let onStyleSelected: (TextStyle) -> Void
    @Binding var isVisible: Bool
    @State private var hoveredButton: TextStyle?
    
    private let styles: [TextStyle] = [
        .bold, .italic, .underline,
        .code, .header(level: 1),
        .link(url: URL(string: "https://")!),
        .bulletList
    ]
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(styles, id: \.systemImage) { style in
                Button(action: { onStyleSelected(style) }) {
                    VStack(spacing: 2) {
                        Image(systemName: style.systemImage)
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: 28, height: 28)
                        
                        Text(style.shortcut)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(hoveredButton == style ? 
                              Color(NSColor.selectedControlColor) : 
                              Color.clear)
                )
                .onHover { isHovered in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        hoveredButton = isHovered ? style : nil
                    }
                }
                
                if style == .underline || style == .header(level: 1) {
                    Divider()
                        .frame(height: 24)
                        .padding(.horizontal, 4)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .cornerRadius(8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.95)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}