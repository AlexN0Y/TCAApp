//
//  LoginView.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 02.05.2025.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    
    @Bindable var store: StoreOf<AuthFeature>
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Mode", selection: $store.isSignUpMode) {
                    Text("Login").tag(false)
                    Text("Sign Up").tag(true)
                }
                .pickerStyle(.segmented)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username").font(.headline)
                    TextField(
                        "Enter username",
                        text: $store.username
                    )
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
                    
                    Text("Password").font(.headline)
                    SecureField(
                        "Enter password",
                        text: $store.password
                    )
                }
                
                if let error = store.state.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button(store.state.isSignUpMode ? "Sign Up" : "Login") {
                    if store.state.isSignUpMode {
                        store.send(.signUpButtonTapped)
                    } else {
                        store.send(.loginButtonTapped)
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .navigationTitle(store.state.isSignUpMode ? "Sign Up" : "Login")
        }
    }
}
