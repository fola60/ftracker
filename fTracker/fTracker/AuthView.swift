import SwiftUI

struct AuthView: View {
    enum FocusedField {
        case str1, str2
    }
    @State private var isSignUp: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    @State private var success: Bool = false
    @State private var showToast: Bool = false
    @State private var loading: Bool = false
    @State private var showForgotPassword: Bool = false
    @FocusState private var focusedField: FocusedField?
    
    private var isEmail: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
    
    private var validPassword: Bool {
        let regex = "(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$&*]).{8,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Text(isSignUp ? "Sign Up" : "Login")
                .font(.custom("AvenirNext-heavy" ,size: 48))
                .fontWeight(.bold)
                .padding()
            
            VStack {
                
                HStack {
                    Image(systemName: "at")
                        .padding()
                    VStack(spacing: 4) {
                        TextField("Email", text:$email)
                            .focused($focusedField, equals: .str1)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(.vertical, 8)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.2))
                    }
                }
            
                HStack {
                    Image(systemName: "exclamationmark.lock.fill")
                        .padding()
                    VStack(spacing: 4) {
                        SecureField("Password", text:$password)
                            .focused($focusedField, equals: .str2)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(.vertical, 8)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.2))
                    }
                }
                
                if !isSignUp {
                    HStack {
                        Spacer()
                        Button {
                            showForgotPassword = true
                        } label: {
                            Text("Forgot password?")
                        }
                    .padding()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            
            
            HStack {
                Spacer()
                Button {
                    Task {
                        if isSignUp {
                            if (isEmail && validPassword) {
                                await signUp()
                            } else {
                                message = ""
                                if (!isEmail) {
                                    message = "Invalid email."
                                }
                                
                                if (!validPassword) {
                                    message += " The password must contain at least one uppercase and lowercase letter, one digit and one special character."
                                }
                                
                                showToast = true
                                await hideToastAfterDelay()
                                
                            }
                        } else {
                            await login()
                        }
                    }
                } label: {
                    Text(isSignUp ? "Sign Up" : "Sign in")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                    
                }
                .frame(width: 250, height: 40)
                .background(.blue)
                .cornerRadius(15)
                Spacer()
            }
            
            HStack {
                Text(isSignUp ? "Already have an account" : "New to fTrack?")
                    .foregroundStyle(.gray.opacity(0.8))
                Button {
                    isSignUp.toggle()
                } label: {
                    Text(isSignUp ? "Login" : "Sign up")
                }
            }
            
            HStack {
                if loading {
                    ProgressView()
                          .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                          .scaleEffect(1.5, anchor: .center)
                          .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                              // Perform transition to the next view here
                            }
                          }
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .overlay(
            VStack {
                if showToast {
                    Text(message)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(success ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showToast)
                }
                Spacer()
            }
        )
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(
                showForgotPassword: $showForgotPassword,
                message: $message,
                success: $success,
                showToast: $showToast
            )
        }
        
    }
    
    @MainActor
    private func hideToastAfterDelay() async {
        try? await Task.sleep(nanoseconds: 4_000_000_000)
        showToast = false
    }
    
    private func login() async {
        loading = true
        let loginRes = await Globals.signIn(email: email, password: password)
        loading = false
        success = loginRes
        message = loginRes ? "Logged in!" : "Email or Password Incorrect!"
        showToast = true
        await hideToastAfterDelay()
    }
    
    private func signUp() async  {
        loading = true
        if let messageResponse = await Globals.signUp(email: email, password: password) {
            success = true
            isSignUp.toggle()
            message = messageResponse
            print(messageResponse)
        } else {
            success = false
            message = "Error! Come back Later."
        }
        loading = false
        showToast = true
        await hideToastAfterDelay()
    }
    
    private func forgotPassword(email: String) async {
        loading = true
        if let messageResponse = await resetPassword(email: email) {
            success = true
            message = messageResponse
        }
        loading = false
        showToast = true
        await hideToastAfterDelay()
    }
    
    private func emailValidation() -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
}

struct ForgotPasswordView: View {
    @Binding var showForgotPassword: Bool
    @Binding var message: String
    @Binding var success: Bool
    @Binding var showToast: Bool
    
    @State private var resetEmail: String = ""
    @State private var loading: Bool = false
    @FocusState private var emailFocused: Bool
    
    private var isValidEmail: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: resetEmail)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 32) {
                
                VStack(spacing: 16) {
                    Text("Reset Password")
                        .font(.custom("AvenirNext-heavy", size: 36))
                        .fontWeight(.bold)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "at")
                            .padding()
                        VStack(spacing: 4) {
                            TextField("Email", text: $resetEmail)
                                .focused($emailFocused)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .padding(.vertical, 8)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.2))
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            Task {
                                await handleForgotPassword()
                            }
                        } label: {
                            HStack {
                                if loading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Send Reset Link")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 18))
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .frame(width: 250, height: 40)
                        .background(isValidEmail ? .blue : .gray)
                        .cornerRadius(15)
                        .disabled(!isValidEmail || loading)
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showForgotPassword = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    @MainActor
    private func hideToastAfterDelay() async {
        try? await Task.sleep(nanoseconds: 4_000_000_000)
        showToast = false
    }
    
    private func handleForgotPassword() async {
        guard isValidEmail else { return }
        
        loading = true
        emailFocused = false
        
        // Call your reset password function here
        if let messageResponse = await resetPassword(email: resetEmail) {
            success = true
            message = messageResponse
            showForgotPassword = false
        } else {
            success = false
            message = "Failed to send reset email. Please try again."
        }
        
        loading = false
        showToast = true
        await hideToastAfterDelay()
    }
}


#Preview {
    AuthView()
}
