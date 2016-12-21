//
//  Toy.swift
//  Veterinary
//
//  Created by Clement Yerochewski on 12/21/16.
//
//

import Vapor
import Fluent

final class Toy: Model {
    
    var exists: Bool = false
    var id: Node?
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("toys") { pets in
            pets.id()
            pets.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("toys")
    }
}

extension Toy {
    func pets() throws -> Siblings<Pet> {
        return try siblings()
    }    
}
