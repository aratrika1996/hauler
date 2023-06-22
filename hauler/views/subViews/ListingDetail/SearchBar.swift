//
//  SearchBar.swift
//  hauler
//
//  Created by Homing Lau on 2023-05-22.
//
import Foundation
import SwiftUI

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var onCancelClicked: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let sb = UISearchBar(frame: .zero)
        sb.delegate = context.coordinator.self
        sb.searchBarStyle = .default
        sb.searchTextField.clearButtonMode = .never
        sb.keyboardType = .default
        sb.returnKeyType = .done
        return sb
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, onCancelClicked: onCancelClicked)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var onCancelClicked: (() -> Void)?
        
        init(text: Binding<String> , onCancelClicked: (() -> Void)?) {
            _text = text
            self.onCancelClicked = onCancelClicked
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            print(text)
        }

        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.showsCancelButton = true
            return true
        }

        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.showsCancelButton = false
            return true
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            text = ""
            self.onCancelClicked?()
            searchBar.resignFirstResponder() // Dismiss the keyboard
            searchBar.showsCancelButton = false
        }
    }
}


