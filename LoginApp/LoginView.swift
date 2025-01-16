//
//  LoginPage.swift
//  LoginApp
//
//  Created by pavan naik on 14/01/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var message: String = ""
    @State private var showPassword: Bool = false
    @State private var loginMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundView()
                
                VStack(spacing: 20){
                    Text("Login Form")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("lightBlue"))
                    
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    
                    ZStack{
                        if showPassword {
                            TextField("Enter your password", text: $password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
                    }
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    HStack{
                        Spacer()
                        Button(action:{
                            showPassword.toggle()
                        }) {
                            Text(showPassword ? "Hide password" : "Show password")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                    }
                    Button(action: {loginUser()}) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView("Logging in...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                    
                    if !loginMessage.isEmpty {
                        Text(loginMessage)
                            .foregroundColor(.red)
                            .font(.body)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                    
                    NavigationLink(destination: Dashboard(), isActive: $isLoggedIn) {
                        EmptyView()
                    }
                }
                .padding()
            }
        }
    }
    
    func loginUser() {
        let url = URL(string: "http://localhost:8000/api/user/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        isLoading = true
        loginMessage = ""
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async{
                isLoading = false
                if let error = error {
                    loginMessage = "Login failed: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    loginMessage = "No response from server"
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    isLoggedIn = true
                } else {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let token = json["token"] as? String {
                            // Save the token to UserDefaults
                            UserDefaults.standard.set(token, forKey: "userToken")
                            UserDefaults.standard.synchronize()
                        } else if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                  let message = json["message"] as? String {
                            loginMessage = message
                        } else {
                            loginMessage = "Login failed: Unlnown error"
                        }
                    } catch {
                        loginMessage = "Login failed: Unable to decode error message"
                    }
                }
            }
        }.resume()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            LoginView()
            LoginView()
                .previewDisplayName("Dark Mode")
                .environment(\.colorScheme, .dark)
        }
    }
}

//#Preview {
//    LoginView()
//}

struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.indigo.opacity(0.3), Color.indigo.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
}
