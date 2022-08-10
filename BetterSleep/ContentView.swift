//
//  ContentView.swift
//  BetterSleep
//
//  Created by Eymen Varilci on 8.08.2022.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeUpTime
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var recomendedBedTime : String {
        
        calculateBedTime()
    }
    
    static var defaultWakeUpTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("When do you want to wake up?")
                        .frame(alignment: .leading)
                        .font(.headline)
                        .padding()
                    Spacer()
                    DatePicker("Please enter a date", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .padding()
                }
                Divider()
                HStack{
                    Text("How much coffee did you have today?")
                        .frame(alignment: .leading)
                        .font(.headline)
                        .padding()
                    Spacer()
                }
                
                Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount.formatted()) cups", value: $coffeeAmount,in: 1...20, step: 1)
                    .padding()
                Divider()
                HStack {
                    Text("Desired amount of sleep")
                        .frame(alignment: .leading)
                        .font(.headline)
                        .padding()
                    Spacer()
                    
                }
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    .padding()
                Divider()
                
                HStack {
                    
                    Text("Your bedtime is: \(recomendedBedTime)")
                        .font(.title.bold())
                        
                        .padding()
                    Spacer()
                }
                
                Spacer()
            }
            .navigationTitle("BetterSleep")
            .navigationBarTitleDisplayMode(.inline)
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    func calculateBedTime() -> String {
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculater(configuration: config)
            
            // logic comes here
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
          let formatter = DateFormatter()
            formatter.timeStyle = .short
           return formatter.string(from: sleepTime)
        } catch {
            // sometrhing went wrong
            alertTitle = "Error"
            alertMessage = "Something went wrong while calculating your bedtime."
            showingAlert = true
            return "Error"
        }
        
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
