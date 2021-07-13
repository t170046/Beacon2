//
//  ContentView.swift
//  Beacon2
//
//  Created by 高井 on 2021/05/23.
//
import Combine
import CoreLocation
import SwiftUI
import CoreBluetooth


class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate{
    var didChange = PassthroughSubject<Void, Never>()
    var locationManager: CLLocationManager?
    var lastDistance = CLProximity.unknown
    
    override init(){
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()

    }
    
    func locationManager(_ manager: CLLocationManager,didChangeAuthorization status: CLAuthorizationStatus){
        print("1")
        locationManager?.startUpdatingLocation()
        if status == .authorizedWhenInUse{
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
                if CLLocationManager.isRangingAvailable(){
                    startScanning()
                }
            }
        }
        
    }
  
    func startScanning(){
        print("2")
        let uuid = UUID(uuidString: "48534442-4C45-4144-80C0-1800FFFFFFFF")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        /* let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "MyBeacon")*/
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
    }
    
    /*func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
            print("Delegate: didStartMonitoringFor")
        }*/
    
    /*func locationManager(_ manager: CLLocationManager,
            didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion {
            // Start ranging only if the devices supports this service.
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
                manager.startUpdatingLocation()
        }
    }
}
*/
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        print("3")
        if let beacon = beacons.first{
            update(distance: beacon.proximity)
        }else{
            update(distance: .unknown)
        }
    }
    
    
    func update(distance:CLProximity){
        print("4")
        lastDistance = distance
        didChange.send(())
    }
}

struct BigText: ViewModifier{
    
    func body(content: Content) -> some View{
        content.font(Font.system(size: 72, design: .rounded))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView: View {
    @ObservedObject var detector = BeaconDetector()
    
    var body: some View {
        print("5")
        if detector.lastDistance == .immediate{
            return Text("RIGHT HERE")
                .modifier(BigText())
                .background(Color.red)
                .edgesIgnoringSafeArea(.all)
            
        }else if detector.lastDistance == .near{
            return Text("NEAR")
                .modifier(BigText())
                .background(Color.orange)
                .edgesIgnoringSafeArea(.all)
                
        }else if detector.lastDistance == .far{
            return Text("FAR")
                .modifier(BigText())
                .background(Color.blue)
                .edgesIgnoringSafeArea(.all)
            
        }else{
            return Text("UNKNOWN")
                .modifier(BigText())
                .background(Color.gray)
                .edgesIgnoringSafeArea(.all)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
