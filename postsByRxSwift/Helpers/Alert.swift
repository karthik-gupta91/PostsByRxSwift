//
//  Alert.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 27/08/24.
//

import Foundation

struct AlertAction {
    let buttonTitle: String
    let handler: (() -> Void)?
}

struct SingleButtonAlert {
    let title: String
    let message: String?
    let action: AlertAction
}
