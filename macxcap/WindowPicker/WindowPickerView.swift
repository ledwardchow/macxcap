import SwiftUI
import AppKit

struct WindowPickerView: View {
    @StateObject private var vm = WindowPickerViewModel()
    var title: String
    var onSelect: (WindowInfo) -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 0) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 12)

                if vm.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Spacer()
                } else if vm.windows.isEmpty {
                    Spacer()
                    Text("No capturable windows found")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 260, maximum: 340))],
                            spacing: 12
                        ) {
                            ForEach(vm.windows) { item in
                                WindowThumbnailCell(item: item)
                                    .onTapGesture { onSelect(item) }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .onAppear { vm.load() }
        .background(
            Button("") { onCancel() }
                .keyboardShortcut(.escape, modifiers: [])
                .hidden()
        )
    }
}

struct WindowThumbnailCell: View {
    let item: WindowInfo
    @State private var hovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                if let thumb = item.thumbnail {
                    Image(nsImage: thumb)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                    Image(systemName: "rectangle.dashed")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100, maxHeight: 160)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(hovered ? Color.white.opacity(0.8) : Color.white.opacity(0.15),
                            lineWidth: hovered ? 2 : 1)
            )
            .clipped()

            Text(item.ownerName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)

            if !item.title.isEmpty {
                Text(item.title)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .padding(10)
        .background(Color.white.opacity(hovered ? 0.15 : 0.07))
        .cornerRadius(10)
        .contentShape(Rectangle())
        .onHover { hovered = $0 }
    }
}
