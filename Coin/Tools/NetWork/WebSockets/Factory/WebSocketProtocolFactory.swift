//
//  WebSocketFactory.swift
//  WebSocket
//
//  Created by gm on 2018/10/30.
//  Copyright © 2018年 gm. All rights reserved.
//

import UIKit

protocol WebSocketProtocolFactory {
    func getWebSocket()->WebSocketDelegate
    func connectAgain(_ isRecalculate: Bool)
}

