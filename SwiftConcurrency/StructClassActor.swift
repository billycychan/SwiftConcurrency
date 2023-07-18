//
//  StructClassActor.swift
//  SwiftConcurrency
//
//  Created by CHI YU CHAN on 17/7/2023.
//


/*
  VALUE TYPES
 - Struct, Enum, String, Int, etc.
 - Stored in the Stack
 - Faster
 - THREAD SAFE
 - When you assign or pass value type, a new copy of data is created
 
 REFERENCE TYPES:
 - Class, Function, Actor
 - Stored in the Heap
 - Slower, but synchronized
 - NOT Thread safe
 -  When you assign or pass reference type a new reference to original instance will be craeted (pointer)
 
 STACK:
 - Stored Value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast
 
 HEAP:
 - Stores Reference types
 - Share across threads
 
 
 STRUCT:
 - Based on VALUES
 - Can be mutated
 - Stored in the Stack!
 
 CLASS:
 - Based on REFERENCES(INSTANCES)
 - Stored in the Heap!
 - Inherit from other classes
 
 ACTOR:
 - Same as Class, but thread safe!
 - - - - - - - - - - - - - - - - - - - - - -
 
 Structs: Data Models, View
 Classes: ViewModels
 Actors: Shared 'Manager' and 'Data Store' -> Multiple places access
 
 
 
 */

import SwiftUI

class StructClassActorViewModel: ObservableObject {
    
    @Published var title: String = ""
    
    init() {
        print("ViewModel INIT")
    }
    
}

struct StructClassActor: View {
    
    @StateObject private var viewModel = StructClassActorViewModel()
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("View INIT")
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.red : Color.blue)
            .onAppear {
//                runTest()
            }
    }
}

struct StructClassActorHomeView: View {
    
    @State private var isActive: Bool = false
    
    var body: some View {
        StructClassActor(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}

struct StructClassActor_Previews: PreviewProvider {
    
    static var previews: some View {
        StructClassActor(isActive: false)
    }
}

struct MyStruct {
    var title: String
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActor {
    
    private func runTest() {
        print("Test Started")
        structTest1()
        printDivier()
        classTest1()
        printDivier()
        actorTest1()
//
//        structTest2()
//        printDivier()
//        classTest2()
//        printDivier()
    }
    
    private func printDivier() {
        print("""
    - - - - - - - - - - - -
""")
    }
    
    private func structTest1() {
        let objectA = MyStruct(title: "Starting Title!")
        print("ObjectA:", objectA.title)
        
        print("Pass the VALUES of objectA to objectB")

        var objectB = objectA
        print("ObjectB:", objectB.title)
        
        objectB.title = "Second title!"
        print("ObjectB title changed")
        
        print("ObjectA:", objectA.title)
        print("ObjectB:", objectB.title)
    }
    
    private func classTest1() {
        let objectA = MyClass(title: "Starting Title!")
        print("ObjectA:", objectA.title)
         
        print("Pass the REFERENCE of objectA to objectB")
        
        let objectB = objectA
        print("ObjectB:", objectB.title)
        
        objectB.title = "Second title!"
        print("ObjectB title changed")
        
        print("ObjectA:", objectA.title)
        print("ObjectB:", objectB.title)
    }
    
    private func actorTest1() {
        Task {
            print("actorTest1")
            let objectA = MyActor(title: "Starting Title!")
            await print("ObjectA:", objectA.title)
             
            let objectB = objectA
            await print("ObjectB:", objectB.title)
            
            await objectB.updateTitle(newTitle: "Second Title")
            print("ObjectB title changed")
            
            await print("ObjectA:", objectA.title)
            await print("ObjectB:", objectB.title)
        }
    }
    
}


// Immutable struct
struct CustomStruct {
    let title: String
    
    func updateTitle(newTitle: String) -> CustomStruct {
        CustomStruct(title: newTitle)
    }
}

// Immutable struct
struct MutatingStruct {
    private(set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActor {
    
    private func structTest2() {
        print("structTest2")
        
        var struct1 = MyStruct(title: "Title1")
        print("Struct1: ", struct1.title)
        struct1.title = "Title2"
        print("Struct1: ", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: ", struct2.title)
        struct2 = CustomStruct(title: "Title2")
        print("Struct2: ", struct2.title)
        
        var struct3 = CustomStruct(title: "Title1")
        print("Struct3: ", struct3.title)
        struct3 = CustomStruct(title: "Title2")
        print("Struct3: ", struct3.title)
        
        var struct4 = MutatingStruct(title: "Title1")
        print("Struct4: ", struct4.title)
        struct4.updateTitle(newTitle: "Title2")
        print("Struct4: ", struct4.title)
    }
}

extension StructClassActor {
    
    private func classTest2() {
        print("classTest2")
        
        let class1 = MyClass(title: "Title1")
        print("Class1: ", class1.title)
        class1.title = "Title2"
        print("class1: ", class1.title)
        
        let class2 = MyClass(title: "Title1")
        print("Class2: ", class2.title)
        class2.updateTitle(newTitle: "Title2")
        print("class2: ", class2.title)
    }
}
