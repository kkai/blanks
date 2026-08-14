import SwiftUI

/// The About screen. Unlike the game screen (a frozen 4.3 replica), this
/// screen keeps the legacy identity — optionback paper, Iowan Old Style,
/// black bar — but is built as a modern flowing layout: Dynamic Type,
/// proper hit targets, readable license.
struct LegacyAboutView: View {
    let config: SKUConfig

    @Environment(\.dismiss) private var dismiss
    @AppStorage("TappingUI") private var isTapping = false
    @State private var showTipJar = false

    private static let headerFont = Font.custom("IowanOldStyle-Italic", size: 22, relativeTo: .title3)
    private static let bodyFont = Font.custom("IowanOldStyle-Roman", size: 17, relativeTo: .body)
    private static let footFont = Font.custom("IowanOldStyle-Roman", size: 12, relativeTo: .footnote)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    modeSection
                    if config.isBlanksSKU {
                        moreWordsSection
                        supportSection
                    } else {
                        Text("Thank you for your support!")
                            .font(Self.headerFont)
                    }
                    licenseSection
                }
                .foregroundStyle(.black)
                .padding(20)
                .padding(.bottom, 40)
            }
            .background {
                // The art carries a printed-text texture; faded so it
                // reads as paper grain instead of competing copy.
                ZStack {
                    Color.white
                    Image(decorative: "optionback")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.22)
                }
                .ignoresSafeArea()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .tint(.white)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .sheet(isPresented: $showTipJar) {
            TipJarView()
        }
    }

    private var modeSection: some View {
        Toggle("Tap words instead of dragging", isOn: $isTapping)
            .font(Self.bodyFont)
            .tint(.black.opacity(0.75))
    }

    private var moreWordsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("More Words")
                .font(Self.headerFont)
            Text("Get more words with More Blanks.")
                .font(Self.bodyFont)
            Link("Get More Blanks on the App Store",
                 destination: URL(string: "https://apps.apple.com/app/moreblanks/id288808376")!)
                .font(Self.bodyFont.bold())
                .frame(minHeight: 44, alignment: .leading)
            Text("New features are coming — stay tuned!")
                .font(Self.footFont)
                .foregroundStyle(.black.opacity(0.6))
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Support")
                .font(Self.headerFont)
            Text("Enjoying Blanks? Support development with a small tip.")
                .font(Self.bodyFont)
            Button("Buy Me a Coffee") {
                showTipJar = true
            }
            .font(Self.bodyFont.bold())
            .frame(minHeight: 44, alignment: .leading)
        }
    }

    private var licenseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("License")
                .font(Self.headerFont)
            Text("Word definitions from WordNet 3.0, Princeton University. The developer is not associated with WordNet or Princeton.")
                .font(Self.footFont)
            Link("Questions? Send me a mail.",
                 destination: URL(string: "mailto:iappsupport@googlemail.com")!)
                .font(Self.footFont.bold())
                .frame(minHeight: 44, alignment: .leading)
            DisclosureGroup {
                Text(Self.licenseText)
                    .font(Self.footFont)
                    .padding(.top, 4)
            } label: {
                Text("WordNet 3.0 License")
                    .font(Self.footFont.bold())
            }
            .tint(.black)
        }
    }

    static let licenseText = """
    WordNet Release 3.0

    This software and database is being provided to you, the LICENSEE, by
    Princeton University under the following license.  By obtaining, using
    and/or copying this software and database, you agree that you have
    read, understood, and will comply with these terms and conditions.:

    Permission to use, copy, modify and distribute this software and
    database and its documentation for any purpose and without fee or
    royalty is hereby granted, provided that you agree to comply with
    the following copyright notice and statements, including the disclaimer,
    and that the same appear on ALL copies of the software, database and
    documentation, including modifications that you make for internal
    use or for distribution.

    WordNet 3.0 Copyright 2006 by Princeton University.  All rights reserved.

    THIS SOFTWARE AND DATABASE IS PROVIDED "AS IS" AND PRINCETON
    UNIVERSITY MAKES NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR
    IMPLIED.  BY WAY OF EXAMPLE, BUT NOT LIMITATION, PRINCETON
    UNIVERSITY MAKES NO REPRESENTATIONS OR WARRANTIES OF MERCHANT-
    ABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE
    OF THE LICENSED SOFTWARE, DATABASE OR DOCUMENTATION WILL NOT
    INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR
    OTHER RIGHTS.

    The name of Princeton University or Princeton may not be used in
    advertising or publicity pertaining to distribution of the software
    and/or database.  Title to copyright in this software, database and
    any associated documentation shall at all times remain with
    Princeton University and LICENSEE agrees to preserve same.
    """
}
