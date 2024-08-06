//
//  ContentView.swift
//  Test app
//
//  Created by Андрій Кулягін on 23.08.2023.
//

import SwiftUI
import Keyri

struct ContentView: View {
    @State var text = "Result will be here"
    @State var inputString = ""
    @State private var showingAlert = false
    
    let keyri = KeyriInterface(appKey: "Ekrdi04LFJSRraLObtJpUap6fkh45fwi",
                               publicApiKey:   "QjBbOrlRALdlebpAuhjtNIJJzgL4vkIF",
                               serviceEncryptionKey: "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEzteySVilYBihc6V67mN084ajGYlBOqXr6JmZ2A26Z6iW/9G8EYxPxfPRgzADrcZUHAcCuXfnv3alDvwYoGaFg==",
                               detectionsConfig: KeyriDetectionsConfig(blockTamperDetection: true)
    )
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack {
                TextField("Public user ID", text: $inputString)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .frame(height: 48)
                                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                                    .cornerRadius(5)
                    .border(.secondary)
                
                Text(text)
                    .onTapGesture {
                        UIPasteboard.general.string = text
                        showingAlert = true
                    }
                    .alert("Copied!", isPresented: $showingAlert) {
                        Button("OK", role: .cancel) {
                            showingAlert = false
                            text = "Result will be here"
                        }
                    }.padding()
                
                Button(action: {
                    keyri.generateAssociationKey(publicUserId: inputString) { res in
                        switch res {
                        case .success(let associationKey):
                            text = associationKey.derRepresentation.base64EncodedString()
                            
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("Generate association key")
                }).padding()
                
                Button(action: {
                    keyri.getAssociationKey(publicUserId: inputString) { res in
                        switch res {
                        case .success(let associationKey):
                            text = associationKey?.derRepresentation.base64EncodedString() ?? "No key present for \(inputString). Use generateAssociationKey()"
                            
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("Get association key")
                }).padding()
                
                Button(action: {
                    keyri.removeAssociationKey(publicUserId: inputString) { res in
                        switch res {
                        case .success:
                            text = "Association key removed!"
                            
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("Remove association key")
                }).padding()
                
                Button(action: {
                    keyri.listAssociationKeys { res in
                        switch res {
                        case .success(let keys):
                            text = keys?.map { (key: String, value: String) in
                                return "\(key): \(value)"
                            }.joined(separator: ",\n") ?? "No keys present"
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("List association keys")
                }).padding()
                
                Button(action: {
                    keyri.listUniqueAccounts { res in
                        switch res {
                        case .success(let keys):
                            text = keys?.map { (key: String, value: String) in
                                return "\(key): \(value)"
                            }.joined(separator: ",\n") ?? "No keys present"
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("List unique accounts")
                }).padding()
                
                Button(action: {
                    keyri.generateUserSignature(publicUserId: inputString, data: inputString.data(using: String.Encoding.ascii)!) { res in
                        switch res {
                        case .success(let signature):
                            text = signature.derRepresentation.base64EncodedString()
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("Generate user signature")
                }).padding()
                
                Button(action: {
                    keyri.easyKeyriAuth(payload: inputString, publicUserId: inputString) { res in
                        switch res {
                        case .success:
                            text = "Auth successfully!"
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("Easy Keyri auth")
                }).padding()
                
                
                Button(action: {
                    keyri.sendEvent(publicUserId: inputString) { res in
                        switch res {
                        case .success(let fingerprintResponse):
                            let jsonEncoder = JSONEncoder()
                            let jsonData = try? jsonEncoder.encode(fingerprintResponse)
                            text = String(data: jsonData!, encoding: String.Encoding.utf8) ?? "Failed to get response"
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("Send event")
                })
                .padding()
                
                Button(action: {
                    keyri.createFingerprint { res in
                        switch res {
                        case .success(let fingerprintRequest):
                            let jsonEncoder = JSONEncoder()
                            let jsonData = try? jsonEncoder.encode(fingerprintRequest)
                            text = String(data: jsonData!, encoding: String.Encoding.utf8) ?? "Failed to get response"
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("Create fingerprint")
                })
            .padding()
                
                Button(action: {
                    keyri.login(publicUserId: inputString) { res in
                        switch res {
                        case .success(let loginObject):
                            let jsonEncoder = JSONEncoder()
                            let jsonData = try? jsonEncoder.encode(loginObject)
                            text = String(data: jsonData!, encoding: String.Encoding.utf8) ?? "Failed to create login object"
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("Login")
                })
                .padding()
                
                Button(action: {
                    keyri.sendEvent(publicUserId: inputString) { res in
                        switch res {
                        case .success(let registerObject):
                            let jsonEncoder = JSONEncoder()
                            let jsonData = try? jsonEncoder.encode(registerObject)
                            text = String(data: jsonData!, encoding: String.Encoding.utf8) ?? "Failed to create register object"
                        case .failure(let error):
                            text = error.localizedDescription
                        }
                    }
                }, label: {
                    Text("Register")
                }).padding()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
