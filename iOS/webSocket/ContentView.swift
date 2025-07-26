//
//  ContentView.swift
//  webSocket
//
//  Created by Tornike Despotashvili on 7/26/25.
//

import SwiftUI

struct ContentView: View {
  @State private var socketManager = WebSocketManager()
  @State private var text: String = ""
  
  var body: some View {
    NavigationStack {
      if socketManager.isConnected {
        VStack {
          ScrollView {
            VStack {
              ForEach(socketManager.chatBox, id: \.messageId) { message in
                
                HStack {
                  if message.userId == socketManager.currentUserId {
                    Spacer()
                  }
                  
                  Text(message.message)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background {
                      message.userId == socketManager.currentUserId ? Color.green : Color.gray
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .foregroundStyle(.white)
                  
                  if message.userId != socketManager.currentUserId {
                    Spacer()
                  }
                }
              }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
          }
          .scrollIndicators(.hidden)
          .defaultScrollAnchor(.bottom)
          .animation(.default, value: socketManager.chatBox)
        }
        .safeAreaInset(edge: .bottom) {
          HStack {
            TextField("Message here ...", text: $text)
              .frame(height: 40)
              .padding(.leading, 10)
              .padding(.trailing, 40)
              .clipShape(RoundedRectangle(cornerRadius: 20))
              .overlay {
                RoundedRectangle(cornerRadius: 20)
                  .stroke(.gray, lineWidth: 1)
              }
              .overlay(alignment: .bottomTrailing) {
                Button {
                  let message = MessageModel(userId: 2, user: "Despo", message: text)
                  
                  Task {
                    await socketManager.send(message)
                  }
                  
                  text = ""
                } label: {
                  Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                }
                .offset(x: -5, y: -5)
                .disabled(text.isEmpty)
              }
          }
          .padding()
        }
        
        .navigationTitle("Chat 💬")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              socketManager.disconnect()
            } label: {
              Image(systemName: "arrow.left.square")
            }
          }
        }
        .toolbarBackground(.visible, for: .navigationBar)
      } else {
        Button("შეერთება") {
          socketManager.connect()
        }
        .buttonStyle(.borderedProminent)
      }
    }
  }
}

#Preview {
  ContentView()
}
