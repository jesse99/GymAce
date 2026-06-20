import SwiftUI

// 1min 30s
@ViewBuilder
func durationsTextField(_ title: String, _ text: Binding<String>) -> some View {
    TextField(title, text: text)
        .textFieldStyle(.roundedBorder)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
}

// 90
@ViewBuilder
func intTextField(_ title: String, _ text: Binding<String>) -> some View {
    TextField(title, text: text)
        .textFieldStyle(.roundedBorder)
        .keyboardType(.numberPad)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
}

// Bench Press
@ViewBuilder
func nameTextField(_ title: String, _ text: Binding<String>) -> some View {
    TextField(title, text: text)
        .textFieldStyle(.roundedBorder)
        .textInputAutocapitalization(.words)
}

// one line of arbitrary text
@ViewBuilder
func noteTextField(_ title: String, _ text: Binding<String>) -> some View {
    TextField(title, text: text)
        .textFieldStyle(.roundedBorder)
        .textInputAutocapitalization(.sentences)
}

// 1-4
@ViewBuilder
func rangeTextField(_ title: String, _ text: Binding<String>) -> some View {
    TextField(title, text: text)
        .textFieldStyle(.roundedBorder)
        .keyboardType(.numbersAndPunctuation)   // need numbers and dash
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
}

// 5 5 5
@ViewBuilder
func repsTextField(_ title: String, _ text: Binding<String>) -> some View {
    TextField(title, text: text)
        .textFieldStyle(.roundedBorder)
        .keyboardType(.numbersAndPunctuation)   // need numbers and space
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
}

// 135.0
@ViewBuilder
func weightTextField(_ title: String, _ text: Binding<String>) -> some View {
    TextField(title, text: text)
        .textFieldStyle(.roundedBorder)
        .keyboardType(.decimalPad)              // need numbers and .
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
}

