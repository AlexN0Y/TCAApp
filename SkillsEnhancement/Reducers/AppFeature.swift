//
//  AppFeature.swift
//  SkillsEnhancement
//
//  Created by Alex Gav on 02.05.2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
    
    @ObservableState
    @CasePathable
    enum State: Equatable {
        case auth(AuthFeature.State)
        case main(MainFeature.State)
        
        init(){
            if let _ = UserDefaults.standard.string(forKey: "username"),
               UserDefaults.standard.bool(forKey: "isLoggedIn") {
                self = .main(.home(.init()))
            } else {
                self = .auth(.initial)
            }
        }
    }
    
    @CasePathable
    enum Action: Equatable {
        case auth(AuthFeature.Action)
        case main(MainFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.auth, action: \.auth) {
            AuthFeature()
        }
        Scope(state: \.main, action: \.main) {
            MainFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .auth(.delegate(.loginSuccess)):
                if case .auth(_) = state {
                     state = .main(.home(.init()))
                }
                return .none
                
            case .main(.delegate(.logout)):
                state = .auth(.initial)
                return .none
                
            default:
                return .none
            }
        }
    }
}
