//
//  MaterialDesignTextField.swift
//  hauler
//
//  Created by Homing Lau on 2023-06-13.
//
//  By Nikita Lazarev-Zubov
//  https://lazarevzubov.medium.com/material-design-like-text-field-with-swiftui-d50d299da3b
//

import SwiftUI

struct MaterialDesignTextField: View {
    
    var body: some View {
        ZStack {
            TextField("", text: $text)
                .padding(6.0)
                .background(RoundedRectangle(cornerRadius: 4.0, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth))
                .focused($focusField, equals: .textField)
            HStack {
                ZStack {
                    Color(.white)
                        .cornerRadius(4.0)
                        .opacity(placeholderBackgroundOpacity)
                    Text(placeholder)
                        .foregroundColor(.white)
                        .colorMultiply(placeholderColor)
                        .animatableFont(size: placeholderFontSize)
                        .padding(2.0)
                        .layoutPriority(1)
                }
                .padding([.leading], placeholderLeadingPadding)
                .padding([.bottom], placeholderBottomPadding)
                Spacer()
                Image(systemName: image)
                .foregroundColor(.green)
                .padding(.trailing)
                
            }
            HStack {
                VStack {
                    Spacer()
                    Text(hint)
                        .font(.system(size: 10.0))
                        .foregroundColor(.gray)
                        .padding([.leading], 10.0)
                }
                Spacer()
            }
        }
        .onChange(of: editing) {
            focusField = $0 ? .textField : nil
            withAnimation(.easeOut(duration: 0.1)) {
                updateBorder()
                updatePlaceholder()
            }
        }
        .frame(height: 64.0)
    }
    private let placeholder: String
    @State private var borderColor = Color.gray
    @State private var borderWidth = 1.0
    @Binding private var editing: Bool
    @FocusState private var focusField: Field?
    @Binding private var hint: String
    @State private var placeholderBackgroundOpacity = 0.0
    @State private var placeholderBottomPadding = 0.0
    @State private var placeholderColor = Color.gray
    @State private var placeholderFontSize = 16.0
    @State private var placeholderLeadingPadding = 2.0
    @State private var image = ""
    @Binding private var text: String
    @Binding private var valid: Bool
    private let initialEditing: Bool
    
    init(_ text: Binding<String>,
         placeholder: String,
         hint: Binding<String>,
         editing: Binding<Bool>,
         valid: Binding<Bool>,
         initialEditing: Bool) {
        self._text = text
        self.placeholder = placeholder
        self._hint = hint
        self._editing = editing
        self._valid = valid
        if initialEditing{
            self.initialEditing = true
            updatePlaceholder()
            updateBorder()
        }else{
            self.initialEditing = false
        }
    }
    
    private func updateBorder() {
        updateBorderColor()
        updateBorderWidth()
    }
    
    private func updateBorderColor() {
        if !valid {
            borderColor = .red
            return
        }
        if editing {
            borderColor = Color("HaulerOrange")
            return
        }
        borderColor = .green
    }
    
    private func updateBorderWidth() {
        borderWidth = editing ? 2.0 : 1.0
    }
    
    private func updatePlaceholder() {
        updatePlaceholderBackground()
        updatePlaceholderColor()
        updatePlaceholderFontSize()
        updatePlaceholderPosition()
    }
    
    private func updateimage() {
        if valid{
            image = "checkmark.fill"
            return
        }
        image = ""
    }
    
    private func updatePlaceholderBackground() {
        if editing || !text.isEmpty {
            placeholderBackgroundOpacity = 1.0
        } else {
            placeholderBackgroundOpacity = 0.0
        }
    }
    
    private func updatePlaceholderColor() {
        if valid {
            placeholderColor = editing ? Color("HaulerOrange") : .gray
        } else if text.isEmpty {
            placeholderColor = editing ? .red : .gray
        } else {
            placeholderColor = .red
        }
    }
    
    private func updatePlaceholderFontSize() {
        if editing || !text.isEmpty {
            placeholderFontSize = 10.0
        } else {
            placeholderFontSize = 16.0
        }
    }
    
    private func updatePlaceholderPosition() {
        if editing || !text.isEmpty {
            placeholderBottomPadding = 34.0
            placeholderLeadingPadding = 8.0
        } else {
            placeholderBottomPadding = 0.0
            placeholderLeadingPadding = 8.0
        }
    }
    
    private enum Field {
        case textField
    }
    
}

struct MaterialDesignTextField_Previews: PreviewProvider {
    static var previews: some View {
        
        MaterialDesignTextField(.constant("1234"), placeholder: "Input", hint: .constant("hint"), editing: .constant(true), valid: .constant(true), initialEditing: true)
    }
}

struct AnimatableCustomFontModifier: AnimatableModifier {
    
    var animatableData: CGFloat {
        get { size }
        set { size = newValue }
    }
    var size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size))
    }
    
}

extension View {
    func animatableFont(size: CGFloat) -> some View {
        modifier(AnimatableCustomFontModifier(size: size))
    }
}
