//
//  MessageModel.swift
//  webSocket
//
//  Created by Tornike Despotashvili on 7/26/25.
//

import Foundation

struct MessageModel : Codable, Hashable {
  let userId: Int
  let user: String
  var messageId = UUID()
  let message: String
}


