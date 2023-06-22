//
//  ExpandableText.swift
//  ExpandableText
//
//  Created by ned on 23/02/23.
//

import Foundation
import SwiftUI

/**
An expandable text view that displays a truncated version of its contents with a "show more" button that expands the view to show the full contents.

 To create a new ExpandableText view, use the init method and provide the initial text string as a parameter. The text string will be automatically trimmed of any leading or trailing whitespace and newline characters.

Example usage with default parameters:
 ```swift
ExpandableText("Lorem ipsum dolor sit amet, consectetur adipiscing elit...")
    .font(.body)
    .foregroundColor(.primary)
    .lineLimit(3)
    .moreButtonText("more")
    .moreButtonColor(.accentColor)
    .expandAnimation(.default)
    .trimMultipleNewlinesWhenTruncated(true)
 ```
*/

public extension ExpandableText {
    
    /**
     Sets the font for the text in the `ExpandableText` instance.
     - Parameter font: The font to use for the text. Defaults to `body`
     - Returns: A new `ExpandableText` instance with the specified font applied.
     */
    func font(_ font: Font) -> Self {
        var copy = self
        copy.font = font
        return copy
    }
    
    /**
     Sets the foreground color for the text in the `ExpandableText` instance.
     - Parameter color: The foreground color to use for the text. Defaults to `primary`
     - Returns: A new `ExpandableText` instance with the specified foreground color applied.
     */
    func foregroundColor(_ color: Color) -> Self {
        var copy = self
        copy.color = color
        return copy
    }
    
    /**
     Sets the maximum number of lines to use for rendering the text in the `ExpandableText` instance.
     - Parameter limit: The maximum number of lines to use for rendering the text. Defaults to `3`
     - Returns: A new `ExpandableText` instance with the specified line limit applied.
     */
    func lineLimit(_ limit: Int) -> Self {
        var copy = self
        copy.lineLimit = limit
        return copy
    }
    
    /**
     Sets the text to use for the "show more" button in the `ExpandableText` instance.
     - Parameter moreText: The text to use for the "show more" button. Defaults to `more`
     - Returns: A new `ExpandableText` instance with the specified "show more" button text applied.
     */
    func moreButtonText(_ moreText: String) -> Self {
        var copy = self
        copy.moreButtonText = moreText
        return copy
    }
    
    func lessButtonText(_ lessText: String) -> Self {
        var copy = self
        copy.lessButtonText = lessText
        return copy
    }
    
    /**
     Sets the font to use for the "show more" button in the `ExpandableText` instance.
     - Parameter font: The font to use for the "show more" button. Defaults to the same font as the text
     - Returns: A new `ExpandableText` instance with the specified "show more" button font applied.
     */
    func moreButtonFont(_ font: Font) -> Self {
        var copy = self
        copy.moreButtonFont = font
        return copy
    }
    
    /**
     Sets the color to use for the "show more" button in the `ExpandableText` instance.
     - Parameter color: The color to use for the "show more" button. Defaults to `accentColor`
     - Returns: A new `ExpandableText` instance with the specified "show more" button color applied.
     */
    func moreButtonColor(_ color: Color) -> Self {
        var copy = self
        copy.moreButtonColor = color
        return copy
    }
    
    /**
     Sets the animation to use when expanding the `ExpandableText` instance.
     - Parameter animation: The animation to use for the expansion. Defaults to `default`
     - Returns: A new `ExpandableText` instance with the specified expansion animation applied.
     */
    func expandAnimation(_ animation: Animation) -> Self {
        var copy = self
        copy.expandAnimation = animation
        return copy
    }
    
    /**
     Sets whether multiple consecutive newline characters should be trimmed when truncating the text in the `ExpandableText` instance.
     - Parameter value: A boolean value indicating whether to trim multiple consecutive newline characters. Defaults to `true`
     - Returns: A new `ExpandableText` instance with the specified trimming behavior applied.
     */
    func trimMultipleNewlinesWhenTruncated(_ value: Bool) -> Self {
        var copy = self
        copy.trimMultipleNewlinesWhenTruncated = value
        return copy
    }
}

public struct ExpandableText: View {
    
    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool = false
    
    @State private var intrinsicSize: CGSize = .zero
    @State private var truncatedSize: CGSize = .zero
    @State private var moreTextSize: CGSize = .zero
    
    private let text: String
    internal var font: Font = .body
    internal var color: Color = .primary
    internal var lineLimit: Int = 3
    internal var moreButtonText: String = "more"
    internal var lessButtonText: String = "less"
    internal var moreButtonFont: Font?
    internal var moreButtonColor: Color = .accentColor
    internal var expandAnimation: Animation = .default
    internal var trimMultipleNewlinesWhenTruncated: Bool = true
    
    /**
     Initializes a new `ExpandableText` instance with the specified text string, trimmed of any leading or trailing whitespace and newline characters.
     - Parameter text: The initial text string to display in the `ExpandableText` view.
     - Returns: A new `ExpandableText` instance with the specified text string and trimming applied.
     */
    
    public init(_ text: String) {
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var body: some View {
        content
            .lineLimit(isExpanded ? nil : lineLimit)
            .applyingTruncationMask(size: moreTextSize, enabled: shouldShowMoreButton)
            .readSize { size in
                truncatedSize = size
                isTruncated = truncatedSize != intrinsicSize
            }
            .background(
                content
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .readSize { size in
                        intrinsicSize = size
                        isTruncated = truncatedSize != intrinsicSize
                    }
            )
            .background(
                Text(moreButtonText)
                    .font(moreButtonFont ?? font)
                    .hidden()
                    .readSize { moreTextSize = $0 }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(expandAnimation) { isExpanded.toggle() }
            }
            .modifier(OverlayAdapter(alignment: .trailingLastTextBaseline, view: {
                if shouldShowMoreButton {
                    Button {
                        withAnimation(expandAnimation) { isExpanded.toggle() }
                    } label: {
                        Text(moreButtonText)
                            .font(moreButtonFont ?? font)
                            .foregroundColor(moreButtonColor)
                    }
                }else if(!shouldShowMoreButton && self.isTruncated){
                    Button {
                        withAnimation(expandAnimation) { isExpanded.toggle() }
                    } label: {
                        Text(lessButtonText)
                            .font(moreButtonFont ?? font)
                            .foregroundColor(moreButtonColor)
                    }
                }
            }))
    }
    
    private var content: some View {
        Text(.init(
            trimMultipleNewlinesWhenTruncated
                ? (shouldShowMoreButton ? textTrimmingDoubleNewlines : text)
                : text
        ))
        .font(font)
        .foregroundColor(color)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var shouldShowMoreButton: Bool {
        !isExpanded && isTruncated
    }
    
    private var textTrimmingDoubleNewlines: String {
        text.replacingOccurrences(of: #"\n\s*\n"#, with: "\n", options: .regularExpression)
    }
}
