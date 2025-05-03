//
//  AuthFeature.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 02.05.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AuthFeature {
    
    @ObservableState
    struct State: Equatable {
        var username: String = ""
        var password: String = ""
        var isSignUpMode: Bool = false
        var errorMessage: String?
        
        static let initial = State()
    }
    
    @CasePathable
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case loginButtonTapped
        case signUpButtonTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case loginSuccess
        }
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .signUpButtonTapped:
                UserDefaults.standard.set(state.username, forKey: "username")
                UserDefaults.standard.set(state.password, forKey: "password")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                state.errorMessage = ""
                return .send(.delegate(.loginSuccess))
                
            case .loginButtonTapped:
                let savedUser = UserDefaults.standard.string(forKey: "username")
                let savedPass = UserDefaults.standard.string(forKey: "password")
                if state.username == savedUser,
                   state.password == savedPass {
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    return .send(.delegate(.loginSuccess))
                } else {
                    state.errorMessage = "❌ Invalid credentials"
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
