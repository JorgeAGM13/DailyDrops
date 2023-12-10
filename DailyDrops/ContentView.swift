//  ContentView.swift

//  DailyDrops

//  Created by ByteBosses


import SwiftUI
import UserNotifications

let minimumDailyGoal = 8

struct ContentView: View {
    private let lastDayIntakeKey = "lastDayIntake"
    
    @State private var waterIntake: Int = {
        let currentDate = Date()
        let calendar = Calendar.current
        let storedIntake = UserDefaults.standard.integer(forKey: "waterIntake")
        if let lastIntakeDate = UserDefaults.standard.object(forKey: "lastIntakeDate") as? Date,
           !calendar.isDateInToday(lastIntakeDate) {
            
            return 0
        }
        
        return max(storedIntake, 0)
    }()
    @State private var dailyGoal: Int = UserDefaults.standard.integer(forKey: "dailyGoal") == 0 ? 8 : UserDefaults.standard.integer(forKey: "dailyGoal")
    @State private var goalInput = ""
    @State private var lastIntakeDate = UserDefaults.standard.object(forKey: "lastIntakeDate") as? Date ?? Date()
    @State private var showAlert = false
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permiso concedido")
            } else if let error = error {
                print("Error al solicitar permiso: \(error.localizedDescription)")
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                
                Image("Fondo")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.blue)
                        
                        Text("Hidratación de Hoy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            
                            .mask(
                                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing)
                                .frame(maxWidth: .infinity)
                                )
                            .shadow(radius: 2)
                    }
                    .padding()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    
                    Text("Mantenerse hidratado es crucial para la salud y el bienestar. Se recomienda beber al menos 8 vasos de agua al día para mantener una hidratación adecuada y ayudar al cuerpo a funcionar de manera óptima.")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 105/255, green: 105/255, blue: 105/255))
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    
                    HStack {
                        TextField("Define tu objetivo de hidratación diaria...", text: $goalInput)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(red: 173/255, green: 216/255, blue: 230/255).opacity(0.9))
                            .cornerRadius(10)
                            .overlay(
                                HStack {
                                    Spacer()
                                    
                                    if !goalInput.isEmpty {
                                        Button(action: {
                                            goalInput = ""
                                        }) {
                                            Image(systemName: "multiply.circle.fill")
                                                .foregroundColor(Color(red: 80/255, green: 80/255, blue: 80/255))
                                        }
                                        .padding(.trailing, 16)
                                    }
                                }
                            )
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Hecho") {
                                        if !goalInput.isEmpty {
                                            updateDailyGoal()
                                        }
                                        hideKeyboard()
                                    }
                                }
                            }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack {
                        Text("Progreso actual:")
                            .font(.title2)
                            .foregroundColor(Color(red: 1/255, green: 22/255, blue: 39/255))
                        
                        
                        ProgressView(value: Float(waterIntake), total: Float(dailyGoal))
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 30/255, green: 144/255, blue: 255/255)))
                            .frame(width: 300)
                            .padding()
                        
                        Text("\(waterIntake) de \(dailyGoal) vasos")
                            .font(.callout)
                            .foregroundColor(Color(red: 80/255, green: 80/255, blue: 80/255))
                    }
                    .padding()
                    
                    Spacer()
                    Spacer()
                    
                    
                    if waterIntake >= dailyGoal {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 173/255, green: 216/255, blue: 230/255).opacity(0.9), Color(red: 173/255, green: 216/255, blue: 230/255).opacity(0.9)]), startPoint: .leading, endPoint: .trailing))
                                .frame(height: 100)
                            
                            Text("🎊 ¡Felicidades! 🎊\nHas alcanzado tu meta diaria")
                                .font(.headline)
                                .foregroundColor(Color(red: 34/255, green: 139/255, blue: 34/255))
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .padding()
                        
                        Spacer()
                        Spacer()
                    }
                    
                    
                    Button(action: {
                        addWaterIntake()
                    }) {
                        HStack {
                            Text("+1")
                                .font(.largeTitle)
                            Image(systemName: "mug.fill")
                                .font(.largeTitle)
                            Text("Vaso de Agua")
                                .font(.largeTitle)
                        }
                        .padding()
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 31/255, blue: 63/255).opacity(0.9), Color(red: 0, green: 31/255, blue: 63/255).opacity(0.9)]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                    }
                    .padding(.bottom)
                    
                    
                    .onAppear {
                        let currentDate = Date()
                        if !Calendar.current.isDateInToday(lastIntakeDate) {
                            
                            let lastDayIntake = UserDefaults.standard.integer(forKey: lastDayIntakeKey)
                            if lastDayIntake > 8 {
                                dailyGoal = lastDayIntake
                            }
                            
                            waterIntake = 0
                            UserDefaults.standard.set(0, forKey: "waterIntake")
                            UserDefaults.standard.set(0, forKey: lastDayIntakeKey)
                        } else {
                            
                            UserDefaults.standard.set(waterIntake, forKey: lastDayIntakeKey)
                        }
                        lastIntakeDate = currentDate
                        UserDefaults.standard.set(currentDate, forKey: "lastIntakeDate")
                    }
                
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Valor no válido"),
                    message: Text("Por tu salud, la meta diaria debe ser de al menos \(minimumDailyGoal) vasos."),
                    dismissButton: .default(Text("OK")) {
                        
                        dailyGoal = minimumDailyGoal
                        UserDefaults.standard.set(minimumDailyGoal, forKey: "dailyGoal")
                        
                        
                        goalInput = ""
                    }
                )
            }
        }.onAppear {
            self.requestNotificationPermission()
        }
    }

    private func addWaterIntake() {
        let currentDate = Date()
        if !Calendar.current.isDateInToday(lastIntakeDate) {
            waterIntake = 0
            lastIntakeDate = currentDate
        }
        
        waterIntake += 1
        UserDefaults.standard.set(waterIntake, forKey: "waterIntake")
        UserDefaults.standard.set(currentDate, forKey: "lastIntakeDate")

        
        if waterIntake < dailyGoal {
            let notificationDelegate = NotificationDelegate()
            notificationDelegate.cancelAllNotifications()
            notificationDelegate.scheduleNotification(title: "Es Hora de Beber Agua", body: "¡Recuerda alcanzar tu objetivo de hidratación diaria!", timeInterval: 3600)
        } else {
            
            let notificationDelegate = NotificationDelegate()
            notificationDelegate.cancelAllNotifications()
        }
    }

    private func updateDailyGoal() {
        if let newGoal = Int(goalInput), newGoal >= minimumDailyGoal {
            dailyGoal = newGoal
            UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
            goalInput = ""
            hideKeyboard()
        } else {
            showAlert = true
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
