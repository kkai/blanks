import SwiftUI

/// Faithful reproduction of the 4.3 About screen (OptionsViewController):
/// optionback paper art on a 320×568 canvas, black nav bar with Done,
/// the tap/drag toggle, and per-SKU extras (Blanks: store link + tip
/// jar; MoreBlanks: thank-you label only).
struct LegacyAboutView: View {
    let config: SKUConfig

    @Environment(\.dismiss) private var dismiss
    @AppStorage("TappingUI") private var isTapping = false
    @State private var showTipJar = false

    static let canvas = CGSize(width: 320, height: 568)

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / Self.canvas.width
            canvasContent
                .frame(width: Self.canvas.width, height: Self.canvas.height)
                .scaleEffect(scale)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .sheet(isPresented: $showTipJar) {
            TipJarView()
        }
    }

    private var canvasContent: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.25, green: 0.25, blue: 0.25)

            Image("optionback")
                .resizable()
                .frame(width: 320, height: 568)

            // Black navigation bar at (0, 31, 320, 44), title "About",
            // Done on the left.
            ZStack {
                Rectangle().fill(Color.black.opacity(0.92))
                Text("About")
                    .font(.headline)
                    .foregroundStyle(.white)
                HStack {
                    Button("Done") { dismiss() }
                        .tint(.white)
                        .padding(.leading, 10)
                    Spacer()
                }
            }
            .frame(width: 320, height: 44)
            .position(x: 160, y: 31 + 22)

            // Tap-instead-of-drag toggle (both SKUs).
            Text("Tap the word instead dragging")
                .font(.custom("Baskerville", size: 18))
                .foregroundStyle(.black)
                .frame(width: 242, height: 45, alignment: .leading)
                .position(x: 20 + 121, y: 113 + 22.5)
            Toggle("", isOn: $isTapping)
                .labelsHidden()
                .frame(width: 51, height: 31)
                .position(x: 251 + 25.5, y: 120 + 15.5)

            if config.isBlanksSKU {
                blanksExtras
            } else {
                moreBlanksExtras
            }

            // WordNet / Princeton license.
            Text(config.isBlanksSKU ? "Licence information" : "licence information")
                .font(.custom("IowanOldStyle-Italic", size: 23))
                .foregroundStyle(.black)
                .frame(width: 178, height: 32, alignment: .leading)
                .position(x: config.isBlanksSKU ? 20 + 89 : 26 + 89,
                          y: config.isBlanksSKU ? 385 + 16 : 358 + 16)

            ScrollView {
                Text(Self.licenseText)
                    .font(.custom("IowanOldStyle-Roman", size: 11))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(width: 269, height: 112)
            .position(x: 20 + 134.5, y: 416 + 56)
        }
        .clipped()
    }

    @ViewBuilder
    private var blanksExtras: some View {
        Text("If you want, you can get more words:")
            .font(.custom("IowanOldStyle-Italic", size: 18))
            .foregroundStyle(.black)
            .frame(width: 259, height: 65, alignment: .leading)
            .position(x: 16 + 129.5, y: 153 + 32.5)

        Link("Get More Blanks from the AppStore",
             destination: URL(string: "https://apps.apple.com/app/moreblanks/id288808376")!)
            .font(.system(size: 15))
            .frame(width: 294, height: 35)
            .position(x: 6 + 147, y: 203 + 17.5)

        Text("new features are coming stay tuned :) ")
            .font(.custom("IowanOldStyle-Italic", size: 18))
            .foregroundStyle(.black)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(width: 302, height: 32, alignment: .leading)
            .position(x: 18 + 151, y: 246 + 16)

        Text("If you want, you can also support ")
            .font(.custom("IowanOldStyle-Italic", size: 18))
            .foregroundStyle(.black)
            .frame(width: 259, height: 32, alignment: .leading)
            .position(x: 20 + 129.5, y: 282 + 16)

        Text("developement and buy me a coffee:")
            .font(.custom("IowanOldStyle-Italic", size: 18))
            .foregroundStyle(.black)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(width: 239, height: 25, alignment: .leading)
            .position(x: 20 + 119.5, y: 311 + 12.5)

        Button("Buy me a Coffee") {
            showTipJar = true
        }
        .font(.system(size: 15))
        .frame(width: 150, height: 35)
        .position(x: 85 + 75, y: 344 + 17.5)
    }

    private var moreBlanksExtras: some View {
        Text("Thank you for your support!")
            .font(.custom("IowanOldStyle-Italic", size: 18))
            .foregroundStyle(.black)
            .frame(width: 215, height: 32, alignment: .leading)
            .position(x: 26 + 107.5, y: 242 + 16)
    }

    static let licenseText = """
    The word definitions are from Wordnet. The application developer is not associated in any way with Wordnet or Princeton.
    In case you have any questions just send me a mail iappsupport@googlemail.com                                                      ======================================WordNet Release 3.0

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
