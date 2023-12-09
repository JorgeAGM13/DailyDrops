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
            // Si la última ingesta no fue hoy, restablece `waterIntake`
            return 0
        }
        // Si no, utiliza el valor almacenado
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
                // Imagen de fondo
                Image("Fondo")
                    .resizable() // Hace que la imagen se pueda redimensionar
                    .edgesIgnoringSafeArea(.all) // Hace que la imagen se extienda en toda la pantalla, incluyendo las áreas de safe area
                
                VStack {
                    HStack {
                        Image(systemName: "drop.fill") // Icono de gota de agua
                            .foregroundColor(.blue)
                        
                        Text("Hidratación de Hoy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            // Se aplica el degradado como máscara
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
                        .foregroundColor(Color(red: 105/255, green: 105/255, blue: 105/255)) // Gris medio
                        .padding()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    // Sección para establecer la meta diaria
                    HStack {
                        TextField("Define tu objetivo de hidratación diaria...", text: $goalInput)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(red: 173/255, green: 216/255, blue: 230/255).opacity(0.9)) // Fondo azul claro
                            .cornerRadius(10)
                            .overlay(
                                HStack {
                                    Spacer()
                                    // Botón para limpiar el TextField que aparece solo si hay texto
                                    if !goalInput.isEmpty {
                                        Button(action: {
                                            goalInput = ""
                                        }) {
                                            Image(systemName: "multiply.circle.fill")
                                                .foregroundColor(Color(red: 80/255, green: 80/255, blue: 80/255)) // Gris oscuro
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
                    
                    Spacer() // Espaciador superior
                    
                    // Sección de Ingesta actual
                    VStack {
                        Text("Progreso actual:")
                            .font(.title2)
                            .foregroundColor(Color(red: 1/255, green: 22/255, blue: 39/255)) // Azul oscuro
                        
                        // Barra de progreso
                        ProgressView(value: Float(waterIntake), total: Float(dailyGoal))
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 30/255, green: 144/255, blue: 255/255))) // Azul dodger
                            .frame(width: 300)
                            .padding()
                        
                        Text("\(waterIntake) de \(dailyGoal) vasos")
                            .font(.callout)
                            .foregroundColor(Color(red: 80/255, green: 80/255, blue: 80/255)) // Gris oscuro
                    }
                    .padding()
                    
                    Spacer() // Espaciador inferior
                    Spacer()
                    
                    // Mensaje de felicitaciones si se alcanza la meta
                    if waterIntake >= dailyGoal {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 173/255, green: 216/255, blue: 230/255).opacity(0.9), Color(red: 173/255, green: 216/255, blue: 230/255).opacity(0.9)]), startPoint: .leading, endPoint: .trailing)) // Gradiente de fondo
                                .frame(height: 100)
                            
                            Text("🎊 ¡Felicidades! 🎊\nHas alcanzado tu meta diaria")
                                .font(.headline)
                                .foregroundColor(Color(red: 34/255, green: 139/255, blue: 34/255)) // Verde bosque
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .padding()
                        
                        Spacer()
                        Spacer()
                    }
                    
                    // Botón para agregar la ingesta de agua
                    Button(action: {
                        addWaterIntake()
                    }) {
                        HStack {
                            Text("+1")
                                .font(.largeTitle)
                            Image(systemName: "mug.fill") // Icono de un vaso de leche
                                .font(.largeTitle)
                            Text("Vaso de Agua")
                                .font(.largeTitle)
                        }
                        .padding()
                        .frame(height: 100) // Establece una altura fija para el botón
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 31/255, blue: 63/255).opacity(0.9), Color(red: 0, green: 31/255, blue: 63/255).opacity(0.9)]), startPoint: .leading, endPoint: .trailing)) // Gradiente de fondo
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(radius: 5) // Sombra ligera para dar profundidad
                    }
                    .padding(.bottom)
                    
                    // Modifica la función de reinicio diario
                    .onAppear {
                        let currentDate = Date()
                        if !Calendar.current.isDateInToday(lastIntakeDate) {
                            // Comprueba la ingesta del día anterior y actualiza la meta si es necesario
                            let lastDayIntake = UserDefaults.standard.integer(forKey: lastDayIntakeKey)
                            if lastDayIntake > 8 {
                                dailyGoal = lastDayIntake
                            }
                            
                            waterIntake = 0 // Reinicia la ingesta para el nuevo día
                            UserDefaults.standard.set(0, forKey: "waterIntake")
                            UserDefaults.standard.set(0, forKey: lastDayIntakeKey) // Reinicia la ingesta del último día
                        } else {
                            // Si todavía es el mismo día, actualiza la ingesta del último día
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
                        // Restablecer la meta al valor mínimo recomendado
                        dailyGoal = minimumDailyGoal
                        UserDefaults.standard.set(minimumDailyGoal, forKey: "dailyGoal")
                        
                        // Limpiar el campo goalInput
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
        UserDefaults.standard.set(waterIntake, forKey: "waterIntake") // Guardar el valor actualizado
        UserDefaults.standard.set(currentDate, forKey: "lastIntakeDate")

        // Programa una notificación solo si la ingesta actualizada es menor que la meta diaria
        if waterIntake < dailyGoal {
            let notificationDelegate = NotificationDelegate()
            notificationDelegate.cancelAllNotifications()
            notificationDelegate.scheduleNotification(title: "Es Hora de Beber Agua", body: "¡Recuerda alcanzar tu objetivo de hidratación diaria!", timeInterval: 3600) // Ajuste del tiempo en segundos
        } else {
            // Cancela todas las notificaciones si la meta ya se ha alcanzado
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
            showAlert = true // Muestra la alerta
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
