import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var p
    @State private var draft = ""
    @FocusState private var focused: Bool

    private let chips = ["chat.chip.color", "chat.chip.city", "chat.chip.vastu", "chat.chip.dasha"]

    var body: some View {
        ZStack {
            p.bgCanvas.ignoresSafeArea()
            VStack(spacing: 0) {
                SacredHeader(devanagari: "पण्डितजी", title: app.t("chat.title"))
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            if app.chat.isEmpty { welcome }
                            ForEach(app.chat) { msg in
                                bubble(msg)
                                    .id(msg.id)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    }
                    .onChange(of: app.chat.count) {
                        if let last = app.chat.last {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                chipsRow
                inputBar
            }
        }
    }

    private var welcome: some View {
        VStack(spacing: 12) {
            ZStack {
                MandalaView().frame(width: 170, height: 170).opacity(0.7)
                DiyaFlame(size: 40)
            }
            Text(PanditBrain(family: app.family, lang: app.language).reply(to: "namaste"))
                .font(.system(size: 16, design: .serif))
                .foregroundStyle(p.inkPrimary.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(16)
                .sacredCard(tika: true)
        }
        .padding(.top, 12)
    }

    private func bubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.isUser { Spacer(minLength: 48) }
            Text(msg.text)
                .font(.system(size: 16, design: msg.isUser ? .default : .serif))
                .foregroundStyle(p.inkPrimary)
                .lineSpacing(4)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(msg.isUser ? p.marigold.opacity(0.22) : p.bgElevated))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(msg.isUser ? p.saffron.opacity(0.35) : p.templeGold.opacity(0.25), lineWidth: 1))
            if !msg.isUser { Spacer(minLength: 48) }
        }
    }

    private var chipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips, id: \.self) { key in
                    Button {
                        app.sendChat(app.t(key))
                    } label: {
                        Text(app.t(key))
                            .font(.system(size: 13))
                            .foregroundStyle(p.sindoor)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(Capsule().fill(p.bgElevated))
                            .overlay(Capsule().strokeBorder(p.templeGold.opacity(0.35), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField(app.t("chat.placeholder"), text: $draft, axis: .vertical)
                .font(.system(size: 16))
                .focused($focused)
                .lineLimit(1...4)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 22).fill(p.bgElevated))
                .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(p.templeGold.opacity(0.3), lineWidth: 1))
            Button {
                let text = draft
                draft = ""
                app.sendChat(text)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(draft.trimmingCharacters(in: .whitespaces).isEmpty ? p.inkSecondary.opacity(0.4) : p.saffron)
            }
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityLabel("Send")
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
