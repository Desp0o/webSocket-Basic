//
//  WebSocketManager.swift
//  webSocket
//
//  Created by Tornike Despotashvili on 7/26/25.
//

import Foundation
import Observation

@MainActor
@Observable
class WebSocketManager {
  private var webSocketTask: URLSessionWebSocketTask?
  private let url = URL(string: "ws://localhost:8080")!
  var isConnected: Bool = false
  var currentUserId: Int = 2
  
  var message: MessageModel?
  var chatBox = [MessageModel]()
  
  func connect() {
    let session = URLSession(configuration: .default)
    webSocketTask = session.webSocketTask(with: url)
    webSocketTask?.resume()
    isConnected = true
    
    Task {
      await receiveMessages()
    }
  }
  
  func disconnect() {
    webSocketTask?.cancel(with: .goingAway, reason: nil)
    isConnected = false
  }
  
  func send(_ message: MessageModel) async {
    let messagedata = try? JSONEncoder().encode(message)
    
    guard let messagedata else { return }
    
    let messageForSend = URLSessionWebSocketTask.Message.data(messagedata)
    
    do {
      try await webSocketTask?.send(messageForSend)
      
      if isConnected {
        chatBox.append(message)
      }
    } catch {
      print("შეცდომა გაგზავნისას:", error)
    }
  }
  
  private func receiveMessages() async {
    guard let task = webSocketTask else { return }
    
    while true {
      do {
        let response = try await task.receive()
        
        switch response {
        case .string(let text):
          print("მიღებულია:", text, "🚀")
          if let data = text.data(using: .utf8), !text.isEmpty {
            do {
              let decoded = try JSONDecoder().decode(MessageModel.self, from: data)
              message = decoded
              chatBox.append(decoded)
            } catch {
              print("დეკოდირების შეცდომა:", error)
            }
          }
        case .data(let data):
          print("მიღებულია Data:", data)
        @unknown default:
          print("უცნობი შეტყობინება")
        }
      } catch {
        print("შეცდომა მიღებისას:", error)
        break
      }
    }
  }
}
