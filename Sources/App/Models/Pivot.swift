//
//  Pivot.swift
//  Veterinary
//
//  Created by Clement Yerochewski on 12/21/16.
//
//

import Vapor
import Fluent

final class ToyPet : Model {
    
    var exists: Bool = false
    var id: Node?
    var pet_id: Node
    var toy_id: Node
    
    init(pet_id: Node, toy_id: Node) {
        self.pet_id = pet_id
        self.toy_id = toy_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        pet_id = try node.extract("pet_id")
        toy_id = try node.extract("toy_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "toy_id": toy_id,
            "pet_id": pet_id,
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("toy_pet") { pets in
            pets.id()
            pets.int("toy_id")
            pets.int("pet_id")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("toy_pet")
    }
}
